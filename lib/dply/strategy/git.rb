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
      def_delegators :config, :target, :branch, :link_config,
                     :config_dir, :config_map, :dir_map, :config_skip_download,
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
          link_config_files
          yum = Yum.new("pkgs.yml")
          yum.install
          tasks.deploy target
          tasks.report_changes(previous_version, current_version)
        end
      end

      def reload
        download_configs if config_download_url
        Dir.chdir current_dir do
          link_dirs
          link_config_files
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

      def link_config_files
        return if not link_config
        logger.bullet "symlinking config files"
        config_linker.create_symlinks
      end

      def link_dirs
        return if not dir_map
        logger.bullet "symlinking shared dirs"
        dir_linker.create_symlinks
      end

      def config_linker
        return @config_linker if @config_linker
        source = "#{config.dir}/config"
        dest = current_dir
        @config_linker ||= ::Dply::Linker.new(source, dest, map: config_map)
      end

      def config_downloader
        @config_downloader = ::Dply::ConfigDownloader.new(config_map.values.uniq, config_download_url, config_skip_download: config_skip_download)
      end

      def dir_linker
        return @dir_linker if @dir_linker
        source = "#{config.dir}/shared"
        dest = current_dir
        @dir_linker ||= ::Dply::Linker.new(source, dest, map: dir_map)
      end

      def setup
        @setup ||= Setup.new(@config)
      end

      def tasks
        @tasks ||= Tasks.new(deployment: true)
      end

    end
  end
end
