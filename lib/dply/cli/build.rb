require 'dply/logger'
require 'dply/lock'
require 'dply/build'
require 'dply/build_config'

module Dply
  module Cli
    class Build

      include Logger

      def initialize(argv)
        @argv = argv
      end

      def run
        lock.acquire
        opts.parse!(@argv)
        build.run
      end

      def build
        @build ||= ::Dply::Build.new(config)
      end

      def config
        @config ||= ::Dply::BuildConfig.new.to_struct
      end

      def dir
        @dir ||= Dir.pwd
      end

      def lock
        @lock ||= ::Dply::Lock.new
      end

      def opts
        OptionParser.new do |opts|

          opts.banner = "Usage: drake build [options] [target]"
          
          opts.on("-b", "--branch [BRANCH]" , "Specify git branch") do |b|
            config.branch = b
          end

          opts.on("-r", "--revision [REVISION]", "Specify revision") do |r|
            config.revision = r
          end

          opts.on("--no-pull", "Enable/disable git pull") do |e|
            config.no_pull = true
          end

          opts.on("--skip-git", "Disable git") do |e|
            config.git = false
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
