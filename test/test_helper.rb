require_relative 'webserver'
require 'minitest/reporters'
require 'minitest/autorun'

class Minitest::Test

  def self.test(name, &block)
    method_name = "test_: #{name}".to_sym
    define_method method_name, &block
  end

end

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require 'fileutils'
FileUtils.mkdir_p "tmp/archive"
