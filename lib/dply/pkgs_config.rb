require 'set'
require 'yaml'
require 'dply/helper'

module Dply
  class PkgsConfig

    include Helper

    def initialize(pkgs_yml = nil, build_mode: false)
      @pkgs_yml = pkgs_yml || "pkgs.yml"
      @build_mode = build_mode
      @pkgs = Set.new
    end

    def pkgs
      populate_all if not @populated
      @pkgs
    end

    private

    def config
      @config ||= load_yml
    end

    def load_yml
      if not File.readable? @pkgs_yml
        logger.debug "skipping yum pkgs"
        return {}
      end
      YAML.safe_load(File.read(@pkgs_yml))
    rescue => e
      error "error loading pkgs list" 
    end

    def populate_all
      populate :pkgs
      populate :build_pkgs if @build_mode
      @populated = true
    end

    def populate(pkg_set)
      list = config[pkg_set.to_s] || []
      list.each { |x| add x }
    end 
      
    def add(pkg)
      pkg = pkg.strip
      validate! pkg
      @pkgs << pkg
    end

    def validate!(pkg)
      msg = "invalid pkg name #{pkg}"
      error msg if pkg =~ /\.rpm\z/i
      error msg if pkg =~/\A[A-Za-z_0-9\.\-]\z/
    end

  end
end


