require 'dply/helper'
require 'dplyr/stage'

module Dplyr
  class StagesConfig
    
    include ::Dply::Helper  
    attr_reader :config_file
    attr_accessor :current_stage

    def initialize(config_file = nil)
      @config_file = config_file || "stages.rb"
      @stages = {}
    end

    def stage(name, &block)
      name = name.to_sym
      stage = Stage.new(name)
      stage.config_proc = block
      @stages[name] = stage
    end

    def read_from_file
      return if @read
      error "#{config_file} not readable" if not File.readable? config_file
      instance_eval(File.read(config_file), config_file)
    rescue NoMethodError => e
       error "invalid option used in config: #{e.name} #{e.message}"
    ensure
      @read = true
    end

    def fetch(stage)
      read_from_file
      @stages[stage.to_sym]
    end

  end
end
