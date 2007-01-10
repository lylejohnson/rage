module RAGE
  
  class AgentCommunicationChannel
    
    def send_message(envelope, payload)
      
      if envelope.intended_receivers.empty?
        # generate intended receiver(s) from receiver(s)
      end
      
      # before forwarding the message, add a completed 'received' parameter to the message envelope
      
      envelope.each_intended_receiver do |receiver|
      end
      
    end

  end # class AgentCommunicationChannel
  
end # module RAGE