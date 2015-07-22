require 'test_helper'
require 'dply/curl'
require 'tmpdir'

module Dply
  class CurlTest < Minitest::Test

    def url
      @url ||= "http://127.0.0.1:8000/build.tar.gz"
    end

    test "#download" do

      Dir.mktmpdir do |dir|
        f = "#{dir}/f"
        curl = Curl.new
        curl.download(url, f)
        assert File.exist? f
      end
    end


  end
end
