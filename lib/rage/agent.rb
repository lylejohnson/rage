require 'rage/ams'
require 'rage/envelope'

require 'thread'

module RAGE
  #
  # Quoting the FIPA Agent Management Specification (SC00023):
  # "An agent is a computational process that implements the autonomous, communicating functionality
  # of an application. Agents communicate using an Agent Communication Language (ACL). An Agent is
  # the fundamental actor on an Agent Platform (AP) which combines one or more service capabilities,
  # as published in a service description, into a unified and integrated execution model. An agent must
  # have at least one owner, for example, based on organizational affiliation or human user ownership,
  # and an agent must support at least one notion of identity. This notion of identity is the
  # Agent Identifier (AID) that labels an agent so that it may be distinguished unambiguously within
  # the Agent Universe. An agent may be registered at a number of transport addresses at which it can
  # be contacted." (p. 2)
  #
  # The Agent class is the common superclass for user defined software agents.
  # It provides methods to perform basic agent tasks, such as:
  #
  # * Message passing using Message objects, both unicast and multicast with optional pattern matching.
  # * Complete Agent Platform life cycle support, including starting, suspending and killing an agent.
  # * Scheduling and execution of multiple concurrent activities.
  # * Simplified interaction with FIPA system agents for automating common agent tasks (DF registration, etc.). 
  #
  # Application programmers must write their own agents as Agent subclasses,
  # adding specific behaviors as needed and exploiting Agent class capabilities.
  #
  class Agent

    # The agent identifier (AID) for this agent.
    attr_accessor :aid
    
    # A reference to the platform's Agent Messaging System (AMS).
    attr_reader :ams
    
    # A reference to the platform's Agent Communication Channel (ACC)
    attr_reader :acc

    # A reference to the platform's Directory Facilitator (DF).
    attr_reader :df
    
    # Platform logger instance
    attr_reader :logger

    # The life cycle state of the agent (one of :initiated, :active, :suspended, :waiting or :transit)
    attr_reader :state
    
    # The owner of this agent (a string)
    attr_reader :owner

    #
    # Return an initialized Agent instance.
    #
    def initialize(params={})
      @ams = params[:ams]
      @df = params[:df]
      @acc = params[:acc]
      @logger = params[:logger]
      @aid = RAGE::AgentIdentifier.new(:name => params[:name])
      @owner = "My Owner"
      @state = :active
      agent_description = RAGE::AMSAgentDescription.new(
        :name => aid,
        :ownership => owner,
        :state => state
      )
      ams.register(agent_description, self)
      @messages = Queue.new
    end
    
    # Return the name for this agent
    def name
      aid.name
    end

    #
    # Send an ACL message to another agent.
    # This method sends a message to the agent specified in :receiver message
    # field (more than one agent can be specified as message receiver).
    #
    def send_message(msg)
      envelope = RAGE::Envelope.new(
        :sender => aid,
        :receivers => msg.receivers,
        :date => Time.now
      )
      acc.send_message(envelope, msg)
    end
    
    #
    # Receives an ACL message from the agent message queue.
    # This method is non-blocking and returns the first message in the queue, if any.
    # Therefore, polling and busy waiting are required to wait for the next
    # message sent using this method.
    #
    def receive
      unless @messages.empty?
        @messages.pop
      else
        nil
      end
    end

    #
    # Receives an ACL message from the agent message queue.
    #
    def blocking_receive
      @messages.pop
    end

    #
    # Put a received message into the agent message queue.
    # The message is put at the back end of the queue.
    # This method is called by RAGE runtime system when a message arrives, but
    # can also be used by an agent, and is just the same as sending a message
    # to oneself (though slightly faster).
    #
    def post_message(envelope, payload)
      logger.info "A message was posted to the message queue for agent: #{name}"
      @messages.push(payload)
    end
    
    #
    # Run
    #
    def run
      logger.info "Agent #{name} is now waiting for messages..."
      loop do
        msg = blocking_receive
        handle_message(msg)
      end
    end
    
    # Handle a message
    def handle_message(msg)
      logger.info "Agent #{name} asked to handle message"
    end
    
  end # class Agent

end # module RAGE

