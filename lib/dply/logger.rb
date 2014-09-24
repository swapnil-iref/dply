require 'logger'
require 'dply/custom_logger'
module Dply
  module Logger

    def self.logger
      @logger ||= ::Dply::CustomLogger.new(STDOUT)
    end

    def self.stderr
      @stderr ||= ::Logger.new(STDERR)
    end

    def logger
      ::Dply::Logger.logger
    end

    def stderr
      ::Dply::Logger.stderr
    end

  end
end
