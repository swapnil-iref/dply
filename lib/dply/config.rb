require 'dply/helper'
require 'dply/config_struct'

module Dply
  class Config

    include Helper
    attr_reader :read_config

    def initialize(dir = nil, read_config: true)
      @dir = dir || Dir.pwd
      @read_config = read_config
    end

    def to_struct
      config
    end

    private 

    def config
      return @config if @config
      @config = ConfigStruct.new(@dir)
      read_from_file if read_config
      return @config
    end

    def name(name)
      set :name, name
    end

    def repo(repo)
      set :repo, repo
    end

    def mirror(repo)
      set :mirror, repo
    end

    def branch(branch)
      set :branch, branch
    end

    def strategy(strategy)
      set :strategy, strategy.to_sym
    end

    def target(target)
      set :target, target
    end

    def shared_dirs(dirs)
      raise if not dirs.is_a? Array
      set :shared_dirs, dirs
    end

    def config_map(map)
      set :config_map, map
    end

    def dir_map(map)
      set :dir_map, map
    end

    def config_download_url(url)
      set :config_download_url, url
    end

    def config_skip_download(list)
      set :config_skip_download, list
    end

    def verify_checksum(verify_checksum)
      set :verify_checksum, verify_checksum
    end


    def set(key, value)
      method = "#{key}=".to_sym
      @config.send method, value
    end

    def env(h)
      raise if not h.is_a? Hash
      h.each do |k,v|
        ENV[k.to_s] = v.to_s
      end
    end

    def config_file
      @config_file ||= begin
        found = ["#{@dir}/deploy.rb", "#{@dir}/dply.rb"].find { |f| File.readable? f }
        found || "#{@dir}/deploy.rb"
      end
    end

    def revision(revision)
      set :revision, revision
    end

    def latest_revision(&block)
      set :latest_revision, block
    end

    def build_url(&block)
      set :build_url_proc, block
    end

    def read_from_file
      if not File.readable? config_file
        error "deploy.rb not found in #{@dir}"
        return
      end
      instance_eval(File.read(config_file))
    rescue NoMethodError => e
      error "invalid option used in config: #{e.name}"
    end
  
  end
end
