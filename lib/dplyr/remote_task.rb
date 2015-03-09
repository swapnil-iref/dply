require 'pty'
require 'dplyr/report'
require 'dply/logger'

module Dplyr
  class RemoteTask

    include ::Dply::Logger
    
    attr_reader :hosts, :parallel_jobs, :task, :env

    def initialize(hosts, task, parallel_jobs: 1, env: "")
      @hosts = hosts
      @parallel_jobs = parallel_jobs
      @task = task
      @env = env
      @env << " PATH=/usr/sbin:/usr/local/sbin:$PATH"
    end

    def run
      if parallel_jobs > 1 && hosts.count > 1
        run_in_parallel
      else
        run_serially
      end
    end

    def run_in_parallel
      init_run
      parallel_jobs.times do
        spawn_queued_job
      end
      loop do
        break if @queue.empty?
        @mq.pop
        spawn_queued_job
      end
      report.print_full
    end

    def run_serially
      hosts.each do |host_info|
        puts "=== Running on #{host_info[:id]} ==="
        run_cmd = remote_cmd host_info
        system run_cmd
        puts 
        raise ::Dply::Error, "remote deploy failed on #{host_info[:id]}" if $? != 0
      end
    end

    private

    def init_run
      queue_all_hosts
      job_output_template
      @threads = {}
      @mq = Queue.new
    end

    def queue_all_hosts
      @queue = Queue.new
      hosts.each { |h| @queue << h }
    end

    def spawn_job(host_info)
      run_cmd = remote_cmd host_info
      thread = popen(run_cmd, host_info)
      @threads[host_info] = thread
    end

    def spawn_queued_job
      return if @queue.empty?
      host = @queue.pop(false)
      spawn_job host
    rescue ThreadError
    end

    def remote_cmd(host_info)
      user = host_info[:user]
      host = host_info[:host]
      dir = host_info[:dir]
      if logger.debug?
        %(ssh -tt -oBatchMode=yes -l #{user} #{host} '#{env} drake --remote --debug -d #{dir} #{task} 2>&1')
      else
        %(ssh -tt -oBatchMode=yes -l #{user} #{host} '#{env} drake --remote -d #{dir} #{task} 2>&1' 2>/dev/null)
      end
    end

    def pty_read(file, id)
      file.each do |line|
        if line =~ /\Adply_msg\|/
          receive_message line
        else
          printf @job_output_template, id, line
        end
      end
    rescue EOFError,Errno::ECONNRESET, Errno::EPIPE, Errno::EIO => e
    end

    def popen(cmd, host_info)
      t = Thread.new do |t|
        Thread.current[:messages] = []
        begin
          r, w, pid = PTY.spawn(cmd)
          pty_read(r, host_info[:id])
          exit_status pid
        ensure
          @mq << true
        end
      end
      t.abort_on_exception = true
      t.run
      return t
    end

    def host_id_max_width
      hosts.map {|h| h[:id].size }.max
    end

    def job_output_template
      @job_output_template ||= begin
        id_template = "%-#{host_id_max_width}s".bold.grey
        template = "#{id_template}  %s"
      end
    end

    def receive_message(msg_str)
      msg = msg_str.partition("|")[2].strip
      return if msg.empty?
      messages = Thread.current[:messages]
      messages << msg
    end

    def report
      @report ||= Report.new(hosts, exit_statuses, messages)
    end

    def messages
      @messages ||= begin
        m = {}
        @threads.each do |host, thread|
          m[host] = thread[:messages]
        end
        m
      end
    end

    def exit_statuses
      return @exit_statuses if @exit_statuses
      @exit_statuses = {}
      @threads.each do |host, thread|
        @exit_statuses[host] = thread.value
      end
      @exit_statuses
    end

    def exit_status(pid)
      pid, status = Process.waitpid2(pid)
      return status
    end

  end
end
