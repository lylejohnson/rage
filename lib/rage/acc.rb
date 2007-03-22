require 'thread'
require 'uri'

# Disable eval() and friends
$SAFE = 1

module RAGE
  
  # A reference to the platform logger
  attr_reader :logger
  
  # A reference to the platform AMS
  attr_reader :ams

  class AgentCommunicationChannel

    # Returns a reference to the Agent Management System (AMS) for this platform
    attr_reader :ams

    #
    # Return the initialized Agent Communication Channel (ACC)
    # for this Agent Platform.
    #
    def initialize(params={})
      @logger = params[:logger] || Logger.new(STDOUT)
      @ams = params[:ams]
      @buffered_messages = []
      @mutex = Mutex.new
    end
    
    #
    # Send the following envelope and payload
    #
    def send_message(envelope, payload)
      
      # FIXME: Mark as received by this ACC
      envelope.mark_as_received(:by => nil, :from => nil, :date => Time.now, :id => nil, :via => nil)

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

          if agent.active?
            agent.post_message(envelope, payload)
          else
            buffer_message(envelope, payload)
          end

        else

          envelope.intended_receiver.addresses.each do |address|
            # FIXME: Try to deliver the message to this address
            mtp = create_mtp_for(address)
            if mtp
              mtp.send_message(envelope, payload)
              return
            end
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
    # Buffer a message for an agent that is currently inactive.
    # FIXME: Add a thread to empty the buffer!
    #
    def buffer_message(envelope, payload)
      @mutex.synchronize do
        @buffered_messages << [envelope, payload]
      end
      if @buffer_emptier_thread.nil?
        @buffer_emptier_thread = Thread.new { empty_message_buffer }
      end
    end
    
    def empty_message_buffer
      loop do
        messages = nil
        @mutex.synchronize do
          messages = @buffered_messages.dup
        end
        delivered_messages = []
        messages.each do |msg|
          envelope, payload = *msg
          agent = ams.agent_for_name(envelope.intended_receiver)
          if agent
            if agent.active?
              agent.post_message(envelope, payload)
              delivered_messages << msg
            end
          else
            # FIXME: Intended receiver is no longer registered with this AMS?
          end
        end
        @mutex.synchronize do
          delivered_messages.each do |msg|
            @buffered_messages.remove(msg)
          end
        end
        sleep 5 # FIXME: How to make this a low priority thread?
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
      @container = DRbObject.new(nil, uri)
    end
    
    def send_message(envelope, payload)
      @container.acc.send_message(envelope, payload)
    end

  end # class DRbTransportProtocol
  
end # module RAGE
