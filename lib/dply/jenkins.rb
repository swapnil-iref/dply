require 'open-uri'
require 'json'
require 'dply/helper'

module Dply
  class Jenkins

    include Helper

    def initialize(url, project)
      @url = URI.parse(url)
      @project = project
      validate
    end

    def latest_successful_revision
      api_url = "#{@url}/job/#{@project}/api/json"
      logger.debug "using jenkins api \"#{api_url}\""
      open(api_url) do |f|
        json = JSON.parse(f.read)
        revision = json["lastSuccessfulBuild"]["number"]
        logger.debug "got revision #{revision}"
        revision
      end
    end

    def validate
      raise "invalid uri " if not ["http", "https"].include? @url.scheme
      raise "project name not defined" if not @project
    end
  end
end
