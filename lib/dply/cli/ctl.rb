require 'dply/lock'
require 'dply/strategy'
require 'dply/config'
require 'dply/tasks'

module Dply
  module Cli
    class Ctl

      def run(command)
        case command
        when :start, :stop, :reopen_logs
          config
          lock.acquire
          Dir.chdir("current") { tasks.send command.to_sym }
        when :reload
          lock.acquire
          strategy.reload
        end
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

      def tasks
        @tasks ||= ::Dply::Tasks.new
      end

    end
  end
end
