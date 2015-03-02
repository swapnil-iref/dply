require 'dply/helper'
require 'dply/setup'
require 'dply/linker'
require 'dply/config_downloader'
require 'dply/yum'
require 'forwardable'


module Dply
  module Strategy
    class Git
      
      extend Forwardable
      include Helper

      attr_reader :config, :options
      def_delegators :config, :target, :branch,
                     :config_map, :dir_map, :config_skip_download,
                     :config_download_url
                
      def initialize(config, options)
        @config = config
        @options = options || {}
      end

      def deploy
        setup.git
        download_configs if config_download_url
        Dir.chdir current_dir do
          previous_version = git.commit_id
          git_step
          current_version = git.commit_id
          link_dirs
          link_config
          install_pkgs
          tasks.deploy target
          tasks.report_changes(previous_version, current_version)
        end
      end

      def reload
        download_configs if config_download_url
        Dir.chdir current_dir do
          link_dirs
          link_config
          tasks.reload target
        end
      end

      private

      def current_dir
        @current_dir ||= "#{config.dir}/current"
      end

      def download_configs
        files = config_map.values.uniq
        downloader = ConfigDownloader.new(files, config_download_url)
        downloader.skip_download = config_skip_download 
        downloader.download_all
      end

      def git_step
        return if options[:skip_git]
        if options[:no_pull]
          git.checkout branch
        else
          git.pull branch
        end
      end

      def link_dirs
        link "#{config.dir}/shared", dir_map
      end

      def link_config
        link "#{config.dir}/config", config_map
      end

      def install_pkgs
        tasks.install_pkgs(use_yum: options[:use_yum])
      end

      def setup
        @setup ||= Setup.new(@config)
      end

      def tasks
        @tasks ||= Tasks.new(deployment: true)
      end

      def link(source, map)
        return if not map
        logger.bullet "symlinking #{source}"
        dest = current_dir
        linker = Linker.new(source, dest, map: map)
        linker.create_symlinks
      end

    end
  end
end
