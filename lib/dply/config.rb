require 'ostruct'
require 'dply/helper'

module Dply
  class Config

    include Helper
    attr_reader :deploy_dir, :read_config

    def initialize(deploy_dir, read_config: true)
      @deploy_dir = deploy_dir
      @read_config = read_config
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
        dir_map: nil,
        shared_dirs: [],
        config_skip_download: [],
        config_download_url: nil
      }
      read_from_file if read_config
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

    def config_skip_download(list)
      set :config_skip_download, list
    end

    def config_download_url(url)
      set :config_download_url, url
    end



    def dir_map(map)
      set :dir_map, map
    end

    def set_env(key, value)
      @config[:env].store key, value
    end

    def set(key, value)
      @config.store key, value
    end

    def to_struct
      OpenStruct.new(config)
    end

    def env(h)
      raise if not h.is_a? Hash
      @config[:env] = h
      @config[:env].each do |k,v|
        ENV[k.to_s] = v.to_s
      end
    end

    def config_file
      @config_file ||= "#{deploy_dir}/dply.rb"
    end

    def shared_dirs(dirs)
      raise if not dirs.is_a? Array
      @config[:shared_dirs] = dirs
    end

    def read_from_file
      if not File.readable? config_file
        raise error "dply.rb not found in #{deploy_dir}"
        return
      end
      instance_eval(File.read(config_file))
    rescue NoMethodError => e
      raise error "invalid option used in config: #{e.name}"
    end

  end
end
