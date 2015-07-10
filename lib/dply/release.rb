require 'dply/archive'
require 'dply/helper'
require 'tmpdir'

module Dply
  class Release

    include Helper

    attr_accessor :url, :verify_checksum
    attr_writer :name

    def self.find_or_create(revision, **kwargs)
      release = new(revision, **kwargs)
      name = find_installed_name(revision, **kwargs)
      release.name = name if name
      return release
    end

    def self.find_installed_name(revision, **kwargs)
      branch = kwargs.fetch(:branch).to_s.gsub(/-/, "_").sub("/", "_")
      app_name = kwargs.fetch(:app_name).to_s.gsub(/-/, "_")
      name_without_ts = "#{revision}-#{app_name}-#{branch}-"
      latest = Dir["releases/#{name_without_ts}*"].sort_by { |x, y| File.mtime(x) }.first
      latest ? File.basename(latest) : nil
    end

    def initialize(revision, app_name: nil, branch: nil, url: nil)
      @revision = revision
      @branch = branch.sub("/", "_")
      @app_name = app_name
      @url = url
    end

    def make_current
      error "cannot make not installed release current" if not installed?
      error "release path #{path} doesn't exist"  if not File.directory? path
      symlink path, "current"
    end

    def name
      @name ||= "#{@revision}-#{replace_dashes(@app_name)}-#{replace_dashes(@branch)}-#{timestamp}"
    end

    def install
      if installed?
        logger.debug "release #{name} already installed"
        return
      end
      Dir.mktmpdir "tmp" do |d|
        path = "#{d}/#{name}"
        archive.extract_to path
        FileUtils.mv path, "releases/"
      end
      archive.clean
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

    def replace_dashes(str)
      str.to_s.gsub(/-/, "_")
    end

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
