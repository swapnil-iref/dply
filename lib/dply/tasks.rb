require 'dply/shell'
module Dply
  class Tasks

    include Shell

    def deploy(target)
      bundle_install
      cmd "#{rake_command} #{target}:deploy"
    end

    def switch(target)
      bundle_install
      cmd "#{rake_command} #{target}:switch"
    end

    def gemfile_exists?
      File.exists? "Gemfile"
    end

    def rake_command
      if gemfile_exists?
        "bundle exec rake -R dply"
      else
        "rake -R dply"
      end
    end

    def bundle_install
      return if not gemfile_exists?
      exitstatus = system "bundle check > /dev/null"
      return if exitstatus
      cmd "bundle install"
    end

  end
end
