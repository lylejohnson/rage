module RAGE
  
  class AMSAgent < RAGE::Agent

    def register_capabilities
      service_description = RAGE::ServiceDescription.new(
        :name => "Agent Management System",
        :type => "fipa-ams",
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
        agree_to(msg, :precondition => true)
        agent_description = msg.content.arguments.first
        ams.register(agent_description)
        inform_done(msg)
      when "deregister"
        agree_to(msg, :precondition => true)
        agent_description = msg.content.arguments.first
        ams.deregister(agent_description)
        inform_done(msg)
      when "modify"
        agree_to(msg, :precondition => true)
        agent_description = msg.content.arguments.first
        ams.modify(agent_description)
        inform_done(msg)
      when "search"
        agree_to(msg, :precondition => true)
        agent_description = msg.content.arguments.first
        ams.register(agent_description)
        inform_result(msg)
      when "get-description"
      else
        raise RuntimeError, "unexpected message content"
      end
    end
    
  end # class AMSAgent
  
end # module RAGE
