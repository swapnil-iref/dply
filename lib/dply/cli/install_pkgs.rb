require 'dply/pkgs'
require 'dply/helper'

module Dply
  module Cli
    class InstallPkgs

      include Helper

      def initialize(argv)
        @argv = argv
        @options = {}
      end

      def run
        opts.parse!(@argv)
        error "pkgs.yml cannot be a symlink" if File.symlink? "pkgs.yml"
        pkgs = Pkgs.new
        pkgs.install(build_mode: @options[:build_mode])
        puts "installed"
      end

      def opts
        OptionParser.new do |opts|

          opts.banner = "Usage: drake install-pkgs [options] [target]"
          
          opts.on("-b" , "Build mode") do |b|
            @options[:build_mode] = true
          end

          opts.on("-h", "--help", "Help") do
            puts opts
            exit
          end
        end
      end


    end
  end
end
