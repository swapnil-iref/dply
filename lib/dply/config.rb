require 'ostruct'
require 'dply/error'
require 'dply/logger'

module Dply
  class Config

    include ::Dply::Logger
    attr_reader :deploy_dir

    def initialize(deploy_dir)
      @deploy_dir = deploy_dir
    end

    def config
      return @config if @config
      @config = {
        deploy_dir: deploy_dir,
        target: :default,
        branch: :master,
        strategy: :default,
        repo: nil,
        env: {},
        link_config: false,
        config_map: nil,
        shared_dirs: []
      }
      read_from_file
      return @config
    end

    def target(target)
      set :target, target
    end

    def branch(branch)
      set :branch, branch
    end

    def strategy(strategy)
      set :strategy, strategy
    end

    def repo(repo)
      set :repo, repo
    end

    def link_config(link_config)
      set :link_config, link_config
    end

    def config_map(map)
      set :link_config, true
      set :config_map, map
    end

    def env(key, value)
      @config[:env].store key, value
    end

    def set(key, value)
      @config.store key, value
    end

    def to_struct
      OpenStruct.new(config)
    end

    def env=(h)
      raise if not h.is_a? Hash
      @config[:env] = h
    end

    def config_file
      @config_file ||= "#{deploy_dir}/dply.rb"
    end

    def shared_dirs=(dirs)
      raise if not dirs.is_a? Array
      @config[:shared_dirs] = dirs
    end

    def read_from_file
      return if not File.readable? config_file
      instance_eval(File.read(config_file))
    rescue NoMethodError => e
      logger.warn "invalid option used in config: #{e.name}"
    end

  end
end
