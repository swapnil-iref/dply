require 'dply/helper'

module Dply
  class StagesConfig
    
    include Helper  
    attr_reader :config_file
    attr_accessor :current_stage

    def initialize(config_file)
      @config_file = config_file
    end

    def config
      return @config if @config
      @config = {
        stages: {}
      }
      read_from_file
      @config
    end


    def user(user)
      set_in_current_stage :user, user
    end

    def deploy_dir(deploy_dir)
      set_in_current_stage :deploy_dir, deploy_dir
    end

    def host(host, user: nil, deploy_dir: nil, id: nil)
      hosts = get_from_current_stage(:hosts) 
      host_info = {
        host: host,
        user: user || get_from_current_stage(:user),
        deploy_dir: deploy_dir || get_from_current_stage(:deploy_dir),
        id: id || host
      }
      hosts << host_info
    end

    def parallel_runs(parallel_runs)
      set_in_current_stage :parallel_runs, parallel_runs
    end

    def set_in_current_stage(key, value)
      stages[current_stage][key] = value
    end

    def get_from_current_stage(key)
      stages[current_stage][key]
    end

    def stages
      config[:stages]
    end

    def get_stage(stage)
      stage = stage.to_sym
      config[:stages][stage]
    end

    def stage(name)
      begin
        name = name.to_sym
        self.current_stage = name
        init_stage name
        yield
      ensure
        self.current_stage = nil
      end
    end

    def ask(key)
      print "Enter #{key}: "
      value = STDIN.gets.chomp
      env = get_from_current_stage(:env)
      env[key] = value
    end

    def init_stage(name)
      stages[name] = {
        hosts: [],
        parallel_runs: 1,
        env: {}
      }
    end


    def read_from_file
      if not File.readable? config_file
        error "#{config_file} not readable"
        return
      end
      instance_eval(File.read(config_file), config_file)
    rescue NoMethodError => e
       error "invalid option used in config: #{e.name} #{e.message}"
    end


  end
end
