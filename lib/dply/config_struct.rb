require 'dply/jenkins'
module Dply
  class ConfigStruct

    attr_writer :revision, :build_url, :build_url_proc, :revision_proc
    attr_accessor :dir, :name, :repo, :branch, 
                  :strategy, :target, 
                  :config_map, :dir_map, :shared_dirs, 
                  :config_download_url, :config_skip_download 

    def initialize(dir = nil)
      @dir = dir || Dir.pwd
      @target = :default
      @branch = :master
    end

    def revision
      @revision ||= instance_eval(&revision_proc)
    end

    def build_url
      @build_url ||= instance_eval(&build_url_proc)
    end

    def revision_proc
      @revision_proc ||= Proc.new do
        jenkins = Jenkins.new(repo, name)
        jenkins.latest_successful_revision
      end
    end

    def build_url_proc
      @build_url_proc ||= Proc.new do
        "#{repo.chomp("/")}/job/#{name}/#{revision}/artifact/build/#{name}-#{revision}-#{branch}.tar.gz"
      end
    end

  end
end
