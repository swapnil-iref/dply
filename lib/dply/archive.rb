require 'dply/helper'
require 'uri'
module Dply
  class Archive

    include Helper

    def initialize(url, verify_checksum: true)
      @url = url
      @verify_checksum = verify_checksum
    end

    def extract_to(extraction_path)
      download_file if not @downloaded
      FileUtils.rm_rf extraction_path if File.exists? extraction_path
      FileUtils.mkdir_p extraction_path
      cmd "tar xf #{path} -C #{extraction_path}", display: true
    end

    def clean
      logger.trace "cleaning cache"
      files = [ "tmp/cache/#{name}", "tmp/cache/#{name}.md5" ]
      files.each { |f| FileUtils.rm f if File.exists? f }
    end
    private

    def download_file
      if File.exists? path
        download if not verify_checksum
      else
        download(uri, path)
      end
      raise if not verify_checksum
      @downloaded = true
    end
    
    def uri
      @uri ||= URI.parse(@url)
    end

    def name
      @name ||= File.basename(uri.path)
    end

    def path
      @path = "tmp/cache/#{name}"
    end

    def checksum
      @checksum ||= load_checksum
    end

    def load_checksum
      file = "tmp/cache/#{name}.md5"
      if File.exists? file
        checksum = File.read(file).chomp
        return checksum if checksum.size == 32
      end
      download("#{uri}.md5", file)
      checksum = File.read(file).chomp
      raise if checksum.size != 32
      return checksum
    end

    def verify_checksum
      return true if not @verify_checksum
      require 'digest'
      computed_checksum = Digest::MD5.file path
      computed_checksum == checksum
    end

    def download(url, outfile)
      logger.bullet "downloading #{url} to #{outfile}"
      http_status = `curl -w "%{http_code}" -f -s -o '#{outfile}' '#{url}' `
      if http_status != "200"
        error "failed to download #{outfile}, http status #{http_status}"
      end
    end
  
  end
end
