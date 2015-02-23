require 'dply/helper'
require 'uri'
module Dply
  class Archive

    include Helper

    def initialize(url)
      @url = url
      @verify_checksum = true
    end

    def extract_to(extraction_path)
      download if not @downloaded
      cmd "tar xf #{path} #{extraction_path}", display: true
    end

    private

    def download
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
      file = "tmp/cache/#{tar_name}.md5"
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
      require 'digest'
      computed_checksum = Digest::MD5.file path
      computed_checksum == checksum
    end

    def download(url, outfile)
      logger.bullet "downloading #{url} to #{outfile}"
      http_status = `curl -w "%{http_code}" -f -s -o 'config/#{outfile}' '#{url}' `
      if http_status != "200"
        raise error "failed to download #{outfile}, http status #{http_status}"
      end
    end
  
  end
end
