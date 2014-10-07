require 'open3'
require 'pty'
module Dply
  class RemoteTask
    
    attr_reader :hosts, :parallel_jobs, :task

    def initialize(hosts, task, parallel_jobs: 1)
      @hosts = hosts
      @parallel_jobs = parallel_jobs
      @task = task
    end

    def run
      init_run
      @hosts_iterator = hosts.to_enum
      spawn_jobs(@hosts_iterator, parallel_jobs)
#      loop do
#        break if @io_objects.empty?
#        r,w = IO.select(@io_objects)
#        r.each do |stream|
#          eof_reached = handle_ready_stream stream
#          spawn_jobs(hosts_iterator, 1) if eof_reached
#        end
#      end
      print_summary
    end

    private

    def init_run
      @io_objects = []
      @io_names = {}
      @wait_threads = {}
      @hosts_exhausted = false
      @failed_jobs = []
      @successful_jobs = []
    end

    def spawn_job(host_info)
      user = host_info[:user]
      host = host_info[:host]
      deploy_dir = host_info[:deploy_dir]
      run_cmd = %(ssh -tt -oBatchMode=yes -l #{user} #{host} "#{cmd} -d #{deploy_dir} #{task} 2>&1")
      popen(run_cmd, host_info)
    #  stdin, stdout, wait_thr = Open3.popen2("ssh -tt -oBatchMode=yes  -l #{user} #{host} #{cmd} -d #{deploy_dir} #{task} 2>&1")
    #  @io_names[stdout] = host_info[:id]
    #  @wait_threads[host_info] = wait_thr
    #  @io_objects << stdout
    end

    def spawn_jobs(hosts_iterator, n)
      return if @hosts_exhausted
      n.times do
        host_info = hosts_iterator.next
        spawn_job(host_info)
      end
    rescue StopIteration
      @hosts_exhausted = true
    end

    def cmd
      "dply"
    end

    def handle_ready_stream(stream)
      begin
        host_string = "#{@io_names[stream]}".bold.grey
        puts "#{host_string} #{stream.readline}"
        return false
      rescue EOFError,Errno::ECONNRESET, Errno::EPIPE => e
        @io_objects.delete(stream)
        return true
      end
    end

    def print_summary
      puts "end"
      total_jobs = @wait_threads.count
      successful = 0
      @wait_threads.each do |host_info, thr|
        status = thr.value
        exit_status = status.exitstatus
        if exit_status == 0
          puts "success #{host_info}"
        else
          puts "failed #{host_info}"
        end
      end
    end

    def popen(cmd, host_info)
     Thread.abort_on_exception = true
     t = Thread.new do 
        begin
          puts "here"
          r, w, pid = PTY.spawn(cmd)
          host_string = "#{host_info[:id]}".bold.grey
          print_pty_output r, host_string
          pid, status = Process.waitpid2(pid)
          spawn_jobs(@hosts_iterator, 1)
          status
        rescue PTY::ChildExited => e
          puts "in errr"
          return e.status
        end
      end
      t.abort_on_exception = true
      @wait_threads[host_info] = t
      t.run
    end

    def print_pty_output(r, host_string)
      r.each { |line| puts "#{host_string} #{line}" }
    rescue Errno::EIO
    end

  end
end
