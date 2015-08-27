require 'dply/helper'
require 'dply/tasks'
require 'dply/setup'
require 'dply/config_downloader'
require 'dply/yum'
require 'dply/release'
require 'dply/release_helper'
require 'forwardable'


module Dply
  module Strategy
    class Archive
      
      extend Forwardable
      include Helper

      attr_reader :config, :options
      def_delegators :config, :target, :branch, :revision, :name,
                     :config_map, :dir_map, :config_skip_download,
                     :config_download_url, :build_url
                
      def initialize(config, options)
        @config = config
        @options = options || {}
      end

      def deploy
        error "revision not specified( use -r)" if not revision 
        setup.archive
        if release.already_deployed? && release.current?
          logger.info "revision #{revision} is currently deployed"
          current_version = previous_version = get_release
          prune_releases
          tasks.report_changes(current_version, previous_version)
          return
        end
        download_configs if config_download_url
        install_release
        previous_version = get_release
        release.make_current
        Dir.chdir current_dir do
          tasks.deploy target
        end
        release.record_deployment
        current_version = get_release
        prune_releases
        tasks.report_changes(previous_version, current_version)
      end
      
      def reload
        download_configs if config_download_url
        Dir.chdir current_dir do
          link_all
          tasks.reload target
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

      def get_release
        return "NA" if not File.symlink? current_dir
        File.basename (File.readlink current_dir)
      end

      def download_configs
        files = config_map.values.uniq
        downloader = ConfigDownloader.new(files, config_download_url)
        downloader.skip_download = config_skip_download if config_skip_download 
        downloader.download_all
      end

      def release
        @release ||= Release.find_or_create(
          revision: revision,
          branch: branch,
          app_name: config.name,
          url: config.build_url
        )
      end

      def install_release
        release.verify_checksum = config.verify_checksum
        release.install
        Dir.chdir release.path do
          link_all
          tasks.install_pkgs(use_yum: options[:use_yum])
        end
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

      def setup
        @setup ||= Setup.new(@config)
      end

      def tasks
        @tasks ||= Tasks.new
      end

      def prune_releases
        ReleaseHelper.new.prune_releases
      end

    end
  end
end
