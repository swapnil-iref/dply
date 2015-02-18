require 'dply/helper'
require 'dply/setup'
require 'dply/linker'
require 'dply/config_downloader'
require 'dply/yum'
require 'dply/tasks'
require 'forwardable'

module Dply
  class Build

    extend Forwardable
    include Helper

    def_delegators :config, :target, :branch, :config_download_url,
                          :config_map, :dir_map, :config_skip_download

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def run
      setup
      download_configs if config_download_url
      Dir.chdir repo_dir do
        git_step
        git.clean
        link_dirs
        link_config
        yum_install
        clean_build_dir
        link_build_dir
        tasks.build config.task
      end
    end

    private 

    def setup
      setup = Setup.new(@config)
      setup.build
    end

    def download_configs
      files = config_map.values.uniq
      downloader = ConfigDownloader.new(files, config_download_url)
      downloader.skip_download = config_skip_download 
      downloader.download_all
    end
  
    def git_step
      return unless config.git
      if config.no_pull
        git.checkout branch
      else
        git.pull branch
      end
    end

    def link_dirs
      return if not dir_map
      logger.bullet "symlinking shared dirs"
      source = "#{config.dir}/shared"
      link source , dir_map
    end

    def link_config
      return if not config_map
      logger.bullet "symlinking config files"
      source = "#{config.dir}/config"
      link source, config_map  
    end

    def yum_install
      yum = Yum.new("pkgs.yml")
      yum.install
    end

    def link(source, map)
      dest = repo_dir
      linker = Linker.new(source, dest, map: map)
      linker.create_symlinks
    end

    def clean_build_dir
      logger.debug "clearing build dir"
      FileUtils.rm_rf build_dir if File.exists? build_dir
      FileUtils.mkdir build_dir
    end

    def link_build_dir
      build_artifacts = "tmp/build_artifacts"
      FileUtils.rm_rf build_artifacts if File.exists? build_artifacts
      symlink build_dir, build_artifacts
    end
    
    def repo_dir
      @repo_dir ||= "#{config.dir}/repo"
    end

    def build_dir
      @build_dir ||= "#{config.dir}/build"
    end

    def tasks
      @tasks ||= Tasks.new
    end

  end
end
