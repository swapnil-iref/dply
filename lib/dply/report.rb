module Dply
  class Report

    attr_reader :hosts, :exit_statuses 

    def initialize(hosts, exit_statuses)
      @hosts = hosts
      @exit_statuses = exit_statuses
    end


    def print_full
      print_successful_jobs
      print_failed_jobs
      print_summary
    end

    def succeeded
      @succeeded ||= exit_statuses.keys.select do |k|
        exit_statuses[k] == 0
      end
    end

    def failed
      @failed ||= exit_statuses.keys.select do |k|
        exit_statuses[k] != 0
      end
    end

    def print_successful_jobs
      puts "succeeded".green
      succeeded.each do |host|
        puts " - #{host[:id]}"
      end
    end

    def print_failed_jobs
      return if failed.count == 0
      puts "failed".red
      failed.each do |host|
        puts " - #{host[:id]}"
      end
    end


    def print_summary
      total_hosts = hosts.count
      run_count = @exit_statuses.count
      not_run = total_hosts - run_count
      if (failed.count > 0 || not_run > 0 )
        not_run_error = "not run on #{not_run}/#{total_hosts}" if not_run > 0
        failed_error = "failed on #{failed.count} of #{total_hosts} hosts" if failed.count > 0
       
        errors = []
        errors << not_run_error if not_run_error
        errors << failed_error if failed_error

        error_str = "task #{errors.join(", ")}"
        raise ::Dply::Error, error_str
      end
      puts "tasks ran successfully on #{succeeded.count}/#{total_hosts} hosts"
    end

  end
end
