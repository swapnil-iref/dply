require 'logger'
require 'dply/ext/string'
module Dply
  class CustomLogger < ::Logger

    def initialize(file)
      super(file)
      @level = ::Logger::INFO
    end

    def format_message(severity, timestamp, progname, msg)
      case severity
      when "INFO"
        "#{msg}\n"
      when "ERROR"
        "#{severity.bold.red} #{msg}\n"
      when "WARN"
        "#{severity.downcase.bold.yellow} #{msg}\n"
      else
        "#{severity.downcase.bold.blue} #{msg}\n"
      end
    end

    def bullet(msg)
      puts "#{"\u2219".bold.blue} #{msg}"
    end

  end
end
