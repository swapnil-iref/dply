require 'json'
require 'dply/shell'
require 'dply/bundle'
require 'dply/yum'
require 'dply/pkgs_config'

module Dply
  class Tasks

    include Shell

    def initialize(deployment: true)
      @deployment = deployment
    end

    def deploy(target)
      bundle.install
      rake "#{target}:deploy"
    end

    def reload(target)
      bundle.install
      rake "#{target}:reload"
    end

    def task(task)
      bundle.install
      rake task
    end

    def build(task)
      bundle.install
      bundle.clean
      rake task
    end

    def rake(task)
      bundle.rake task
    end

    def report_changes(previous_version, current_version)
      info = {}
      info[:current] = current_version
      info[:previous] = previous_version
      logger.remote "#{JSON.dump info}"
    end

    def install_pkgs(build_mode: false, use_yum: false)
      if use_yum
        yum_install build_mode
      else
        command_install build_mode
      end
    end

    private

    def bundle
      @bundle ||= Bundle.new(deployment: @deployment)
    end

    def yum_install(build_mode)
      pkgs = PkgsConfig.new(build_mode: build_mode).pkgs
      Yum.new(pkgs, sudo: true).install
    end

    def command_install(build_mode)
      drake_command = ENV["DRAKE_COMMAND"] || "/opt/ruby/bin/drake"
      command = "sudo -n #{drake_command} install-pkgs"
      command << " -b" if build_mode
      cmd command
    end

  end
end
