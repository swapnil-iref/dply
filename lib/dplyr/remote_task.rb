require 'pty'
require 'dplyr/report'
require 'dply/logger'

module Dplyr
  class RemoteTask

    include ::Dply::Logger

    attr_reader :exit_status, :messages

    def initialize(host, task, id_size: nil)
      @host = host
      @task = task
      @messages = []
      @id_size = id_size || @host_info[:id].size
    end

    def run
      reset!
      r, w, pid = PTY.spawn(remote_cmd)
      pty_read(r, @host[:id])
      @exit_status = get_exit_status pid
    end

    def remote_cmd
      if logger.debug?
        %(#{ssh} -l #{user} #{addr} '#{env} drake --remote --debug -d #{dir} #{@task} 2>&1')
      else
        %(#{ssh} -l #{user} #{addr} '#{env} drake --remote -d #{dir} #{@task} 2>&1' 2>/dev/null)
      end
    end

    def user
      @host.fetch :user
    end

    def dir
      @host.fetch :dir
    end

    def addr
      @host.fetch :addr
    end

    def roles
      @host.fetch :roles
    end
    
    def ssh
      "ssh -tt -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    end

    def pty_read(file, id)
      file.each do |line|
        if line =~ /\Adply_msg\|/
          receive_message line
        else
          printf output_template, id, line
        end
      end
    rescue EOFError,Errno::ECONNRESET, Errno::EPIPE, Errno::EIO => e
    end

    def receive_message(msg_str)
      msg = msg_str.partition("|")[2].strip
      return if msg.empty?
      @messages << msg
    end

    def get_exit_status(pid)
      pid, status = Process.waitpid2(pid)
      return status
    end

    def output_template
      @output_template ||= begin
        id_template = "%-#{@id_size}s".bold.grey
        template = "#{id_template}  %s"
      end
    end

    def reset!
      @output_template = nil
    end

    def env
      @env ||= "PATH=/usr/sbin:/usr/local/sbin:$PATH #{roles_env}"
    end

    def roles_env
      return "" if not roles.size > 0
      roles_str = roles.join(",")
      "DPLY_ROLES=#{roles_str}"
    end

  end
end
