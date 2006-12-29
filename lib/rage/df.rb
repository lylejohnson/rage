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
    def initialize(params)
      @name = params[:name]
      @type = params[:type]
      @protocols = params[:protocols]
      @ontologies = params[:ontologies]
      @languages = params[:languages]
      @ownership = params[:ownership]
      @properties = params[:properties]
    end
    
    # Return +true+ if this service description matches the pattern.
    def matches?(pattern)
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
    def initialize(params)
      @name = params[:name]
      @services = params[:services] || []
      @protocols = params[:protocols] || []
      @ontologies = params[:ontologies] || []
      @languages = params[:languages] || []
      @lease_time = params[:lease_time]
    end

    def matches?(pattern)
      pattern.services.each do |service_pattern|
        this_pattern_matched = false
        self.services.each do |service|
          if service.matches? service_pattern
            this_pattern_matched = true
          end
        end
        return false if !this_pattern_matched
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
    #
    # Return an initialized DirectoryFacilitator instance.
    #
    def initialize
      @entries = {}
    end

    # Register an agent's capabilities, where _entry_ is a DF
    # Agent Description.
    def register(entry)
      unless @entries.key? entry.name
        @entries[entry.name] = entry
      else
        raise RuntimeError, "agent already registered"
      end
    end
    
    def deregister(entry)
      @entries.delete(entry.name)
    end
    
    def modify(entry)
      if @entries.key? entry.name
        @entires[entry.name] = entry
      else
        raise RuntimeError, "no such agent is registered"
      end
    end
    
    #
    # Returns a set of agent descriptions.
    #
    def search(pattern, search_constraints=nil)
      matches = []
      @entries.each do |aid, entry|
        matches << entry if entry.matches? pattern
      end
      matches
    end

  end # class DirectoryFacilitator
  
end # module RAGE

