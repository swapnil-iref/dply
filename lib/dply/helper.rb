require 'dply/tasks'
require 'dply/shell'
require 'dply/git'
require 'dply/error'


module Dply
  module Helper

    def self.git
      Git
    end

    include Shell

    def git
      ::Dply::Helper.git
    end

    def error(msg)
      raise ::Dply::Error, msg
    end

  end
end
