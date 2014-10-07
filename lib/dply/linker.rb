require 'dply/helper'
module Dply
  class Linker

    include Helper

    attr_reader :src_dir, :dest_dir, :map, :dir_prefix

    def initialize(src_dir, dest_dir, map: nil, dir_prefix: nil)
      verify_absolute src_dir, dest_dir
      @src_dir = src_dir
      @dest_dir = dest_dir
      @map = map
      @dir_prefix = dir_prefix
    end
    
    def create_symlinks
      files.each do |f|
        link_target = link_target(f)
        absolute_source_path = absolute_source_path(f)
        relative_path = absolute_source_path.relative_path_from link_target.parent
        logger.debug "linking #{link_target} -> #{absolute_source_path}"
        symlink(relative_path, link_target)
      end
    end

    def files
      @map ? mapped_files : all_files
    end

    def map
      @map || default_map
    end

    def link_target(relative_source)
      target = map[relative_source]
      Pathname.new "#{dest_dir}/#{target}"
    end

    def absolute_source_path(src)
      Pathname.new "#{src_dir}/#{src}"
    end


    def default_map
      @h ||= Hash.new do |hash, key|
        dir_prefix ? "#{dir_prefix}/#{key}" : "#{key}"
      end
    end

    def all_files
      Dir.chdir(src_dir) { Dir.glob("*") }
    end
    
    def mapped_files
      map.keys.collect do |k|
        path = Pathname.new k 
        raise "config map path cannot be absoulte" if path.absolute?
        k
      end
    end

    def verify_absolute(*paths)
      paths.each do |path|
        absolute = Pathname.new(path).absolute?
        raise "#{path} not absolute" if not absolute
      end
    end

  end
end
