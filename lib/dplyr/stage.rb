require 'dply/helper'

module Dplyr
  class Stage

    include ::Dply::Helper

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

    def host(addr, user: nil, dir: nil, id: nil, roles: [])
      @hosts << ({
        addr: addr,
        user: user,
        dir: dir,
        id: id || addr,
        roles: cleaned_roles(roles)
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

    def add_default_roles
      return if not @hosts.size > 0
      @hosts.first[:roles] << "first"
      @hosts.last[:roles] << "last"
    end

    def finalize
      return if @finalized
      instance_eval &config_proc if config_proc
      fill_hosts
      add_default_roles
      @hosts.freeze
      @parallel_runs.freeze
      @finalized = true
    end

    def cleaned_roles(roles)
      error "roles must be an array" if not roles.is_a? Array
      roles.each do |r|
        r.strip!
        error "invalid role value #{r} " if not r =~ /\A[0-9A-Za-z_\-]+\z/
      end
      return roles
    end

  end
end

