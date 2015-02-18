require 'dply/shell'
require 'dply/bundle'
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

    private

    def bundle
      @bundle ||= Bundle.new(deployment: @deployment)
    end

  end
end
