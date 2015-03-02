require 'dply/helper'

module Dply
  class Yum

    include Helper

    def initialize(pkgs, sudo: false)
      if pkgs.is_a? Set
        @pkgs = pkgs.to_a
      else
        @pkgs = pkgs
      end
      @sudo = sudo
    end

    def install
      return if installed?
      command = ""
      command << "sudo -n " if @sudo
      command << "yum install -y #{not_installed_pkgs.join(' ')}"
      cmd command
    end

    private

    def pkgs_str
      @pkgs.join " "
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

  end
end
