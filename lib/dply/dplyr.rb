require 'dply/stages_config'
require 'dply/remote_task'
module Dply
  class Dplyr

    attr_reader :stage, :argv
    def initialize(stage, argv)
      @stage = stage
      @argv = argv
    end

    def run
      case stage
      when 'dev'
        system "drake #{argv_str}"
      when 'local'
        system "drake #{argv_str}"
      else
        run_remote_task
      end
    end

    def stage_data
      @stage_data ||= StagesConfig.new("stages.rb").get_stage(stage)
    end

    def hosts
      stage_data[:hosts]
    end

    def parallel_jobs
      stage_data[:parallel_runs]
    end

    def argv_str
      @argv_str ||= argv.join(' ')
    end

    def run_remote_task
      remote_task = ::Dply::RemoteTask.new(hosts, argv_str, parallel_jobs: parallel_jobs)
      remote_task.run
    end

  end
end
