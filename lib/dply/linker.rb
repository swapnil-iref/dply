require 'dply/helper'
module Dply
  class Linker

    include Helper

    attr_reader :src_dir, :dest_dir, :map

    def initialize(src_dir, dest_dir, map: {})
      verify_absolute src_dir, dest_dir
      @src_dir = src_dir
      @dest_dir = dest_dir
      @map = map
    end
    
    def create_symlinks
      mapped_files.each do |f|
        target = link_target(f)
        source = link_source(f)
        relative_source = link_relative_source(source, target)
        logger.debug "linking #{target} -> #{source}"
        symlink(relative_source, target)
      end
    end

    def link_target(relative_target)
      Pathname.new "#{dest_dir}/#{relative_target}"
    end

    def link_source(relative_target)
      relative_source = map[relative_target]
      Pathname.new "#{src_dir}/#{relative_source}"
    end

    def link_relative_source(source, target)
      source.relative_path_from target.parent
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
