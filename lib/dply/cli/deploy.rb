require 'dply/deploy'
module Dply
  module Cli
    class Deploy

      attr_reader :deploy_dir, :argv

      def initialize(deploy_dir, argv)
        @deploy_dir = deploy_dir
        @argv = argv
      end

      def run
        opts.parse!(argv)
        target = argv.shift
        deploy.config.target = target if target
        deploy.options = options
        deploy.run
      end

      def deploy
        @deploy ||= ::Dply::Deploy.new(deploy_dir)
      end

      def opts
        OptionParser.new do |opts|

          opts.banner = "Usage: dply deploy [options] [target]"
          
          opts.on("-b", "--branch [BRANCH]" , "Specify git branch") do |b|
            options[:branch] = b
          end

          opts.on("--no-pull", "Enable/disable git pull") do |e|
            options[:no_pull] = true
          end

          opts.on("--skip-git", "Disable git") do |e|
            options[:skip_git] = true
          end  
          
          opts.on("--skip-bundler", "Skip bundle install") do |e|
            options[:skip_bundler] = true
          end

          opts.on("-h", "--help", "Help") do
            puts opts
            exit
          end
        end
      end

      def options
        @options ||= {}
      end

    end
  end
end
