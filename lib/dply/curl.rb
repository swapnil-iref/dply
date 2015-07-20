require 'dply/helper'
require 'fileutils'
require 'tmpdir'

module Dply
  class Curl

    include Helper

    def initialize(quiet = false)
      @quiet = quiet
    end

    def download(url, outfile)
      Dir.mktmpdir "tmp", "./" do |d|
        tmpfile = "#{d}/f"
        log "downloading #{url}"
        http_status = `curl -w "%{http_code}" -f -s -o '#{tmpfile}' '#{url}' `
        exit_status = $?.exitstatus
        if (http_status != "200" || exit_status != 0)
          error "failed to download #{outfile}, http status #{http_status}, exit_status #{exit_status}"
        end
        FileUtils.mv tmpfile, outfile
      end
    end

    private

    def log(msg)
      if @quiet
        logger.debug msg
      else
        logger.bullet msg
      end
    end

  end
end
