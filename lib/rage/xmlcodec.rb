require 'rage/Message'
require 'rage/aid'
require 'rexml/document'

module RAGE

  class XMLCodec

    def agent_identifier_from_xml(element)
      name = nil
      name_elt = element.elements["name"]
      if name_elt.attributes["id"]
        name = name_elt.attributes["id"]
      else
        name = name_elt.attributes["refid"]
      end
      addresses = []
      addresses_elt = element.elements["addresses"]
      if addresses_elt
        addresses_elt.each_element("url") do |url_elt|
          addresses << url_elt.attributes["href"]
        end
      end
      resolvers_elt = element.elements["resolvers"]
      resolvers = []
      if resolvers_elt
        resolvers_elt.each_element("agent-identifier") do |aid_elt|
          resolvers << agent_identifier_from_xml(aid_elt)
        end
      end
      RAGE::AgentIdentifier.new(
        :name => name,
        :addresses => addresses,
        :resolvers => resolvers
      )
    end

    #
    # Return a new Message instance, with contents initialized
    # from an REXML document _doc_.
    #
    def decode(src)
      doc = REXML::Document.new(src)
      performative = doc.root.attributes["act"]
      msg = Message.new(:performative => performative)
      msg.conversation_id = doc.root.attributes["conversation-id"]
      receiver_elt = doc.root.elements["receiver"]
      receiver_elt.each_element("agent-identifier") do |aid_elt|
        msg.receivers << agent_identifier_from_xml(aid_elt)
      end
      sender_elt = doc.root.elements["sender"]
      aid_elt = sender_elt.elements["agent-identifier"]
      msg.sender = agent_identifier_from_xml(aid_elt)
      msg.content = doc.root.elements["content"].attributes["href"]
      msg.language = doc.root.elements["language"].attributes["href"]
      msg.encoding = doc.root.elements["encoding"].attributes["href"]
      msg.ontology = doc.root.elements["ontology"].attributes["href"]
      msg.protocol = doc.root.elements["protocol"].attributes["href"]
      msg.reply_with = doc.root.elements["reply-with"].attributes["href"]
      msg.in_reply_to = doc.root.elements["in-reply-to"].attributes["href"]
      msg.reply_by = ReplyBy.new(doc.root.elements["reply-by"].attributes["time"], doc.root.elements["reply-by"].attributes["href"])
      reply_to_elt = doc.root.elements["reply-to"]
      reply_to_elt.each_element("agent-identifier") do |aid_elt|
        msg.reply_to << agent_identifier_from_xml(aid_elt)
      end
      msg.conversation_id = doc.root.elements["conversation-id"].attributes["href"]
      msg
    end

    #
    # Return an XML document.
    #
    def encode(msg)
      doc = REXML::Document.new
      doc << REXML::XMLDecl.default
      root = doc.add_element("fipa-message", { "act" => msg.performative, "conversation-id" => msg.conversation_id })
      msg.receivers.each do |recv|
        el = root.add_element("receiver")
        el.add_element("agent-identifier")
      end
      el = root.add_element("sender")
      el.add_element("agent-identifier")
      root.add_element("content", { "href" => nil })
      root.add_element("language", { "href" => nil })
      root.add_element("encoding", { "href" => nil })
      root.add_element("ontology", { "href" => nil })
      root.add_element("protocol", { "href" => nil })
      root.add_element("reply-with", { "href" => nil })
      root.add_element("in-reply-to", { "href" => nil })
      root.add_element("reply-by", { "time" => nil, "href" => nil })
      el = root.add_element("reply-to")
      msg.reply_to.each do |repl|
        el.add_element("agent-identifier")
      end
      root.add_element("conversation-id", { "href" => nil })
      root.add_element("user-defined")
      doc.to_s
    end

  end # class XMLCodec

end # module RAGE

