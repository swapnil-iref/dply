require 'dply/helper'
module Dply
  class ConfigDownloader

    include Helper
    attr_writer :config_skip_download

    def initialize(config_files , base_url)
      @config_files = config_files
      @base_url = base_url
    end

    def download_all
      @config_files.each do |f|
        if config_skip_download.include? f
          logger.debug "skipping to download file #{f}"
          next
        end
        download f
      end
    end

    private

    def download(file)
      url = "#{@base_url}/#{file}"
      logger.bullet "downloading #{file}"
      http_status = `curl -w "%{http_code}" -f -s -o 'config/#{file}' '#{url}' `
      if http_status != "200"
        raise error "failed to download #{file}, http status #{http_status}"
      end
    end


    def config_skip_download
      @config_skip_download ||= []
    end

  end
end
