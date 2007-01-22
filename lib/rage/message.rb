require 'rage/xmlcodec'

module RAGE

  class ReplyBy

    attr_reader :time
    attr_reader :url

    def initialize(tm, href)
      @time = tm
      @url = href
    end

  end # class ReplyBy

  #
  # Represents a FIPA ACL message.
  #
  class Message

  public

    #
    # The _performative_ denotes the type of the communicative act of the ACL
    # message. See FIPA00037 for a list of the FIPA standard performatives.
    #
    attr_accessor :performative
    
    #
    # The _sender_ (an AgentIdentifier instance) denotes the identity of the
    # sender of the message, i.e. the name of the agent of the communicative act.
    #
    attr_accessor :sender
    
    # Subsequent messages in this conversation thread are to be directed to this
    # agent (an AgentIdentifier) instead of the sender.
    attr_accessor :reply_to

    # The content of the message.
    attr_accessor :content
    
    # The language in which the _content_ is expressed; see FIPA00007.
    attr_accessor :language
    
    # The specific encoding of the content language expression (see FIPA00007).
    attr_accessor :encoding
    
    # The ontology(s) used to give a meaning to the symbols in the content expression.
    attr_accessor :ontology
    
    #
    # The interaction protocol that the sending agent is employing with this
    # ACL message (see FIPA00025).
    #
    attr_accessor :protocol
    
    # An expression (a conversation identifier) which is used to identify
    # the ongoing sequence of communicative acts that together form a conversation.
    attr_accessor :conversation_id
    
    # An expression that will be used by the responding agent to identify this message.
    attr_accessor :reply_with
    
    # An expression that references an earlier action to which this message is a reply.
    attr_accessor :in_reply_to
    
    # A time and/or date expression which indicates the latest time by which the sending
    # agent would like to receive a reply.
    attr_accessor :reply_by

    #
    # Return an initialized Message instance.
    #
    def initialize(params={})
      @performative = params[:performative]
      @sender = params[:sender]
      @reply_to = params[:reply_to] || []
      @content = params[:content]
      @language = params[:language]
      @encoding = params[:encoding]
      @ontology = params[:ontology]
      @protocol = params[:protocol]
      @conversation_id = params[:conversation_id]
      @reply_with = params[:reply_with]
      @in_reply_to = params[:in_reply_to]
      @reply_by = params[:reply_by]
      if params.key? :receiver
        @receivers = [ params[:receiver] ]
      else
        @receivers = params[:receivers] || []
      end
    end
    
    #
    # Return an array of the intended recipient(s) of the message.
    #
    def receivers
      @receivers
    end

    #
    # Iterate over the receiver(s) for this message.
    #
    def each_receiver(&blk) # :yields: anAID
      receivers.each(&blk)
    end

    #
    # Return the identity of the intended recipient of the message,
    # if there's only one.
    #
    def receiver
      unless receivers.empty?
        receivers.first
      else
        nil
      end
    end
    
    #
    # Set the intended recipient of the message to the agent indicated by the given AgentIdentifier
    #
    def receiver=(recv)
      @receivers = [recv]
    end
    
    #
    # Return an array of the agent(s) to reply to.
    # Subsequent messages in this conversation thread are to be directed to
    # these agent(s) instead of the _sender_.
    #
    def reply_to
      @reply_to
    end

    #
    # Iterate over the list of reply-to agent identifiers.
    #
    def each_reply_to(&blk) # :yields: anAID
      reply_to.each(&blk)
    end

    #
    # Return a new Message instance, with contents initialized
    # from a string containing XML.
    #
    def Message.from_xml(str)
      RAGE::XMLCodec.new.decode(str)
    end

    #
    # Return an XML document.
    #
    def to_xml
      RAGE::XMLCodec.new.encode(self)
    end
    
    #
    # Create a new message which is a reply to this one.
    # The new message's receiver will be initialized to this message's
    # sender, and the new message's in-reply-to slot will be initialized
    # to this message's reply-with value.
    #
    def create_reply
      msg = self.dup
      msg.performative = "agree"
      msg.receiver = msg.sender
      msg.sender = aid
      msg.in_reply_to = msg.reply_with
      msg
    end
    
  end # class Message
  
end # module RAGE

