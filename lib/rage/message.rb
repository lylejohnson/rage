require 'rage/aid'
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
    # The _sender_ denotes the identity of the sender of the message, i.e.
    # the name of the agent of the communicative act.
    #
    attr_accessor :sender
    
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
    attr_accessor :conversation_id
    attr_accessor :reply_with
    attr_accessor :in_reply_to
    attr_accessor :reply_by

    #
    # Return an initialized Message instance.
    #
    def initialize
      @performative = nil
      @receivers = []
      @sender = nil
      @reply_to = []
      @content = nil
      @language = nil
      @encoding = nil
      @ontology = nil
      @protocol = nil
      @conversation_id = nil
      @reply_with = nil
      @in_reply_to = nil
      @reply_by = nil
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
    
  end # class Message
  
end # module RAGE

