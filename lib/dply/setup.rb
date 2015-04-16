require 'fileutils'
require 'dply/helper'
require 'dply/repo'
require 'dply/shared_dirs'

module Dply
  class Setup

    include Helper

    def initialize(config)
      @config = config
    end

    def build
      dirs = ["config", "shared", "build"]
      create_repo if @config.git
      create_dirs dirs
      create_shared_dirs
    end

    def git
      dirs = ["config", "shared"]
      create_repo
      symlink "repo", "current"
      create_dirs dirs
      create_shared_dirs
    end

    def archive
      dirs = ["config", "shared", "releases", "tmp/cache"]
      create_dirs dirs
      create_shared_dirs
    end

    private

    def create_repo
      repo = ::Dply::Repo.new("repo", @config.repo, mirror: @config.mirror)
      repo.create
    end

    def create_dirs(dirs)
      FileUtils.mkdir_p dirs
    end

    def create_shared_dirs
      shared_dirs = SharedDirs.new(@config.shared_dirs)
      shared_dirs.create_in "shared"
    end

  end
end
