require 'fileutils'
require 'dply/helper'
require 'dply/shared_dirs'

module Dply
  module Setup
    class Default

      include Helper

      attr_reader :config

      def initialize(config)
        @config = config
      end

      def run
        Dir.chdir config.deploy_dir do
          shared_dirs.create
        end
      end

      private

      def shared_dirs
        @shared_dirs ||= SharedDirs.new
      end

    end
  end
end
