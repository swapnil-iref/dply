require 'dply/shell'
module Dply
  class Tasks

    include Shell

    def initialize(deployment: true)
      @deployment = deployment
    end

    def deploy(target, env:{})
      env.merge!(env_from_yml)
      bundle_install
      cmd "#{rake_command} #{target}:deploy", env: env
    end

    def reload(target)
      bundle_install
      cmd "#{rake_command} #{target}:reload", env: env_from_yml
    end

    def task(task)
      bundle_install
      cmd "#{rake_command} #{task}"
    end

    def rake(task)
      cmd "#{rake_command} #{task}"
    end

    private

    def gemfile_exists?
      File.exists? "Gemfile"
    end

    def rake_command
      if gemfile_exists?
        "bundle exec rake -Nf dply/Rakefile -R dply"
      else
        "rake -Nf dply/Rakefile -R dply"
      end
    end

    def bundle_install
      return if not gemfile_exists?
      if @deployment
        bundle_install_deployment
      else
        bundle_install_global
      end
    end

    def bundle_install_global
      exitstatus = system "bundle check > /dev/null"
      return if exitstatus
      cmd "bundle install"
    end

    def bundle_install_deployment
      if deployment_config_present?
        exitstatus = system "bundle check > /dev/null"
        return if exitstatus
      end
      cmd "bundle install --deployment"
    end

    def deployment_config_present?
      file = ".bundle/config"
      if not File.readable? file
        return false
      end
      config = YAML.load_file file
      config["BUNDLE_FROZEN"] == "1" && config["BUNDLE_PATH"] == "vendor/bundle"
    rescue
      return false
    end

    def env_from_yml
      path = "config/env.yml"
      if not File.readable? path
        logger.debug "skipped loading env from #{path}"
        return {}
      end
      require 'yaml'
      YAML.load_file(path)
    end

  end
end
