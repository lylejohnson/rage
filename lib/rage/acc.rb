require 'drb'
require 'uri'

# Disable eval() and friends
$SAFE = 1

module RAGE
  
  # A reference to the platform logger
  attr_reader :logger
  
  # A reference to the platform AMS
  attr_reader :ams

  class AgentCommunicationChannel

    #
    # Return the initialized Agent Communication Channel (ACC)
    # for this Agent Platform.
    #
    def initialize(params={})
      @logger = params[:logger] || Logger.new(STDOUT)
      @ams = params[:ams]
    end
    
    #
    # Start a DRb server for this
    #
    def start
      DRb.start_service("druby://localhost:9001", self)
    end
    
    def stop
      DRb.thread.join
    end

    #
    # Send the following envelope and payload
    #
    def send_message(envelope, payload)
      
      # FIXME: Mark as received by this ACC
      envelope.mark_as_received(:by => nil, :from => nil, :date => nil, :id => nil, :via => nil)

      # Build envelopes for all intended receivers
      envelopes = []
      if envelope.intended_receiver.nil?
        envelope.each_receiver do |receiver|
          new_envelope = envelope.dup
          new_envelope.intended_receiver = receiver
          envelopes << new_envelope
        end
      else
        envelopes << envelope
      end
      
      # Forward message to intended receiver(s)
      envelopes.each do |envelope|

        # Is the intended receiver a local agent?
        agent = ams.agent_for_name(envelope.intended_receiver)
        if agent
          agent.post_message(envelope, payload)
        else

          envelope.intended_receiver.addresses.each do |address|
            # FIXME: Try to deliver the message to this address
            mtp = create_mtp_for(address)
          end

          # If we couldn't deliver it to any of the transport addresses,
          # try the name resolution services.
          envelope.intended_receiver.resolvers.each do |resolver|
            # FIXME: Try to resolve the AID (i.e. the intended_receiver) using this name resolution service
          end

          # Still no luck -- pass an appropriate error message back to
          # the sending agent. (FIXME)
        end

      end
      
    end
    
    #
    # Return a suitable Message Transport Protocol (MTP) for the
    # given transport address.
    #
    def create_mtp_for(address)
      uri = URI.parse(address)
      case uri.scheme
      when "druby"
        DRbTransportProtocol.new(uri)
      else
        raise RuntimeError, "unsupported MTP scheme (#{address})"
      end
    end

  end # class AgentCommunicationChannel
  
  class DRbTransportProtocol

    def initialize(uri)
      @server = DRbObject.new(nil, uri)
    end
    
    def send_message(envelope, payload)
      @server.send_message(envelope, payload)
    end

  end # class DRbTransportProtocol
  
end # module RAGE
