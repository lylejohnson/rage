require 'rage/Message'
require 'rage/aid'
require 'rage/npreader'

module RAGE

  #
  # Instances of this class can be used to encode an Message object into
  # its string representation, as specified by the "FIPA ACL Message
  # Representation in String Specification" (SC00070I).
  #
  class StringCodec

    def decode_agent_identifier(node)
      node.values.shift # agent-identifier
      node.values.shift # :name
      name = node.values.shift
      addresses = []
      resolvers = []
      while !node.values.empty?
        key = node.values.shift
        case key
        when ":addresses"
          seq = node.values.shift
          seq.values.shift # sequence
          seq.values.each { |uri| addresses << uri }
        when ":resolvers"
          set = node.values.shift
          set.values.each { |v| resolvers << decode_agent_identifier(v) }
        default
          raise RuntimeError
        end
      end
      AgentIdentifier.new(
        :name => name,
        :addresses => addresses,
        :resolvers => resolvers
      )
    end

    private :decode_agent_identifier

    def decode(src)
      parser = NPReader.new
      ast = parser.parse(src)
      performative = ast.values.shift
      msg = Message.new(:performative => performative)
      while !ast.values.empty?
        key   = ast.values.shift
        value = ast.values.shift
        case key
        when ":sender"
          msg.sender = decode_agent_identifier(value)
        when ":receiver"
          value.values.shift # set
          value.values.each do |v|
            msg.receivers << decode_agent_identifier(v)
          end
        when ":content"
          msg.content = value
        when ":reply-with"
          msg.reply_with = value
        when ":reply-by"
          msg.reply_by = value
        when ":in-reply-to"
          msg.in_reply_to = value
        when ":reply-to"
          value.values.shift # set
          value.values.each do |v|
            msg.reply_to << decode_agent_identifier(v)
          end
        when ":language"
          msg.language = value
        when ":encoding"
          msg.encoding = value
        when ":ontology"
          msg.ontology = value
        when ":protocol"
          msg.protocol = value
        when ":conversation-id"
          msg.conversation_id = value
          default
          raise RuntimeError
        end
      end
      msg
    end

    def encode_agent_identifier(aid)
      str = "(agent-identifier :name #{aid.name}"
      unless aid.addresses.empty?
        str << " :addresses (sequence"
        aid.each_address do |address|
          str << " #{address}"
        end
        str << ")"
      end
      unless aid.resolvers.empty?
        str << " :resolvers (set"
        aid.each_resolver do |resolver|
          str << encode_agent_identifier(resolver)
        end
        str << ")"
      end
      str << ")"
    end

    private :encode_agent_identifier

    def encode(msg)
      str = "(#{msg.performative}"
      str << " :sender " << encode_agent_identifier(msg.sender)
      unless msg.receivers.empty?
        str << " :receiver (set"
        msg.each_receiver do |receiver|
          str << " #{encode_agent_identifier(receiver)}"
        end
        str << ")"
      end
      str << " :content #{msg.content}" unless msg.content.nil?
      str << " :reply-with #{msg.reply_with}" unless msg.reply_with.nil?
      str << " :reply-by #{msg.reply_by}" unless msg.reply_by.nil?
      str << " :in-reply-to #{msg.in_reply_to}" unless msg.in_reply_to.nil?
      unless msg.reply_to.empty?
        str << " :reply-to (set"
        msg.each_reply_to do |reply_to|
          str << " #{encode_agent_identifier(reply_to)}"
        end
        str << ")"
      end
      str << " :language #{msg.language}" unless msg.language.nil?
      str << " :encoding #{msg.encoding}" unless msg.encoding.nil?
      str << " :ontology #{msg.ontology}" unless msg.ontology.nil?
      str << " :protocol #{msg.protocol}" unless msg.protocol.nil?
      str << " :conversation-id #{msg.conversation_id}" unless msg.conversation_id.nil?
      str << ")"
    end
    
  end # class StringCodec
  
end # module RAGE

