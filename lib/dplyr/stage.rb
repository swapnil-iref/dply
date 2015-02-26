module Dplyr
  class Stage

    attr_accessor :config_proc

    def initialize(name)
      @name = name.to_sym
      @hosts = []
      @parallel_runs = 1
    end

    def data
      finalize
      return ({
        parallel_runs: @parallel_runs,
        hosts: @hosts,
        env: {}
      })
    end

    def host(host, user: nil, dir: nil, id: nil)
      @hosts << ({
        host: host,
        user: user,
        dir: dir,
        id: id || host
      })
    end

    def dir(dir)
      @dir = dir
    end

    def user(user)
      @user = user
    end

    def parallel_runs(parallel_runs)
      @parallel_runs = parallel_runs
    end

    def fill_hosts
      @hosts.each do |host|
        host[:user] ||= fetch(:user)
        host[:dir] ||= fetch(:dir)
      end
    end

    alias_method :deploy_dir, :dir

    def fetch(var)
      value = instance_variable_get("@#{var}")
      raise "error accessing var #{var} for stage #{name}" if not value
      return value
    end

    def finalize
      return if @finalized
      instance_eval &config_proc if config_proc
      fill_hosts
      @hosts.freeze
      @parallel_runs.freeze
      @finalized = true
    end

  end
end

