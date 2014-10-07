require 'dply/helper'
module Dply
  class Lock

    include Helper
    attr_accessor :deploy_dir

    def initialize(deploy_dir)
      @deploy_dir = deploy_dir
    end

    def lock_file
      @lock_file ||= Dir.chdir(deploy_dir) do
        File.open(".dply.lock", "w+")
      end
    end

    def acquire
      logger.debug "acquiring exclusive lock"
      lock_file.flock(File::LOCK_EX)
    end

  end
end
