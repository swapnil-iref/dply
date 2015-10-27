require 'dply/helper'

module Dply
  class Rpm
    include Helper

    def libs_packages_map(libs)
      h = {}
      libs.each do |lib|
        list = whatprovides(lib)
        h[lib] = list if not list.empty?
      end
      return h
    end

    private

    def filtered?(pkg)
      @filtered ||= ["glibc", "libgcc", "libstdc++", "openssl", "ruby-alt", "jemalloc"]
      @filtered.include? pkg.strip
    end

    def whatprovides(lib)
      lib = "#{lib}()(64bit)"
      command = ["rpm", "--queryformat", "%{NAME} ", "-q", "--whatprovides", lib]
      output = cmd command, return_output: true, display: false
      list = output.strip.split.select {|pkg| not filtered? pkg }
    end

  end
end
