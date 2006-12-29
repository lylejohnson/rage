require 'rage/aid'

module RAGE

  class AMSAgentDescription

    # The identifier of the agent (an AgentIdentifier)
    attr_reader :name
    
    # The owner of the agent (a string)
    attr_reader :ownership
    
    # The life cycle state of the agent (one of :initiated, :active, :suspended, :waiting or :transit)
    attr_reader :state

    def initialize(params)
      @name = params[:name]
      @ownership = params[:ownership]
      @state = params[:state]
    end
    
  end

  class AgentManagementSystem
    #
    # Map of AIDs to agents.
    #
    attr_reader :agents

    #
    # Return an initialized AgentManagementSystem (AMS) instance.
    #
    def initialize
      @agents = {}
    end

    #
    # Register an agent with the specified AMSAgentDescription.
    #
    def register(agent_description)
    end
    
    def deregister(agent_description)
    end
    
    def modify(agent_description)
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
    
  end # class AgentManagementSystem
  
end # module RAGE

