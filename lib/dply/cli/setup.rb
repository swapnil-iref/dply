require 'dply/logger'
require 'dply/lock'
require 'fileutils'
require 'erb'

module Dply
  module Cli
    class Setup

      include ::Dply::Logger

      def initialize(argv)
        @argv = argv
        @options = {}
      end

      def run
        opts.parse!(@argv)
        return if not proceed?
        lock.acquire
        setup_default
        setup_app_rake
      end

      def proceed?
        print "Are you sure?(y/n) "
        v = STDIN.gets.strip
        v == "y"
      end

      def setup_default
        if not File.exist? "dply"
          FileUtils.mkdir_p "dply"
          logger.info "created dply/"
        else
          logger.info "skipping dply/"
        end

        rakefile = "dply/Rakefile"
        if not File.exist? rakefile
          FileUtils.touch rakefile
          logger.info "created #{rakefile}"
        else
          logger.info "skipping #{rakefile}"
        end
        
        pkgs_yml = "pkgs.yml"
        if not File.exist? pkgs_yml
          FileUtils.cp "#{templates_dir}/pkgs.erb", pkgs_yml
          logger.info "created #{pkgs_yml}"
        else
          logger.info "skipping #{pkgs_yml}"
        end
      end

      def setup_app_rake
        tasks_file = "dply/app.rake"
        if File.exist? tasks_file
          logger.info "skipping #{tasks_file}"
          return
        end
        FileUtils.cp "#{templates_dir}/deploy.erb", tasks_file
        logger.info "created #{tasks_file}"
      end

      def templates_dir
        @templates_dir ||= "#{__dir__}/../templates"
      end

      def lock
        @lock ||= ::Dply::Lock.new
      end

      def opts
        OptionParser.new do |opts|

          opts.banner = "Usage: drake setup [options] [namespace]"

          opts.on("-h", "--help", "Help") do
            puts opts
            exit
          end
        end
      end

    end
  end
end
