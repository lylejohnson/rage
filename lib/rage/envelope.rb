require 'rexml/document'
require 'time'
require 'rage/aid'

module RAGE

  class Received

    attr_reader :by, :from, :date, :id, :via

    def initialize(params)
      @by = params[:by]
      @from = params[:from]
      @date = params[:date]
      @id = params[:id]
      @via = params[:via]
    end

  end # class Received

  class Envelope

    private

    def Envelope.agent_identifier_from_xml(element)
      name = element.elements["name"].text
      addresses_elt = element.elements["addresses"]
      addresses = []
      if addresses_elt
        addresses_elt.each_element("url") do |url_elt|
          addresses << url_elt.text
        end
      end
      resolvers_elt = element.elements["resolvers"]
      resolvers = []
      if resolvers_elt
        resolvers_elt.each_element("agent-identifier") do |aid_elt|
          resolvers << agent_identifier_from_xml(aid_elt)
        end
      end
      AgentIdentifier.new(:name => name, :addresses => addresses, :resolvers => resolvers)
    end

    public

    attr_reader   :intended_receiver
    attr_reader   :receivers
    attr_accessor :sender
    attr_accessor :comments
    attr_accessor :acl_representation
    attr_accessor :payload_length
    attr_accessor :payload_encoding
    attr_accessor :date
    attr_accessor :encrypted
    attr_accessor :received

    #
    # Return an initialized Envelope instance.
    #
    def initialize(params={})
      @receivers = params[:receivers] || []
      @sender = params[:sender]
      @comments = params[:comments]
      @acl_representation = params[:acl_representation]
      @payload_length = params[:payload_length]
      @payload_encoding = params[:payload_encoding]
      @date = params[:date]
      @encrypted = params[:encrypted]
      @intended_receiver = params[:intended_receiver]
      @received = params[:received] || []
    end

    def add_receiver(name, address)
      self.receivers << AgentIdentifier.new(:name => name, :addreses => [address])
    end

    def add_sender(name, address)
      self.sender = AgentIdentifier.new(:name => name, :addresses => [address])
    end

    #
    # Return a new Envelope instance, initialized from a REXML document.
    #
    def Envelope.from_xml(doc)
      # Collect all of the PARAMS elements, sort by index.
      params = []
      doc.root.each_element("params") do |params_elt|
        params << params_elt
      end

      # Sort them by the values of their index attributes
      params.sort { |a, b| a.attributes["index"].to_i <=> b.attributes["index"].to_i }

      # Now process them in order
      env = Envelope.new
      params.each do |params_elt|
        to_elt = params_elt.elements["to"]
        if to_elt
          env.receivers.clear # replace previous values, if any
          to_elt.each_element("agent-identifier") do |aid_elt|
            env.receivers << agent_identifier_from_xml(aid_elt)
          end
        end
        from_elt = params_elt.elements["from"]
        if from_elt
          aid_elt = from_elt.elements["agent-identifier"]
          env.sender = agent_identifier_from_xml(aid_elt)
        end
        comments_elt = params_elt.elements["comments"]
        env.comments = comments_elt.text if comments_elt
        acl_rep_elt = params_elt.elements["acl-representation"]
        env.acl_representation = acl_rep_elt.text if acl_rep_elt
        payload_len_elt = params_elt.elements["payload-length"]
        env.payload_length = payload_len_elt.text if payload_len_elt
        payload_enc_elt = params_elt.elements["payload-encoding"]
        env.payload_encoding = payload_enc_elt.text if payload_enc_elt
        date_elt = params_elt.elements["date"]
        if date_elt
          env.date = Time.parse(date_elt.text)
        end
        encrypted_elt = params_elt.elements["encrypted"]
        intended_elt = params_elt.elements["intended-receiver"]
        if intended_elt
          env.intended_receiver = nil # replace previous value, if any
          intended_elt.each_element("agent-identifier") do |aid_elt| # FIXME: we expect at most one of these
            env.intended_receiver = agent_identifier_from_xml(aid_elt)
          end
        end
        received = params_elt.elements["received"]
        if received
          by, from, date, id, via = nil, nil, nil, nil, nil
          #	by = received.elements["received-by"].elements["url"].text
          by = received.elements["received-by"].attributes["value"]
          if received.elements["received-from"]
            #	from = received.elements["received-from"].elements["url"].text
            from = received.elements["received-from"].attributes["value"]
          end
          date = received.elements["received-date"].attributes["value"]
          if date
            date = Time.parse(date)
          end
          if received.elements["received-id"]
            id = received.elements["received-id"].attributes["value"]
          end
          if received.elements["received-via"]
            via = received.elements["received-via"].attributes["value"]
          end
          env.received = Received.new(:by => by, :from => from, :date => date, :id => id, :via => via)
        end
      end
      env
    end

    #
    # Return the first of the receivers.
    #
    def receiver
      receivers.first
    end

    #
    # Iterate over the receivers.
    #
    def each_receiver(&blk) # :yield: anAID
      receivers.each(&blk)
    end

    def agent_identifier_to_xml(root, aid)
      aid_elt = root.add_element("agent-identifier")
      name_elt = aid_elt.add_element("name")
      name_elt.text = aid.name
      unless aid.addresses.empty?
        addresses_elt = aid_elt.add_element("addresses")
        aid.each_address do |addr|
          url_elt = addresses_elt.add_element("url")
          url_elt.text = addr
        end
      end
      unless aid.resolvers.empty?
        resolvers_elt = aid_elt.add_element("resolvers")
        aid.each_resolver do |res|
          agent_identifier_to_xml(resolvers_elt, res)
        end
      end
    end

    #
    # Return an REXML::Document instance for this envelope,
    # FIPA Agent Message Transport Envelope Representation in XML
    # Specification (SC00085J).
    #
    def to_xml
      doc = REXML::Document.new
      doc << REXML::XMLDecl.default
      doc.add_element("envelope")
      p = doc.root.add_element("params", { "index" => "1" })
      unless receivers.empty?
        to_elt = p.add_element("to")
        receivers.each do |aid|
          agent_identifier_to_xml(to_elt, aid)
        end
      end
      unless sender.nil?
        from_elt = p.add_element("from")
        agent_identifier_to_xml(from_elt, sender)
      end
      unless comments.nil?
        elt = p.add_element("comments")
        elt.text = comments
      end
      unless acl_representation.nil?
        elt = p.add_element("acl-representation")
        elt.text = acl_representation
      end
      unless payload_length.nil?
        elt = p.add_element("payload-length")
        elt.text = payload_length
      end
      unless payload_encoding.nil?
        elt = p.add_element("payload-encoding")
        elt.text = payload_encoding
      end
      unless date.nil?
        elt = p.add_element("date")
        elt.text = date.iso8601
      end
      unless encrypted.nil?
        elt = p.add_element("encrypted")
        elt.text = encrypted
      end
      unless intended_receivers.empty?
        elt = p.add_element("intended-receiver")
        intended_receivers.each do |r|
          agent_identifier_to_xml(elt, r)
        end
      end
      unless received.nil?
        received_elt = p.add_element("received")
        received_by_elt = received_elt.add_element("received-by")
        url_elt = received_by_elt.add_element("url")
        url_elt.text = received.by
        unless received.from.nil?
          received_from_elt = received_elt.add_element("received-from")
          url_elt = received_from_elt.add_element("url")
          url_elt.text = received.from
        end
        received_elt.add_element("received-date", { "value" => received.date })
        unless received.id.nil?
          received_elt.add_element("received-id", { "value" => received.id})
        end
        unless received.via.nil?
          received_elt.add_element("received-via", { "value" => received.via})
        end
      end
      doc
    end
    
    def mark_as_received(params={})
      self.received << Received.new(params)
    end
    
  end # class Envelope

end # module RAGE

