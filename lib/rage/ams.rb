require 'rage/aid'

module RAGE

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
    # Register an agent with the requested name.
    #
    def register(agent, name)
      agent.aid = AID.new(name)
      agents[agent.aid] = agent
    end
    
    # Search for an agent identified by the supplied AID.
    # Return the AMS agent description of the agent.
    def search(aid)
    end
    
  end # class AgentManagementSystem
  
end # module RAGE

