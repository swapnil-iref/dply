require 'ostruct'
require 'dply/helper'

module Dply
  class BuildConfig

    include Helper

    def initialize(dir: nil, read_config: true)
      @read_config = read_config
      @dir = (dir || Dir.pwd)
    end

    def config
      return @config if @config
      @config = {
        dir: @dir,
        task: "app:build",
        branch: :master,
        repo: nil,
        git: true,
        env: {},
        config_map: nil,
        dir_map: nil,
        shared_dirs: [],
        config_skip_download: [],
        config_download_url: nil
      }
      read_from_file if @read_config
      return @config
    end

    def branch(branch)
      set :branch, branch
    end

    def task(task)
      set :task, task
    end

    def repo(repo)
      set :repo, repo
    end

    def config_map(map)
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
      @config_file ||= "#{@dir}/build.rb"
    end

    def shared_dirs(dirs)
      raise if not dirs.is_a? Array
      @config[:shared_dirs] = dirs
    end

    def read_from_file
      if not File.readable? config_file
        error "build.rb not found in #{@dir}"
        return
      end
      instance_eval(File.read(config_file), config_file)
    rescue NoMethodError => e
      error "invalid option used in config: #{e.name}"
    end

  end
end
