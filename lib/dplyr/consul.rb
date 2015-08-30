require 'open-uri'
require 'json'
require 'dply/error'

module Dplyr
  class Consul

    def hosts(app_name, service: "app")
      uri = "http://127.0.0.1:8500/v1/catalog/service/#{service}?tag=#{app_name}"
      response = JSON.parse(open(uri).read)
      hosts = []
      response.each do |i|
        host = {}
        metadata_tag = i["ServiceTags"].find {|t| t =~ /\Ametadata:/}
        metadata = metadata_tag ? JSON.parse(metadata_tag.partition(":")[2]) : {}
        host[:user] = metadata["user"]
        host[:dir] = metadata["dir"]
        host[:addr] = i["Address"] 
        host[:id] = i["Node"]
        hosts << host
      end
      hosts
    rescue
      raise ::Dply::Error, "failed to load hosts from consul"
    end

  end
end
