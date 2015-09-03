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
        deplist = Deplist.new(tar_path)
        deplist.verify!
      end

    end
  end
end
