require 'dply/helper'
module Dplyr
  class TasksConfig

    include ::Dply::Helper
    
    def initialize(config_file)
      @config_file = config_file || "tasks.rb"
      @tasks = {}
    end

    def task(name, &block)
      @tasks[name.to_sym] = block
    end

    def get_task
      
    end

    private

    def read_from_file
      if not File.readable? @config_file
        error "#{config_file} not readable"
        return
      end
      instance_eval(File.read(config_file), config_file)
    rescue NoMethodError => e
       error "invalid option used in config: #{e.name} #{e.message}"
    end

  end
end
