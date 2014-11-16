require 'dply/strategy'
require 'dply/config'

module Dply
  class Reload

    attr_reader :deploy_dir, :config
    attr_writer :options

    def initialize(deploy_dir, config)
      @deploy_dir = deploy_dir
      @config = config
    end

    def run
      strategy.reload
    end
    
    def strategy
      @strategy ||= Strategy.load(config, options)
    end

    def options
      @options ||= {}
    end


  end
end
