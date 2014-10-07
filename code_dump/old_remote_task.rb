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
      if parallel_jobs > 1
        run_in_parallel
      else
        run_serially
      end
    end

    def run_in_parallel
      init_run
      hosts_iterator = hosts.to_enum
      spawn_jobs(hosts_iterator, parallel_jobs)
      loop do
        break if @io_objects.empty?
        r,w = IO.select(@io_objects)
        r.each do |stream|
          eof_reached = handle_ready_stream stream
          spawn_jobs(hosts_iterator, 1) if eof_reached
        end
      end
      print_summary
    end

    def run_serially
      hosts.each do |host_info|
        puts "=== Running on #{host_info[:id]} ==="
        run_cmd = remote_cmd host_info
        system run_cmd
        puts "=== end ==="
        puts 
        raise ::Dply::Error, "remote deploy failed on #{host_info[:id]}" if $? != 0
      end
    end

    private

    def init_run
      @io_objects = []
      @io_names = {}
      @exit_statuses = {}
      @hosts_exhausted = false
      job_output_template
    end

    def spawn_job(host_info)
      run_cmd = remote_cmd host_info
      popen(run_cmd, host_info)
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

    def remote_cmd(host_info)
      user = host_info[:user]
      host = host_info[:host]
      deploy_dir = host_info[:deploy_dir]
      %(ssh -tt -oBatchMode=yes -l #{user} #{host} "dply -d #{deploy_dir} #{task} 2>&1")
    end

    def handle_ready_stream(stream)
      host_string = "#{@io_names[stream]}"
      printf @job_output_template, host_string, stream.readline
      return false
    rescue EOFError,Errno::ECONNRESET, Errno::EPIPE, Errno::EIO => e
      @io_objects.delete(stream)
      return true
    end

    def print_summary
      total_jobs = hosts.count
      run_count = @exit_statuses.count
      not_run = total_jobs - run_count
      failed = @exit_statuses.values.select { |v| v !=0 }.count
      successful = @exit_statuses.values.select { |v| v == 0 }.count
      puts "--------"
      puts "Summary"
      puts "--------"
      puts "Succeeded: "
      
      total_jobs = @exit_statuses.count
      failed = 0
      @exit_statuses.each do |host_info, status|
        exit_status = status.exitstatus
        if exit_status == 0
          puts "#{"success".green} #{host_info[:id]} "
        else
          puts "#{"failed ".red} #{host_info[:id]}"
          failed +=1
        end
      end
      if failed > 0
        puts "-------"
        raise ::Dply::Error, "#{failed}/#{total_jobs} jobs failed" if failed > 0
      end
    end

    def popen(cmd, host_info)
      r, w, pid = PTY.spawn(cmd)
      @io_objects << r 
      @io_names[r] = host_info[:id]
      wait_thread host_info, pid
    rescue PTY::ChildExited => e
      @exit_statuses[host_info] = e.status
    end

    def wait_thread(host_info, pid)
      t = Thread.new do
        pid, status = Process.waitpid2(pid)
        @exit_statuses[host_info] = status
      end
      t.abort_on_exception = true
      t.run
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

  end
end
