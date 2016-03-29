require 'dply/jenkins'
module Dply
  class ConfigStruct

    attr_writer :revision, :build_url, :build_url_proc, 
                :revision_proc, :latest_revision
    attr_accessor :dir, :name, :repo, :branch, :mirror,
                  :strategy, :target, :verify_checksum, 
                  :config_map, :dir_map, :shared_dirs, 
                  :config_download_url, :config_skip_download 

    def initialize(dir = nil)
      @dir = dir || Dir.pwd
      @target = nil
      @branch = :master
      @verify_checksum = true
      @shared_dirs = []
    end

    def revision
      if @revision == "latest"
        @revision = instance_eval(&latest_revision)
      else
        @revision
      end
    end

    def build_url
      @build_url ||= instance_eval(&build_url_proc)
    end

    def build_url_proc
      @build_url_proc ||= Proc.new do
        "#{repo}/artifacts/#{name}/#{revision}/#{name}-#{revision}-#{branch.to_s.tr("/","_")}.tar.gz"
      end
    end

    def dir_map
      @dir_map ||= {
        "tmp" => "tmp",
        "log" => "log"
      }
    end

    def latest_revision
      @latest_revision ||= Proc.new do
        Jenkins.new(@repo, @name).latest_successful_revision
      end
    end

  end
end
