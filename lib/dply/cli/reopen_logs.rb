require 'dply/logger'
require 'dply/lock'
require 'dply/strategy'
require 'dply/config'

module Dply
  module Cli
    class ReopenLogs

      include Logger

      def initialize(argv)
        @argv = argv
      end

      def run
        lock.acquire
        strategy.reopen_logs
      end

      def strategy
        @strategy ||= Strategy.load(config, {})
      end

      def config
        @config ||= Config.new.to_struct
      end

      def lock
        @lock ||= Lock.new
      end

    end
  end
end
