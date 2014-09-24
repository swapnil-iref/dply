require 'fileutils'
require 'dply/helper'

module Dply
  class Setup

    include Helper

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def run
      method = "#{config.mode}_mode".to_sym
      send method
    end

    def git_mode
      Dir.chdir deploy_dir do
        git.clone config.repo, "repo"
        FileUtils.mkdir_p "config"
        symlink "repo", "current"
      end
    end

    def release_mode
      Dir.chdir deploy_dir do
        git.clone "repo_cache"
        FileUtils.mkdir_p "shared", "releases", "config"
        create_tmp_dirs "shared"
        create_extra_shared_dirs "shared"
      end
    end

    def default_mode
      create_tmp_dirs deploy_dir
    end

    private

    def create_tmp_dirs(dir)
      dirs = "tmp/sockets", "tmp/pids", "log"
      Dir.chdir(dir) { FileUtils.mkdir_p dirs }
    end

    def create_extra_shared_dirs(dir)
      dirs = config.shared_dirs
      Dir.chdir dir { FileUtils.mkdir_p dirs }
    end

    def deploy_dir
      config.deploy_dir
    end

  end
end
