require 'dply/logger'
module Dply
  class ReleaseHelper

    include Logger

    def current_release_dir
      current_dir = "current"
      return if not File.symlink? current_dir
      name = File.basename (File.readlink current_dir)
      "releases/#{name}"
    end

    def prune_releases(keep: 5)
      all_releases.reject! { |x| x == current_release_dir}[keep..-1].each do |d|
        logger.info "deleting old release #{File.basename d}"
        FileUtils.rm_rf d
      end
    end
    
    def all_releases
      Dir["releases/*"].sort! { |x, y| File.mtime(y) <=> File.mtime(x) }
    end 

    def parse(name)
      arr = name.split("-")
      deployed = File.exist? "releases/#{name}/.deployed"
      release = {
        revision: arr[0] || "NA",
        project: arr[1] || "NA",
        branch: arr[2] || "NA",
        timestamp: arr[3] || "NA",
        deployed: deployed
      }
    end

  end
end
