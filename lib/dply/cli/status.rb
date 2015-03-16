require 'dply/logger'
require 'dply/release'
require 'dply/config'

module Dply
  module Cli
    class Status

      include Logger

      def initialize(argv)
        @argv = argv
      end

      def run
        print_status
      end

      def print_status
        r = current_release
        color = r[:deployed] ? :green : :red
        logger.info "#{r[:revision].send color} #{r[:project]} #{r[:branch]} #{r[:timestamp]}" 
      end

      def current_release
        @current_release ||= begin
          if File.symlink? current_dir
            name = File.basename( File.readlink current_dir )
          else
            name = "NA"
          end
          Release.parse name
        end
      end

      def current_dir
        @current_dir ||= "current"
      end

    end
  end
end
