require 'logger'
require 'net/http'

module RAGE

  class MessageTransportSystem

    # A reference to the platform logger
    attr_reader :logger

    #
    # Return an initialized MessageTransportSystem instance.
    #
    def initialize(params={})
      @logger = params[:logger] || Logger.new(STDOUT)
    end

    #
    # Send a message using the HTTP transport.
    #
=begin
    def send_message(msg)
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
=end

    def send_message(msg)
      logger.info "MTS" do "Received message: #{msg.inspect}" end
    end
    
  end # class MessageTransportSystem
  
end # module RAGE

