require 'dply/helper'

module Dply
  class Rpm
    include Helper

    def libs_to_packages(libs)
      packages = Set.new
      libs.each do |l|
        list = whatprovides(l)
        packages << list if not list.empty?
      end
      return packages
    end

    def filtered?(pkg)
      @filtered ||= ["glibc", "libgcc", "libstdc++", "openssl", "ruby-alt", "jemalloc"]
      @filtered.include? pkg.strip
    end

    def whatprovides(lib)
      lib = "#{lib}()(64bit)"
      command = %(rpm --queryformat "%{NAME} " -q --whatprovides "#{lib}")
      logger.debug command
      output = `#{command}`
      error "running command #{command}" if not $?.exitstatus == 0
      list = output.strip.split.select {|pkg| not filtered? pkg }
    end

  end
end
