require 'dply/helper'
require 'dply/setup'
require 'dply/linker'


module Dply
  module Strategy
    class Default
      
      include Helper
      attr_reader :config, :options

      def initialize(config, options)
        @config = config
        @options = options
      end

      def deploy
        Dir.chdir deploy_dir do
          git_step
          tasks.deploy config.target
        end
      end

      def switch

      end

      private

      def deploy_dir
        config.deploy_dir
      end

      def branch
        config.branch
      end

      def git_step
        return if options[:skip_git]
        if options[:no_pull]
          git.checkout branch
        else
          git.pull branch
        end
      end

    end
  end
end
