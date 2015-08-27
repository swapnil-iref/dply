require 'dply/archive'
require 'dply/helper'
require 'tmpdir'

module Dply
  class Release

    include Helper

    attr_accessor :url, :verify_checksum
    attr_writer :name

    def self.find_or_create(**kwargs)
      release = new(**kwargs)
      name = find_installed_name(**kwargs)
      release.name = name if name
      return release
    end

    def self.find_installed_name(**kwargs)
      branch = kwargs.fetch(:branch).to_s.tr('-/', '__')
      app_name = kwargs.fetch(:app_name).to_s.tr('-/', '__')
      revision = kwargs.fetch(:revision)

      name_without_ts = "#{revision}-#{app_name}-#{branch}-"
      latest = Dir["releases/#{name_without_ts}*"].sort_by { |x, y| File.mtime(x) }.first
      latest ? File.basename(latest) : nil
    end

    def initialize(revision:, app_name:, branch:, url:)
      @revision = revision
      @branch = branch.to_s.tr('-/', '__')
      @app_name = app_name.to_s.tr('-/', '__')
      @url = url
    end

    def make_current
      error "cannot make not installed release current" if not installed?
      error "release path #{path} doesn't exist"  if not File.directory? path
      symlink path, "current"
    end

    def name
      @name ||= "#{@revision}-#{@app_name}-#{@branch}-#{timestamp}"
    end

    def install
      if installed?
        logger.debug "release #{name} already installed"
        return
      end
      archive.extract do |path|
        FileUtils.mv path, "releases/#{name}"
      end
    end

    def path
      @path ||= "releases/#{name}"
    end

    def record_deployment
      FileUtils.touch "#{path}/.deployed"
    end

    def already_deployed?
      File.exist? "#{path}/.deployed"
    end

    def current?
      return false if not File.symlink? "current"
      File.basename(File.readlink "current") == name
    end

    private

    def archive
      @archive ||= Archive.new(url, verify_checksum: @verify_checksum)
    end

    def timestamp
      Time.now.strftime "%Y%m%d%H%M%S"
    end

    def installed?
      File.exist? path
    end

  end
end
