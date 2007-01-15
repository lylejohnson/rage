require 'rage/ams'
require 'rage/envelope'

require 'logger'
require 'net/http'

module RAGE

  #
  # The Message Transport Service (MTS) is a service provided by the
  # Agent Platform (AP) to which an agent is attached. The MTS supports
  # the transportation of FIPA ACL messages between agents on any given
  # AP, and between agents on different APs.
  #
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
      envelope = make_envelope_for(msg)
      msg.receivers.each do |receiver|
        agent = ams.agent_for_name(receiver)
        if agent
          agent.post_message(msg)
        else
          # No such agent is registered with the AMS?
        end
      end
    end
    
    def make_envelope_for(msg)
      RAGE::Envelope.new()
    end
    
  end # class MessageTransportSystem
  
end # module RAGE

