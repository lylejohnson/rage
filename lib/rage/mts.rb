require 'rage/ams'

require 'logger'
require 'net/http'

module RAGE

  class MessageTransportSystem

    # A reference to the platform logger
    attr_reader :logger
    
    # A reference to the platform AMS
    attr_reader :ams

    #
    # Return an initialized MessageTransportSystem instance.
    #
    def initialize(params={})
      @logger = params[:logger] || Logger.new(STDOUT)
      @ams = params[:ams]
    end

    def send_message(msg)
      logger.info "Received message: #{msg}"
      msg.receivers.each do |receiver|
        agent = ams.agent_for_name(receiver)
        if agent
          agent.post_message(msg)
        else
          # No such agent is registered with the AMS?
        end
      end
    end
    
  end # class MessageTransportSystem
  
end # module RAGE

