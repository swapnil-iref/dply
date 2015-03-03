require 'dply/logger'
require 'dply/lock'
require 'dply/strategy'
require 'dply/config'

module Dply
  module Cli
    class Task

      include Logger

      def initialize(argv)
        @argv = argv
      end

      def run
        task_name = @argv.shift
        error "task name not specified" if not task_name
        lock.acquire
        strategy.task(task_name)
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
