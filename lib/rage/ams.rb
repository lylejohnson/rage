require 'rage/aid'
require 'rage/exceptions'

require 'logger'

module RAGE

  class APDescription
    
    # The name of the Agent Platform (a string)
    attr_reader :name
    
    # The set of services provided by this AP to the resident agents (a set of APService instances)
    attr_reader :services
    
    # Returns an initialized APDescription instance
    def initialize(params={})
      @name = params[:name]
      @services = params[:services] || []
    end
    
  end
  
  class APService
    
    # The name of the AP service (a string)
    attr_reader :name
    
    # The type of the AP service (a string)
    attr_reader :type
    
    # A list of the addresses of the service (a sequence of URLs)
    attr_reader :addresses
    
    # Return an initialized APService instance
    def initialize(params={})
      @name = params[:name]
      @type = params[:type]
      @addresses = params[:addresses] || []
    end
  
  end

  class AMSAgentDescription

    # The identifier of the agent (an AgentIdentifier)
    attr_reader :name
    
    # The owner of the agent (a string)
    attr_reader :ownership
    
    # The life cycle state of the agent (one of :initiated, :active, :suspended, :waiting or :transit)
    attr_reader :state

    def initialize(params={})
      @name = params[:name]
      @ownership = params[:ownership]
      @state = params[:state]
    end
    
  end

  class AgentManagementSystem
    
    # Map of AIDs to agents.
    attr_reader :agents
    
    # Platform logger
    attr_reader :logger

    #
    # Return an initialized AgentManagementSystem (AMS) instance.
    #
    def initialize(params={})
      @aid = RAGE::AgentIdentifier.new(:name => "ams@hap_name", :addresses => ["hap_transport_address"])
      @agents = {}
      @logger = params[:logger] || Logger.new(STDOUT)
    end

    #
    # Register an agent with the specified AMSAgentDescription.
    #
    def register(agent_description)
      unless @agents.key? agent_description.name
        @agents[agent_description.name] = agent_description
        logger.info "registered agent #{agent_description.name.name}"
      else
        raise FailureException.new("already-registered")
      end
    end
    
    def deregister(agent_description)
      if @agents.key? agent_description.name
        @agents.delete(agent_description.name)
      else
        raise FailureException.new("not-registered")
      end
    end
    
    def modify(agent_description)
      if @agents.key? agent_description.name
        @agents[agent_description.name] = agent_description
      else
        raise FailureException.new("not-registered")
      end
    end
    
    # Search for an agent identified by the supplied pattern.
    # Return the AMS agent description of the matching agent(s).
    def search(pattern, search_constraints=nil)
      matches = []
      @entries.each do |agent_description|
        matches << agent_description if agent_description.matches? pattern
      end
      matches
    end
    
    # Return the platform profile of the AP for this AMS
    def get_description
      APDescription.new
    end
    
  end # class AgentManagementSystem
  
end # module RAGE

