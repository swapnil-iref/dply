require 'dply/helper'
require 'dply/curl'
require 'uri'
require 'tmpdir'

module Dply
  class Archive

    include Helper

    attr_reader :name, :path, :checksum_path, :uri

    def initialize(url, verify_checksum: true)
      @uri = URI.parse url
      @verify_checksum = verify_checksum
      @name = File.basename(uri.path)
      @path = "tmp/archive/#{name}"
      @checksum_path = "tmp/archive/#{name}.md5"
    end

    def extract(&block)
      download_file
      Dir.mktmpdir "tmp", "./" do |d|
        extracted = "#{d}/extracted"
        FileUtils.mkdir extracted
        cmd "tar xf #{path} -C #{extracted}", display: true
        yield extracted
      end
      cleanup
    end

    private

    def cleanup
      logger.trace "cleaning tmp/archive"
      files = [ path, checksum_path ]
      files.each { |f| FileUtils.rm f if File.exists? f }
    end

    def download_file
      curl.download(uri, path)
      if @verify_checksum
        download_checksum
        error "checksum doesn't match for archive" if not checksum_matches?
      end
    end

    def download_checksum
      curl.download("#{uri}.md5", checksum_path)
    end

    def checksum
      File.read(checksum_path).chomp
    end

    def checksum_matches?
      require 'digest'
      computed_checksum = Digest::MD5.file path
      computed_checksum == checksum
    end

    def curl
      @curl ||= Curl.new
    end

  end
end
