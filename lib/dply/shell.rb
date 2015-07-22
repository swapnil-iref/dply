require 'dply/error'
require 'dply/logger'

module Dply
  module Shell

    include Logger

    def cmd(command, display: true, error_msg: nil, return_output: false, env:{})
      stringify_values(env)
      if display
        logger.bullet command
      else
        logger.debug command
      end
      command_arr = command.split

      if return_output
        output = IO.popen(env, command_arr) { |f| f.read }
      else
        output = ""
        system(env, *command_arr, 2 => 1)
      end 
      return_value = $?.exitstatus
      error_msg ||= "non zero exit for \"#{command}\""
      raise ::Dply::Error, error_msg if return_value !=0 
      return output
    end 

    def symlink(src, dst)
      if File.symlink? dst
        FileUtils.rm dst
        FileUtils.ln_s src, dst
      elsif File.exist? dst
        raise "cannot create symlink #{dst} => #{src}"
      else
        FileUtils.ln_s src, dst
      end
    end

    def symlink_in_dir(src,destdir)
      if not Dir.exist? destdir
        raise "symlink destination not a dir"
      end
      src_path = Pathname.new(src)
      dst = "#{destdir}/#{src_path.basename}"
      symlink src, dst
    end

    def stringify_values(hash)
      hash.each do |k,v|
        hash[k] = v.to_s
      end
    end

  end
end
