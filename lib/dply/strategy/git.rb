require 'dply/helper'
require 'dply/setup'
require 'dply/linker'
require 'forwardable'


module Dply
  module Strategy
    class Git
      
      extend Forwardable
      include Helper

      def_delegators :config, :target, :branch, :link_config,
                              :config_dir, :config_map, :dir_map
      
      attr_reader :config, :options

      def initialize(config, options)
        @config = config
        @options = options
      end

      def deploy
        setup.run
        Dir.chdir current_dir do
          git_step
          link_dirs
          link_config_files
          tasks.deploy target
        end
      end

      def switch
      end

      private

      def current_dir
        @current_dir ||= "#{config.deploy_dir}/current"
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
        dir_prefix = config_dir || "config"
        source = "#{config.deploy_dir}/config"
        dest = current_dir
        @config_linker ||= ::Dply::Linker.new(source, dest, map: config_map, dir_prefix: dir_prefix)
      end

      def dir_linker
        return @dir_linker if @dir_linker
        source = "#{config.deploy_dir}/shared"
        dest = current_dir
        @dir_linker ||= ::Dply::Linker.new(source, dest, map: dir_map)
      end

      def setup
        @setup ||= Setup.load(:git, config)
      end

    end
  end
end
