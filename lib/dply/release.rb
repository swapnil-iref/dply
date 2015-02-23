require 'dply/archive'
require 'dply/helper'

module Dply
  class Release

    include Helper

    attr_accessor :url, :verify_checksum
    attr_reader :name

    def initialize(revision, app_name: nil, branch: nil, url: nil)
      @revision = revision
      @branch = branch
      @app_name = app_name
      @url = url
    end

    def make_current
      raise "cannot make not installed release current" if not installed?
      raise "release path #{path} doesn't exist"  if not File.directory? path
      symlink path, "current"
    end

    def install
      return if installed?
      @name = name_without_ts + timestamp
      path = "tmp/releases/#{name}"
      archive.extract_to path
      FileUtils.mv path, "releases"
      @installed = true
    end

    def path
      @path ||= "releases/#{@name}"
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

    def load_status
      name = name_without_ts
      latest = Dir["releases/#{name}*"].sort_by { |x, y| File.mtime(x) }.first
      if latest
        @installed = true
        @name = File.basename latest
      end
      @status_loaded = true
    end

    def installed?
      load_status if not @status_loaded
      @installed
    end

    def name_without_ts
      @name_without_ts ||= "#{@revision}-#{replace_dashes(@app_name)}-#{replace_dashes(@branch)}-"
    end

  end
end
