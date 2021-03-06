require 'logger'
require 'rage/exceptions'
require 'thread'

module RAGE

  class ServiceDescription
    
    # The name of the service (a string)
    attr_reader :name
    
    # The type of the service (a string)
    attr_reader :type
    
    # A list of interaction protocols supported by the service (a set of strings)
    attr_reader :protocols
    
    # A list of ontologies supported by the service (a set of strings)
    attr_reader :ontologies
    
    # A list of content languages supported by the service (a set of strings)
    attr_reader :languages
    
    # The owner of the service (a string)
    attr_reader :ownership
    
    # A list of properties that discriminate the service (a hash of name-value pairs)
    attr_reader :properties
    
    # Return an initialized service description instance
    def initialize(params={})
      @name = params[:name]
      @type = params[:type]
      if params.key? :protocol
        @protocols = [ params[:protocol] ]
      else
        @protocols = params[:protocols] || []
      end
      if params.key? :ontology
        @ontologies = [ params[:ontology] ]
      else
        @ontologies = params[:ontologies] || []
      end
      if params.key? :language
        @languages = [ params[:language] ]
      else
        @languages = params[:languages] || []
      end
      @ownership = params[:ownership] || []
      @properties = params[:properties] || {}
    end
    
    # Return the first ontology associated with this service description, if any.
    def ontology; ontologies.first; end
    
    # Return the first language associated with this service description, if any.
    def language; languages.first; end
    
    # Return the first protocol associated with this service description, if any.
    def protocol; protocols.first; end
    
    # Return +true+ if this service description matches the pattern.
    def matches?(pattern)
      return false if (pattern.name && self.name != pattern.name)
      return false if (pattern.type && self.type != pattern.type)
      pattern.protocols.each do |protocol|
        return false unless self.protocols.include? protocol
      end
      pattern.ontologies.each do |ontology|
        return false unless self.ontologies.include? ontology
      end
      pattern.languages.each do |language|
        return false unless self.languages.include? language
      end
      return false if (pattern.ownership && self.ownership != pattern.ownership)
      pattern.properties.each do |kp, vp|
        this_property_matched = false
        self.properties.each do |k, v|
          if ((k == kp) && (v == vp))
            this_property_matched = true
            break
          end
        end
        return false unless this_property_matched
      end
      true
    end

  end

  class DFAgentDescription
    
    # The identifier for the agent (an AgentIdentifier)
    attr_reader :name
    
    # A list of services supported by this agent (a set of ServiceDescription instances)
    attr_reader :services
    
    # A list of interaction protocols supported by this agent (a set of strings)
    attr_reader :protocols
    
    # A list of ontologies known by this agent (a set of strings)
    attr_reader :ontologies
    
    # A list of content languages known by this agent (a set of strings)
    attr_reader :languages
    
    # The duration or time at which the lease for this registration will expire (a Time)
    attr_reader :lease_time
    
    # Return an initialized DFAgentDescription instance
    def initialize(params={})
      @name = params[:name]
      if params.key? :service
        @services = [ params[:service] ]
      else
        @services = params[:services] || []
      end
      if params.key? :protocol
        @protocols = [ params[:protocol] ]
      else
        @protocols = params[:protocols] || []
      end
      if params.key? :ontology
        @ontologies = [ params[:ontology] ]
      else
        @ontologies = params[:ontologies] || []
      end
      if params.key? :language
        @languages = [ params[:language] ]
      else
        @languages = params[:languages] || []
      end
      @lease_time = params[:lease_time]
    end
    
    # Return the first service associated with this agent description, if any.
    def service; services.first; end
    
    # Return the first protocol associated with this agent description, if any.
    def protocol; protocols.first; end
    
    # Return the first ontology associated with this agent description, if any.
    def ontology; ontologies.first; end
    
    # Return the first language associated with this agent description, if any.
    def language; languages.first; end

    # Return true if this agent description matches the provided pattern
    def matches?(pattern)
      return false if (pattern.name && !self.name.matches?(pattern.name))
      pattern.services.each do |service_pattern|
        this_pattern_matched = false
        self.services.each do |service|
          this_pattern_matched = true if service.matches? service_pattern
        end
        return false unless this_pattern_matched
      end
      pattern.protocols.each do |protocol|
        return false unless self.protocols.include? protocol
      end
      pattern.ontologies.each do |ontology|
        return false unless self.ontologies.include? ontology
      end
      pattern.languages.each do |language|
        return false unless self.languages.include? language
      end
      true
    end

  end

  #
  # A Directory Facilitator (DF) is an optional component of the Agent
  # Platform (AP), but if it is present, it must be implemented as a 
  # DF service. The DF provides yellow pages services to other agents.
  # Agents may register their services with the DF or query the DF to
  # find out what services are offered by other agents. Multiple DFs
  # may exist within an AP and may be federated. The DF is a reification
  # of the Agent Directory Service described in the Abstract Architecture.
  #
  class DirectoryFacilitator
    
    # A reference to the platform logger
    attr_reader :logger

    #
    # Return an initialized DirectoryFacilitator instance.
    #
    def initialize(params={})
      @logger = params[:logger] || Logger.new(STDOUT)
      @entries = {}
      @entries_mutex = Mutex.new
    end

    #
    # Register an agent's capabilities.
    #
    # Example:
    #
    #   service = ServiceDescription.new(
    #     :name => "Bob's Books",
    #     :type => "bookseller"
    #   )
    #   agent_description = DFAgentDescription.new(
    #     :name => aid,
    #     :services => [ service ]
    #   )
    #   df.register(agent_description)
    #
    def register(agent_description)
      @entries_mutex.synchronize do
        unless @entries.key? agent_description.name
          @entries[agent_description.name] = agent_description
          logger.info "Registered agent capabilities for #{agent_description.name.name}"
        else
          raise FailureError.new("already-registered")
        end
      end
    end
    
    def deregister(agent_description)
      @entries_mutex.synchronize do
        if @entries.key? agent_description.name
          @entries.delete(agent_description.name)
        else
          raise FailureError.new("not-registered")
        end
      end
    end
    
    def modify(agent_description)
      @entries_mutex.synchronize do
        if @entries.key? agent_description.name
          @entries[agent_description.name] = agent_description
        else
          raise FailureError.new("not-registered")
        end
      end
    end
    
    #
    # Returns a set of agent descriptions.
    #
    def search(pattern, search_constraints=nil)
      matches = []
      @entries_mutex.synchronize do
        @entries.each do |aid, agent_description|
          matches << agent_description if agent_description.matches? pattern
        end
      end
      matches
    end

  end # class DirectoryFacilitator
    
end # module RAGE

