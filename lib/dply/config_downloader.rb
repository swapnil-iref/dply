require 'dply/helper'
module Dply
  class ConfigDownloader

    include Helper
    attr_accessor :base_url, :config_files, :config_skip_download

    def initialize(config_files , base_url, secret: nil, config_skip_download: [])
      @config_files = config_files
      @base_url = base_url
      @secret = secret
      @config_skip_download = config_skip_download
    end

    def download_all
      config_files.each do |f|
        if config_skip_download.include? f
          logger.debug "skipping to download file #{f}"
          next
        end
        download f
      end
    end

    def download(file)
      url = "#{base_url}/#{file}"
      logger.bullet "downloading #{file}"
      http_status = `curl -w "%{http_code}" -f -s -o 'config/#{file}' '#{url}' `
      if http_status != "200"
        raise error "failed to download #{file}, http status #{http_status}"
      end
    end

  end
end
