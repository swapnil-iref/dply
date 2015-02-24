require 'dply/shell'
require 'dply/bundle'
require 'json'
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

    private

    def bundle
      @bundle ||= Bundle.new(deployment: @deployment)
    end

  end
end
