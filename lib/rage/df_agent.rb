module RAGE
  
  class DFAgent < RAGE::Agent

    def register_capabilities
      register_service_description = RAGE::ServiceDescription.new(
        :name => "Service Registration",
        :protocols => [ "fipa-request" ],
        :ontologies => [ "fipa-agent-management" ]
      )
      deregister_service_description = RAGE::ServiceDescription.new(
        :name => "Service Deregistration",
        :protocols => [ "fipa-request" ],
        :ontologies => [ "fipa-agent-management" ]
      )
      modify_service_description = RAGE::ServiceDescription.new(
        :name => "Service Modification",
        :protocols => [ "fipa-request" ],
        :ontologies => [ "fipa-agent-management" ]
      )
      search_service_description = RAGE::ServiceDescription.new(
        :name => "Service Search",
        :protocols => [ "fipa-request" ],
        :ontologies => [ "fipa-agent-management" ]
      )
      agent_description = RAGE::DFAgentDescription.new(
        :name => aid,
        :services => [
          register_service_description,
          deregister_service_description,
          modify_service_description,
          search_service_description
        ]
      )
      df.register(agent_description)
    end
    
    def handle_request(msg)
      action = msg.content
      case action.act
      when "register"
      when "deregister"
      when "modify"
      when "search"
      when "get-description"
      else
        raise RuntimeError, "unexpected message content"
      end
    end

  end # class DFAgent

end # module RAGE
