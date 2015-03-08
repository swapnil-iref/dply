require 'dply/helper'
require 'dply/setup'
require 'dply/config_downloader'
require 'dply/yum'
require 'dply/tasks'
require 'forwardable'
require 'digest'

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
        link_all
        install_pkgs
        clean_build_dir
        link_build_dir
        tasks.build config.task
        generate_checksum
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

    def link_all
      link "#{config.dir}/shared", dir_map
      link "#{config.dir}/config", config_map
    end

    def install_pkgs
      tasks.install_pkgs(build_mode: true, use_yum: config.use_yum)
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

    def generate_checksum
      Dir["#{build_dir}/*"].each do |f|
        checksum = Digest::MD5.file f
        checksum_file = "#{f}.md5"
        File.open(checksum_file, 'w') { |cf| cf.write checksum }
      end
    end

    def tasks
      @tasks ||= Tasks.new
    end

  end
end
