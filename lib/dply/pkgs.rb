require 'yaml'
require 'dply/helper'
require_relative 'yum'

module Dply
  class Pkgs

    include Helper

    attr_reader :runtime, :build, :all

    def initialize(pkgs_yml = nil)
      @pkgs_yml = pkgs_yml || "pkgs.yml"
      read_config
    end

    def install(build_mode: false, sudo: false)
      pkgs = build_mode ? @all : @runtime
      Yum.new(pkgs, sudo: sudo).install
    end

    def installed?(build_mode: false)
      pkgs = build_mode ? @all : @runtime
      Yum.new(pkgs).installed?
    end

    private

    def read_config
      @read ||= begin
        config = load_yml
        error "data from pkgs.yml not a hash" if not config.is_a? Hash
        @runtime = config["pkgs"] || []
        @build = config["build_pkgs"] || []
        @all = @runtime + @build
        @all.each { |i| validate! i }
        true
      end
    end

    def load_yml
      if not File.readable? @pkgs_yml
        logger.debug "skipping yum pkgs"
        return {}
      end
      YAML.safe_load(File.read(@pkgs_yml)) || {}
    rescue => e
      error "error loading pkgs list" 
    end

    def validate!(pkg)
      msg = "invalid pkg name #{pkg}"
      error msg if pkg =~ /\.rpm\z/i
      error msg if pkg =~/\A[A-Za-z_0-9\.\-]\z/
      return true
    end

  end
end


