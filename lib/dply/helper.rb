require 'dply/error'
require 'dply/logger'
require 'fileutils'
require 'tmpdir'

module Dply
  module Helper

    def cmd(command, display: true, error_msg: nil, return_output: false, env:{}, shell: false)
      if command.is_a? Array
        command_arr = command
        command_str = command.join(" ")
      else
        command_arr = command.split
        command_str = command
      end
      stringify_values!(env)
      if display
        logger.bullet command_str
      else
        logger.debug command_str
      end

      run_command = shell ? command_str : command_arr
      output = if return_output
        IO.popen(env, run_command) { |f| f.read }
      else
        system(env, *run_command, 2 => 1)
      end
      return_value = $?.exitstatus
      error_msg ||= "non zero exit for \"#{command_str}\""
      error error_msg if return_value != 0
      return output
    end

    def symlink(src, dst)
      if File.symlink? dst
        Dir.mktmpdir("sym-", "./") do |d|
          dst_tmp = "#{d}/#{File.basename dst}"
          FileUtils.ln_s src, dst_tmp
          cmd "mv #{dst_tmp} #{File.dirname dst}", display: false
        end
      elsif File.exist? dst
        error "cannot create symlink #{dst} => #{src}"
      else
        FileUtils.ln_s src, dst
      end
    end

    def stringify_values!(hash)
      hash.each do |k,v|
        hash[k] = v.to_s
      end
    end

    def logger
      Logger.logger
    end

    def git
      Git
    end

    def error(msg)
      raise ::Dply::Error, msg
    end

  end
end
