require 'dply/helper'
require 'fileutils'
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
        download f
        FileUtils.mv "#{tmpdir}/#{f}", "config/#{f}"
      end
    end

    private

    def download(file)
      url = "#{@base_url}/#{file}"
      logger.bullet "downloading #{file}"
      http_status = `curl -w "%{http_code}" -f -s -o '#{tmpdir}/#{file}' '#{url}' `
      exitstatus = $?.exitstatus
      if (http_status != "200"  || exitstatus != 0 )
        error "failed to download #{file}, http status #{http_status}, exitstatus #{exitstatus}"
      end
    end

    def tmpdir
      @tmpdir ||= "tmp/config_dl"
    end

    def init_tmpdir
      if File.exists? tmpdir
        FileUtils.rm_rf tmpdir
      end
      FileUtils.mkdir_p tmpdir
    end

  end
end
