require 'test_helper'
require 'dply/archive'

module Dply
  class ArchiveTest < Minitest::Test
    def setup
      url = "http://127.0.0.1:8000/build.tar.gz"
      @name = "build.tar.gz"
      @path = "tmp/archive/build.tar.gz"
      @checksum_path = "tmp/archive/build.tar.gz.md5"
      @archive = Archive.new(url, verify_checksum: true)
    end

    def teardown
      @archive = nil
    end

    test "#new" do
      assert_equal @archive.name, @name
      assert_equal @archive.path, @path
      assert_equal @archive.checksum_path, @checksum_path
    end

    test ".extract" do
      @archive.extract do |d|
        assert File.exist? "#{d}/code"
      end
      [@path, @checksum_path].each do |f|
        refute File.exist?(f), msg: "cache file not deleted #{f}"
      end
    end

  end
end
