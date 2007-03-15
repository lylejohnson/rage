module RAGE
  
  module MessageHelper
    
    # Send an agree message in response to this message
    def agree_to(previous_msg)
      msg = previous_msg.create_reply
      msg.performative = "agree"
      msg.sender = aid
      send_message(msg)
    end
    
    # Send an inform message
    def inform(previous_msg)
      msg = previous_msg.create_reply
      msg.performative = "inform"
      msg.sender = aid
      send_message(msg)
    end

  end # module MessageHelper
  
end # module RAGE
