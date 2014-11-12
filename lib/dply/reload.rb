require 'dply/strategy'
require 'dply/config'

module Dply
  class Reload

    attr_reader :deploy_dir
    attr_writer :options

    def initialize(deploy_dir)
      @deploy_dir = deploy_dir
    end

    def run
      strategy.reload
    end

    def config
      @config ||= Config.new(deploy_dir).to_struct
    end

    def strategy
      @strategy ||= Strategy.load(config, options)
    end

    def options
      @options ||= {}
    end


  end
end
