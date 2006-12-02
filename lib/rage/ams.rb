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
  end
end

