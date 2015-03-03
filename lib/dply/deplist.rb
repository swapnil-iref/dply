require 'filemagic'
require 'elf'
require 'dply/helper'
require 'dply/rpm'
require 'tmpdir'

module Dply
  class Deplist

    include Helper

    def initialize(path)
      @path = path
    end

    def deps
      @deps ||= load_deps
    end

    def verify!(pkgs_list)
      deps.each do |pkgs|
        if not pkgs.any? { |pkg| pkgs_list.include? pkg }
          logger.error "missing from pkgs.yml : any of #{pkgs}"
          @error = true
        end
      end
      error "packages dependencies not satisfied" if @error
      puts "all dependencies satisfied".green
    end

    private

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

    def load_deps
      error "#{@path} not readable" if not File.readable? @path
      tmp_dir do
        logger.info "(in #{Dir.pwd})"
        cmd "tar xf #{@path}"
        @libs = get_libs
        logger.debug @libs.inspect
        @deps = rpm.libs_to_packages @libs
      end
    end

    def tmp_dir(&block)
      dir = File.exist?("tmp") ? "tmp" : "/tmp"
      Dir.mktmpdir(nil, dir) do |d|
        Dir.chdir(d) { yield }
      end
    end

    def get_libs
      libs = Set.new
      Dir["./**/*"].each do |f|
        type = magic.file(f)
        if type =~ /ELF/
          dynamic_libs(f).each { |k| libs << k }
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
