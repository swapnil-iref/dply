require 'dplyr/report'
require 'dply/logger'
require 'dplyr/remote_task'

module Dplyr
  class TaskRunner

    include ::Dply::Logger
    
    attr_reader :hosts, :parallel_jobs, :task, :messages, :exit_statuses
    attr_writer :auto_serialize

    def initialize(hosts, task, parallel_jobs: 1)
      @hosts = hosts
      @parallel_jobs = parallel_jobs
      @task = task

      @messages = {}
      @exit_statuses = {}
      @auto_serialize = true
    end

    def run
      if parallel_jobs > 1 && hosts.count > 1
        run_in_parallel
      else
        run_serially
      end
      report.print_full
    end

    def run_serially
      hosts.each do |host|
        task = execute_serially host
        break if task.exit_status != 0 
      end
    end

    def run_in_parallel
      if @auto_serialize
        t = execute_serially hosts[0]
        return if t.exit_status != 0
        execute_in_parallel Range.new(1,hosts.size - 1)
      else
        execute_in_parallel Range.new(0, hosts.size - 1)
      end
    end

    private 

    def remote_task(host)
      RemoteTask.new(host, @task, id_size: host_id_max_width)
    end

    def execute_serially(host)
      task = remote_task host
      task.run
      @exit_statuses[host] = task.exit_status
      @messages[host] = task.messages
      return task
    end

    def execute_in_parallel(range)
      init_run
      queue_hosts range
      parallel_jobs.times do
        spawn_queued_job
      end
      loop do
        break if @queue.empty?
        @mq.pop
        spawn_queued_job
      end
      wait_for_threads
    end

    def start_task_thread(host)
      t = Thread.new do
        Thread.current[:messages] = []
        task = remote_task(host)
        begin
          task.run
          Thread.current[:messages] = task.messages
          Thread.current[:exit_status] = task.exit_status
        rescue => e
          puts e.message
        ensure
          @mq << true
        end
      end
      t.abort_on_exception = true
      t.run
      @threads[host] = t
    end

    def init_run
      @mq = Queue.new
      @queue = Queue.new
      @threads = {}
    end

    def queue_hosts(range)
      range.each { |i| @queue << hosts[i] }
    end

    def spawn_queued_job
      return if @queue.empty?
      host = @queue.pop(false)
      start_task_thread host
    rescue ThreadError
    end

    def host_id_max_width
      @host_id_max_width ||= hosts.map {|h| h[:id].size }.max
    end

    def report
      @report ||= Report.new(hosts, exit_statuses, messages)
    end

    def wait_for_threads
      @threads.each do |host, t|
        @exit_statuses[host] = t.value
        @messages[host] = t[:messages]
      end
    end

  end
end
