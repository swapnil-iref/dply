require 'dply/pkgs_config'
require 'dply/deplist'
require 'dply/helper'

module Dply
  module Cli
    class Depcheck

      include Helper

      def initialize(argv)
        @argv = argv
      end

      def run
        tar_path = @argv.shift
        error "tar path not specified" if not tar_path
        tar_path = "#{Dir.pwd}/#{tar_path}"
        pkgs = PkgsConfig.new.pkgs
        deplist = Deplist.new(tar_path)
        deplist.verify! pkgs
      end

    end
  end
end
