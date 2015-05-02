require 'json'
require 'dply/shell'
require 'dply/bundle'
require 'dply/yum'
require 'dply/linker'
require 'dply/pkgs_config'
require 'dply/error'
require 'etc'

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
      logger.remote "#{previous_version} => #{current_version}"
    end

    def install_pkgs(build_mode: false, use_yum: false)
      return if not File.exists? "pkgs.yml"
      drake_exists = File.exists? (drake_command)

      pkgs = get_pkgs(build_mode)
      if use_yum || !drake_exists
        yum_install pkgs
      else
        return if Yum.new(pkgs).installed?
        command_install build_mode
      end
    end

    def link(source, map)
      return if not map
      logger.bullet "symlinking #{source}"
      dest = Dir.pwd
      linker = Linker.new(source, dest, map: map)
      linker.create_symlinks
    end

    private

    def bundle
      @bundle ||= Bundle.new(deployment: @deployment)
    end

    def get_pkgs(build_mode)
      PkgsConfig.new(build_mode: build_mode).pkgs
    end

    def yum_install(pkgs)
      Yum.new(pkgs, sudo: true).install
    end

    def command_install(build_mode)
      command = "#{drake_command} install-pkgs"
      command << " -b" if build_mode
      check_sudo_permission command
      cmd "sudo -n #{command}"
    end

    def drake_command
      @drake_command ||= (ENV["DRAKE_COMMAND"] || "/opt/ruby/bin/drake")
    end

    def check_sudo_permission(command)
      output = `sudo -n -l #{command}`
      if output.chomp.strip == command
        return true
      else
        msg = []
        user = Etc.getpwuid(Process.uid).name
        msg << %{unable to run "#{command}" with sudo permissions}
        msg << %{To resolve add the following line to sudoers: }
        msg << %{#{user} ALL=(ALL) NOPASSWD: /opt/ruby/bin/drake install-pkgs *, /opt/ruby/bin/drake install-pkgs}.yellow 
        raise Error, msg.join("\n")
      end

    end

  end
end
