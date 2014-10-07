require 'dply/tasks'
require 'dply/shell'
require 'dply/git'
require 'dply/error'
require 'dply/logger'


module Dply
  module Helper

    def self.git
      Git
    end

    def self.tasks
      @tasks ||= Tasks.new
    end

    include Shell
    include Logger

    def git
      ::Dply::Helper.git
    end

    def tasks
      ::Dply::Helper.tasks
    end

    def error(msg)
      ::Dply::Error.new(msg)
    end

  end
end
