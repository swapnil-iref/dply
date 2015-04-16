require 'dply/git'
module Dply
  class Repo

    attr_reader :dir, :upstream, :mirror

    def initialize(dir, upstream, mirror: nil)
      @dir = dir
      @upstream = upstream
      @mirror = mirror
    end

    def create
      if Dir.exist? "#{dir}/.git"
        raise "unable to create repo" if not verify_remote_url
      else
        Git.clone upstream, dir, mirror: @mirror
      end
    end

    private

    def verify_remote_url
      remote_url = Dir.chdir(dir) do
        Git.get_remote_url
      end
      remote_url == upstream
    end
 
  end
end
