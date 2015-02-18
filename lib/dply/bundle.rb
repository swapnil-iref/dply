require 'dply/shell'
module Dply
  class Bundle

    include Shell

    def initialize(deployment: true)
      @deployment = deployment
    end

    def install
      return if not gemfile_exists?
      if @deployment
        install_deployment
      else
        install_global
      end
    end

    def rake(task, **args)
      if gemfile_exists?
        cmd "bundle exec rake -Nf dply/Rakefile -R dply #{task}", env: env
      else
        cmd "rake -Nf dply/Rakefile -R dply #{task}", env: env
      end
    end

    def clean
      cmd "bundle clean"
    end

    private

    def install_global
      exitstatus = system "bundle check > /dev/null"
      return if exitstatus
      cmd "bundle install"
    end

    def install_deployment
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

    def env
      @env ||= env_from_yml
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

    def gemfile_exists?
      File.exists? "Gemfile"
    end

  end
end
