module Dply
  class Release

    attr_reader release_dir

    def initialize(release_dir)
      @release_dir = release_dir
    end

    def create(repo_cache, branch)
      return if exists?
      FileUtils.mkdir uncommited_release_dir
      copy_source_code(repo_cache, branch)
    end

    def copy_source_code(repo_cache, branch)
      cmd "git archive #{branch} | tar -x -f - -C  #{uncommited_release_dir}"
    end

    def exists?
      File.exists? (release_dir) || File.exists? (uncommited_release_dir)
    end

    def uncommited_release_dir
      "#{release_dir}.uncommited"
    end

    def commit
      return if File.exists? (release_dir)
      FileUtils.mv uncommited_release_dir, release_dir
    end

  end
end
