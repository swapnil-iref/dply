require 'filemagic'
require 'elf'
require 'dply/helper'
require 'dply/rpm'
require 'dply/pkgs'
require 'tmpdir'

module Dply
  class Deplist

    include Helper

    def initialize(path)
      if Pathname.new(path).relative?
        @path = "#{Dir.pwd}/#{path}"
      else
        @path = path
      end
    end

    def verify!
      error "#{@path} not readable" if not File.readable? @path
      tmp_dir do
        logger.info "(in #{Dir.pwd})"
        cmd "tar xf #{@path}"
        pkgs_list = Pkgs.new.runtime

        @libs_files_map = libs_files_map
        libs = @libs_files_map.keys

        deps = rpm.libs_packages_map libs
        verify_deps(deps, pkgs_list)
      end
    end

    private

    def verify_deps(deps, pkgs_list)
      deps.each do |lib, pkgs|
        if not pkgs.any? { |pkg| pkgs_list.include? pkg }
          logger.error "missing from pkgs.yml : any of #{pkgs} (lib: #{lib}, files: #{@libs_files_map[lib]})"
          @error = true
        end
      end
      error "packages dependencies not satisfied" if @error
      puts "all dependencies satisfied".green
    end

    def magic
      @magic ||= begin
        flags = FileMagic::FLAGS_BY_SYM.select { |k,v| k.to_s =~ /no_check_/ }.keys
        not_required_flags = [:no_check_soft, :no_check_elf, :no_check_builtin]
        not_required_flags.each {|x| flags.delete(x) }
        fm = FileMagic.new
        fm.flags = flags
        fm
      end
    end

    def tmp_dir(&block)
      dir = File.exist?("tmp") ? "tmp" : "/tmp"
      Dir.mktmpdir(nil, dir) do |d|
        Dir.chdir(d) { yield }
      end
    end

    def libs_files_map
      libs = {}
      Dir["./**/*"].each do |f|
        type = magic.file(f)
        next if not type =~ /ELF/
        dynamic_libs(f).each do |l|
          libs[l] ||= []
          libs[l] << f
        end
      end
      return libs
    end

    def dynamic_libs(file)
      Elf::File.open(file) do |ef|
        return [] if not ef.has_section? ".dynamic"
        ef[".dynamic"].needed_libraries.keys
      end
    rescue Exception
      return []
    end

    def rpm
      @rpm ||= Rpm.new
    end

  end
end
