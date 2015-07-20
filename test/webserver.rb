require 'webrick'
class ::WEBrick::BasicLog
  def log(level, data)
    # nop
  end
end
port = 8000
webserver = Thread.new do
  WEBrick::HTTPServer.new(
    :Port => port, 
    :DocumentRoot => "#{Dir.pwd}/test/sample_data", 
    Logger: WEBrick::Log.new("/dev/null"),
    AccessLog: []
  ).start
end
puts "staring webserver on port #{port}"
webserver.run

at_exit { Thread.kill webserver }
 
