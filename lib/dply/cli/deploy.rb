require 'dply/deploy'
require 'dply/logger'
require 'dply/lock'
require 'dply/config'

module Dply
  module Cli
    class Deploy

      include Logger

      attr_reader :argv

      def initialize(argv)
        @argv = argv
      end

      def run
        lock.acquire
        opts.parse!(argv)
        strategy.deploy
      end

      def strategy
        @strategy ||= Strategy.load(config, options)
      end

      def lock
        @lock ||= Lock.new
      end

      def config
       @config ||= Config.new.to_struct 
      end

      def opts
        OptionParser.new do |opts|

          opts.banner = "Usage: dply deploy [options] [target]"
          
          opts.on("-b", "--branch [BRANCH]" , "Specify git branch") do |b|
            config.branch = b
          end

          opts.on("-r", "--revision [REVISION]", "Specify build revision (only used in archive strategy)") do |r|
            config.revision = r
          end

          opts.on("--no-pull", "Enable/disable git pull") do |e|
            options[:no_pull] = true
          end

          opts.on("--skip-git", "Disable git") do |e|
            options[:skip_git] = true
          end  
          
          opts.on("--skip-bundler", "Skip bundle install") do |e|
            options[:skip_bundler] = true
          end

          opts.on("-h", "--help", "Help") do
            puts opts
            exit
          end
        end
      end

      def options
        @options ||= {}
      end

    end
  end
end
