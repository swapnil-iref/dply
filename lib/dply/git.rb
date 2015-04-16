require 'dply/shell'
module Dply
  module Git

    extend Shell

    def self.pull(branch)
      cmd "git fetch"
      checkout(branch)
      if tracking_branch = get_tracking_branch(branch)
        cmd "git merge #{tracking_branch}"
      else
        cmd "git pull origin #{branch}"
      end
    end
  
    def self.checkout(branch)
      current_branch = `git rev-parse --abbrev-ref HEAD `.chomp.to_sym
      cmd "git checkout #{branch}" if branch != current_branch
    end

    def self.clone(repo, dir, mirror: nil)
      if mirror
        cmd "git clone #{mirror} #{dir}"
        Dir.chdir(dir) { cmd "git remote set-url origin #{repo}" }
      else
        cmd "git clone #{repo} #{dir}"
      end
    end

    def self.clean
      cmd "git reset --hard HEAD"
      cmd "git clean -dxf "
    end

    def self.get_tracking_branch(branch)
      command = "git for-each-ref --format='%(upstream:short)' refs/heads/#{branch} --count=1"
      tracking_branch = `#{command}`
      if tracking_branch =~ /[a-zA-Z0-9_]/
        return tracking_branch.chomp!
      else
        return nil
      end  
    end

    def self.get_remote_url
     remote_url = cmd "git config --get remote.origin.url", return_output: true, display: false
     logger.debug remote_url.chomp
     remote_url.chomp
    end

    def self.commit_id
      commit_id = cmd "git rev-parse HEAD", return_output: true, display: false
      logger.debug commit_id.chomp
      commit_id.chomp
    end

  end
end
