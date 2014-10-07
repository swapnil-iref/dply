require 'fileutils'
require 'dply/helper'
require 'dply/repo'
require 'dply/shared_dirs'

module Dply
  module Setup
    class Git

      include Helper

      attr_reader :config

      def initialize(config)
        @config = config
      end

      def run
        Dir.chdir setup_dir do
          repo.create
          symlink "repo", "current"
          create_dirs
          shared_dirs.create_in "shared"
        end
      end

      private

      def repo
        @repo ||= ::Dply::Repo.new(repo_dir, config.repo)
      end

      def create_dirs
        dirs = ["config", "shared"]
        FileUtils.mkdir_p dirs
      end

      def shared_dirs
        @shared_dirs ||= SharedDirs.new(config.shared_dirs)
      end

      def setup_dir
        config.deploy_dir
      end

      def repo_dir
        "#{setup_dir}/repo"
      end

    end
  end
end
