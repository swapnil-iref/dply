require 'dply/helper'
require 'dply/setup'
require 'dply/linker'
require 'dply/config_downloader'
require 'dply/yum'
require 'dply/release'
require 'forwardable'


module Dply
  module Strategy
    class Archive
      
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
        setup.archive
        download_configs if config_download_url
        install_release
        release.make_current
        previous_version = get_release
        Dir.chdir current_dir do
          tasks.deploy target
        end
        current_version = get_release
#       tasks.report_changes(previous_version, current_version)
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

      def get_release
        File.basename (File.readlink current_dir)
      end

      def download_configs
        files = config_map.values.uniq
        downloader = ConfigDownloader.new(files, config_download_url)
        downloader.skip_download = config_skip_download 
        downloader.download_all
      end

      def release
        @release ||= Release.new(
          revision, branch: branch,
          app_name: config.name,
          url: config.build_url
        )
      end

      def install_release
        release.install
        Dir.chdir release.path do
          link_dirs
          link_config_files
          yum_install
        end
      end

      def yum_install
        Yum.new("pkgs.yml").install
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
