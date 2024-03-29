require 'dply/helper'
module Dply
  class Lock

    include Helper

    def initialize(dir = nil)
      @dir = dir
    end

    def acquire
      logger.debug "acquiring lock"
      lock_acquired = lock_file.flock(File::LOCK_NB | File::LOCK_EX)
      error "exclusive lock not available" if not lock_acquired
    end

    def lock_file
      @lock_file ||= File.open("#{dir}/.dply.lock", "a+")
    end

    private

    def dir
      @dir ||= Dir.pwd
    end

  end
end
