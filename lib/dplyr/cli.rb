require 'dplyr/stages_config'
require 'dplyr/remote_task'
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
      remote_task = RemoteTask.new(hosts, argv_str, parallel_jobs: parallel_jobs, env: env_str)
      remote_task.run
    end

  end
end
