require 'logger'
require 'dply/custom_logger'
module Dply
  module Logger

    class << self
      attr_writer :logger
    end

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

    def debug?
      logger.level == ::Logger::DEBUG
    end

  end
end
