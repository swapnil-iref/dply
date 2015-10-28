require 'dply/helper'
require 'dply/setup'
require 'dply/config_downloader'
require 'dply/yum'
require 'dply/tasks'
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
          link_all
          install_pkgs
          tasks.deploy :git
          tasks.report_changes(previous_version, current_version)
        end
      end

      def reload
        download_configs if config_download_url
        Dir.chdir current_dir do
          link_all
          tasks.reload
        end
      end

      def reopen_logs
        Dir.chdir(current_dir) { tasks.rake "#{target}:reopen_logs" }
      end

      def task(task_name)
        Dir.chdir(current_dir) { tasks.task task_name }
      end

      private

      def current_dir
        @current_dir ||= "#{config.dir}/current"
      end

      def download_configs
        files = config_map.values.uniq
        downloader = ConfigDownloader.new(files, config_download_url)
        downloader.skip_download = config_skip_download if config_skip_download 
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

      def link_all
        tasks.link "#{config.dir}/shared", dir_map
        tasks.link "#{config.dir}/config", config_map
      end

      def install_pkgs
        tasks.install_pkgs(use_yum: options[:use_yum], build_mode: true)
      end

      def setup
        @setup ||= Setup.new(@config)
      end

      def tasks
        @tasks ||= Tasks.new
      end

    end
  end
end
