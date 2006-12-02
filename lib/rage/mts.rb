require 'net/http'
require 'singleton'

module RAGE

  class MessageTransportSystem

    include Singleton

    #
    # Return an initialized MessageTransportSystem instance.
    #
    def initialize
    end

    #
    # Send a message using the HTTP transport.
    #
    def send(msg)
      path = "/"
      data = ""
      header = {
        "Content-Type"  => "multipart/mixed",
        "Host"          => "hostname:80",
        "Cache-Control" => "no-cache",
        "MIME-Version"  => "1.0"
      }
      msg.each_receiver do |recv|
        Net::HTTP.start(recv.address) do |http|
          response = http.post(path, data, header)
        end
      end
    end
    
  end # class MessageTransportSystem
  
end # module RAGE

