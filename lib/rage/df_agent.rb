module RAGE
  
  class DFAgent < RAGE::Agent

    def register_capabilities
      service_description = RAGE::ServiceDescription.new(
        :name => "Directory Facilitator",
        :type => "fipa-df",
        :protocols => [ "fipa-request" ],
        :ontologies => [ "fipa-agent-management" ]
      )
      agent_description = RAGE::DFAgentDescription.new(
        :name => aid,
        :services => [ service_description ]
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
