require 'fileutils'

module Dply
  class SharedDirs

    def initalize(extra_dirs)
      dirs << extra_dirs
    end

    def create
      FileUtils.mkdir_p dirs
    end 

    def create_in(dir)
      Dir.chdir(dir) { create }
    end

    def dirs
      @dirs ||= [
        "tmp",
        "log",
        "tmp/pids",
        "tmp/sockets"
      ]
    end

  end
end
