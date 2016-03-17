require 'dply/logger'
require 'dply/lock'
require 'dply/tasks'
require 'fileutils'

module Dply
  module Cli
    class Devbuild

      include Logger

      def initialize(argv)
        @argv = argv
        @options = {}
      end

      def run
        lock.acquire
        opts.parse!(@argv)
        revision = @options[:revision] || "dev"
        ENV["BUILD_NUMBER"] = revision

        build_artifacts = "tmp/build_artifacts"
        FileUtils.mkdir_p build_artifacts

        clear_bundle_config
        tasks.install_pkgs(build_mode: true, use_yum: @options[:use_yum])
        tasks.build "app:build"
      ensure
        clear_bundle_config
      end

      def tasks
        @tasks ||= ::Dply::Tasks.new
      end

      def lock
        @lock ||= ::Dply::Lock.new
      end

      def clear_bundle_config
        FileUtils.rm ".bundle/config" if File.exists? ".bundle/config"
      end

      def opts
        OptionParser.new do |opts|

          opts.banner = "Usage: drake devbuild [options] [target]"

          opts.on("-r", "--revision [REVISION]", "Specify revision") do |r|
            @options[:revision] = r
          end

          opts.on("--use-yum", "use yum to install packages") do |e|
            @options[:use_yum] = true
          end

          opts.on("-h", "--help", "Help") do
            puts opts
            exit
          end
        end
      end

    end
  end
end
