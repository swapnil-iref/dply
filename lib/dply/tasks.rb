require 'dply/shell'
module Dply
  class Tasks

    include Shell

    def deploy(target, env:{})
      env.merge!(env_from_yml)
      bundle_install
      cmd "#{rake_command} #{target}:deploy", env: env
    end

    def switch(target, env:{})
      env.merge!(env_from_yml)
      bundle_install
      cmd "#{rake_command} #{target}:switch", env: env
    end

    def reload(target)
      bundle_install
      cmd "#{rake_command} #{target}:reload", env: env_from_yml
    end

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
      exitstatus = system "bundle check > /dev/null"
      return if exitstatus
      cmd "bundle install"
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
