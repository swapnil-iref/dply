require 'dply/helper'
require 'fileutils'
require 'dply/curl'

module Dply
  class ConfigDownloader

    include Helper
    attr_writer :skip_download

    def initialize(config_files , base_url)
      @config_files = config_files
      @base_url = base_url
      @skip_download = []
    end

    def download_all
      init_tmpdir
      @config_files.each do |f|
        if @skip_download.include? f
          logger.debug "skipping to download file #{f}"
          next
        end
        curl.download f, "config/#{f}"
      end
    end

    private

    def curl
      @curl ||= Curl.new
    end

  end
end
