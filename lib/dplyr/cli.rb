require 'dplyr/stages_config'
require 'dplyr/task_runner'
require 'dply/logger'

module Dplyr
  class Cli

    include ::Dply::Logger

    attr_reader :stage, :argv
    def initialize(stage, argv)
      @stage = stage
      @argv = argv
    end

    def run
      global_switches = []
      global_switches << "--debug" if  logger.debug?
      case stage
      when 'dev'
        global_switches << "--no-config"
        system "drake #{global_switches.join(" ")} #{argv_str}"
      when 'local'
        system "drake #{global_switches.join(" ")} #{argv_str}"
      else
        command = argv[0]
        case command
        when "list"
          require 'pp'
          pp hosts
        else
          run_remote_task
        end
      end
    end

    def stage_data
      @stage_data ||= StagesConfig.new.fetch(@stage).data
    end

    def hosts
      stage_data[:hosts]
    end

    def parallel_jobs
      stage_data[:parallel_runs]
    end

    def env_str
      str = ""
      stage_data[:env].each do |k,v|
        str << %(DPLY_#{k.upcase}="#{v}" )
      end
      str
    end

    def argv_str
      @argv_str ||= argv.join(' ')
    end

    def run_remote_task
      task_runner  = TaskRunner.new(hosts, argv_str, parallel_jobs: parallel_jobs)
      task_runner.run
    end

  end
end
