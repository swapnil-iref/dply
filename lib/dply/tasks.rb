require 'dply/shell'
module Dply
  class Tasks

    include Shell

    def deploy(target)
      cmd "bundle install"
      cmd "bundle exec rake -R dply #{target}:deploy"
    end

    def switch(target)
      cmd "bundle install"
      cmd "bundle exec rake -R dply #{target}:switch"
    end

  end
end
