require 'dply/helper'
require 'fileutils'
require 'yaml'
require 'shellwords'

module Dply
  class Bundle

    include Helper

    def install
      init
      return if check
      cmd "bundle install -j5 --deployment"
    end

    def rake(task)
      rakelib = Shellwords.shellescape "#{__dir__}/rakelib"
      rake_cmd = %(rake -R #{rakelib} -Nf dply/Rakefile #{task})
      command = gemfile_exists? ? "bundle exec #{rake_cmd}" : rake_cmd
      cmd command, env: env, display: false
    end

    def clean
      cmd "bundle clean"
    end

    private

    def init
      @init ||= begin
        h = {
          "BUNDLE_PATH" => "vendor/bundle",
          "BUNDLE_FROZEN" => "1",
          "BUNDLE_DISABLE_SHARED_GEMS" => "1"
        }
        FileUtils.mkdir_p ".bundle"
        File.open(".bundle/config", "w") { |f| f.write(YAML.dump h) }
      end
    end

    def check
      system "bundle check > /dev/null"
    end

    def env
      @env ||= begin
        env = {}
        env.merge! env_from_yml(".env.yml")
        env.merge! env_from_yml("config/env.yml")
        env
      end
    end

    def env_from_yml(path)
      if not File.readable? path
        logger.debug "skipped loading env from #{path}"
        return {}
      end
      require 'yaml'
      YAML.load_file(path)
    end

    def gemfile_exists?
      File.exists? "Gemfile"
    end

  end
end
