require 'logger'
require 'dply/ext/string'
module Dply
  class CustomLogger < ::Logger

    attr_writer :trace_mode, :remote_mode, :enable_markers

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
        "#{severity[0].bold.blue} #{msg}\n"
      end
    end

    def bullet(msg)
      info "#{"\u2219".bold.blue} #{msg}"
    end

    def trace(msg)
      return if not @trace_mode
      info %(#{"T".bold.blue} #{msg}\n)
    end

    def remote(msg)
      return if not @remote_mode
      info %{dply_msg|#{msg}}
    end

    def marker(msg)
      return if not @enable_markers
      info "dply_marker:#{msg}"
    end

    def silence!
      @logdev = nil
    end

  end
end
