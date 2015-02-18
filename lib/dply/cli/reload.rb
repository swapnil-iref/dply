require 'dply/logger'
require 'dply/lock'

module Dply
  module Cli
    class Reload

      include Logger

      def initialize(argv)
        @argv = argv
      end

      def run
        lock.acquire
        strategy.deploy
      end

      def strategy
        @strategy ||= ::Dply::Strategy.load(config, options)
      end

      def config
        @config ||= ::Dply::Config.new(dir).to_struct
      end

      def dir
        @dir ||= Dir.pwd
      end

      def lock
        @lock ||= ::Dply::Lock.new
      end

      def options
        @options ||= {}
      end

    end
  end
end
