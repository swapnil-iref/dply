require 'dply/reload'
require 'dply/logger'
require 'dply/lock'

module Dply
  module Cli
    class Reload

      include Logger

      attr_reader :deploy_dir, :argv

      def initialize(deploy_dir, argv)
        @deploy_dir = deploy_dir
        @argv = argv
      end

      def run
        lock.acquire
        opts.parse!(argv)
        target = argv.shift
        reload.config.target = target if target
        reload.options = options
        reload.run
      end

      def reload
        @reload ||= ::Dply::Reload.new(deploy_dir)
      end

      def lock
        @lock ||= ::Dply::Lock.new(deploy_dir)
      end

      def opts
        OptionParser.new do |opts|

          opts.banner = "Usage: dply reload [options] [target]"
          
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
