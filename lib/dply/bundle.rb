require 'dply/helper'
module Dply
  class Bundle

    include Helper

    def install_deployment
      install(without: ["test", "development"])
    end

    def install_test
      install(without: ["development"])
    end

    def rake(task, **args)
      if gemfile_exists?
        cmd "bundle exec rake -Nf dply/Rakefile -R dply #{task}", env: env
      else
        cmd "rake -Nf dply/Rakefile -R dply #{task}", env: env
      end
    end

    def clean
      bundle_without(without: ["development"])
      cmd "bundle clean"
    end

    private

    def check
      system "bundle check > /dev/null"
    end

    def install(without:[])
      #persists BUNDLE_WITHOUT config
      bundle_without(without: without)
      return if check
      cmd "bundle install -j5 --deployment"
    end

    def bundle_without(without: [])
      value = without.join(":")
      cmd "bundle config --local without #{value}", return_output: true
    end

    def env
      @env ||= begin
        env = {}
        env.merge! env_from_yml(".env.yml")
        env.merge! env_from_yml("config/env.yml")
        env
      end
    end

    def env_from_yml(path)
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
