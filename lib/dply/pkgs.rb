require 'yaml'
require 'dply/helper'
require 'yum'

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
        @runtime = config[:pkgs].select { |i| validate! i}
        @build = config[:build_pkgs].select { |i| validate! i }
        @all = @runtime + @build
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


