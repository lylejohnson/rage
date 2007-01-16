module RAGE
  
  class AMSAgent < RAGE::Agent

    def register_capabilities
      register_service_description = RAGE::ServiceDescription.new(
        :name => "Agent Registration",
        :protocols => [ "fipa-request" ],
        :ontologies => [ "fipa-agent-management" ]
      )
      deregister_service_description = RAGE::ServiceDescription.new(
        :name => "Agent Deregistration",
        :protocols => [ "fipa-request" ],
        :ontologies => [ "fipa-agent-management" ]
      )
      modify_service_description = RAGE::ServiceDescription.new(
        :name => "Agent Modification",
        :protocols => [ "fipa-request" ],
        :ontologies => [ "fipa-agent-management" ]
      )
      search_service_description = RAGE::ServiceDescription.new(
        :name => "Agent Search",
        :protocols => [ "fipa-request" ],
        :ontologies => [ "fipa-agent-management" ]
      )
      get_description_service_description = RAGE::ServiceDescription.new(
        :name => "Platform Description",
        :protocols => [ "fipa-request" ],
        :ontologies => [ "fipa-agent-management" ]
      )
      agent_description = RAGE::DFAgentDescription.new(
        :name => aid,
        :services => [
          register_service_description,
          deregister_service_description,
          modify_service_description,
          search_service_description,
          get_description_service_description
        ]
      )
      df.register(agent_description)
    end
    
    def handle_request(msg)
      # FIXME
    end
    
  end # class AMSAgent
  
end # module RAGE
