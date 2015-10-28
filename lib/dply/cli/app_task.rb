require 'dply/helper'
require 'dply/lock'
require 'dply/tasks'
require 'dply/config'

module Dply
  module Cli
    class AppTask

      include Helper

      def initialize(argv)
        @argv = argv
      end

      def run
        task_name = @argv.shift
        error "task name not specified" if not task_name
        config
        lock.acquire
        Dir.chdir("current") { tasks.app_task task_name }
      end

      def tasks
        @tasks ||= ::Dply::Tasks.new
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
