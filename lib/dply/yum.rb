require 'dply/helper'
require 'yaml'

module Dply
  class Yum

    include Helper

    def initialize(pkgs_yml)
      @pkgs_yml = pkgs_yml
    end

    def pkgs
      @pkgs ||= load_pkgs
    end

    def install
      return if installed?
      cmd "sudo -n yum install -y #{not_installed_pkgs.join(' ')}"
    end

    private

    def pkgs_str
      pkgs.join " "
    end

    def not_installed_pkgs
      @not_installed_pkgs ||= query_not_installed
    end

    def query_not_installed
      return [] if pkgs_str.strip.empty?
      command = "rpm -V --noscripts --nodeps --nofiles #{pkgs_str}"
      matches = `#{command}`.scan(/^package (.*) is not installed$/)
    end

    def installed?
      not_installed_pkgs.size == 0
    end

    def load_pkgs
      if not File.readable? @pkgs_yml
        logger.debug "skipping yum pkgs"
        return []
      end
      YAML.load_file(@pkgs_yml)
    rescue => e
      error "error loading pkgs list" 
    end

  end
end
