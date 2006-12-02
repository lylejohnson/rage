require 'rage/mts'

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
  # * Message passing using ACLMessage objects, both unicast and multicast with optional pattern matching.
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
    
    # The agent identifier (AID) for the platform Agent Messaging System (AMS).
    attr_reader :ams
    
    # The agent identifier (AID) for the platform's default Directory Facilitator (DF).
    attr_reader :df
    
    # The array of arguments passed to this agent.
    attr_reader :arguments

    # The agent's local name.
    attr_reader :local_name
    
    # The agent's complete name.
    attr_reader :name
    
    # The agent's home address.
    attr_reader :hap
    
    #
    # Return an initialized Agent instance.
    #
    def initialize
    end

    #
    # Return a reference to the message transport system.
    #
    def mts
      MessageTransportSystem.instance
    end

    #
    # This method adds a new behavior to the agent.
    # This behavior will be executed concurrently with all the others, using a
    # cooperative round robin scheduling.
    # This method is typically called from an agent's #setup method to fire off
    # some initial behavior, but can also be used to spawn new behaviors
    # dynamically.
    #
    def add_behavior(behavior)
    end
    
    #
    # This method removes a given behavior from the agent.
    # This method is called automatically when a top level behavior terminates,
    # but can also be called from a behavior to terminate itself or some other
    # behavior.
    #
    def remove_behavior(behavior)
    end
    
    #
    # This method is an empty placeholder for application specific startup code.
    # Agent developers can override it to provide necessary behavior.
    # When this method is called the agent has been already registered with the
    # Agent Platform AMS and is able to send and receive messages.
    # However, the agent execution model is still sequential and no behavior
    # scheduling is active yet.
    # This method can be used for ordinary startup tasks such as DF registration,
    # but is essential to add at least one Behavior object to the agent, in order
    # for it to be able to do anything.
    #
    def setup
    end
    
    #
    # This method is an empty placeholder for application specific cleanup code.
    # Agent developers can override it to provide necessary behavior.
    # When this method is called the agent has not yet deregistered itself with the
    # Agent Platform AMS and is still able to exchange messages with other agents.
    # However, no behavior scheduling is active anymore and the Agent Platform
    # Life Cycle state is already set to _deleted_.
    # This method can be used for ordinary cleanup tasks such as DF deregistration,
    # but explicit removal of all agent behaviors is not needed.
    #
    def take_down
    end
    
    #
    # Send an ACL message to another agent.
    # This method sends a message to the agent specified in :receiver message
    # field (more than one agent can be specified as message receiver).
    #
    def send(msg)
      mts.send(msg)
    end
    
    #
    # Receives an ACL message from the agent message queue.
    # This method is non-blocking and returns the first message in the queue, if any.
    # Therefore, polling and busy waiting are required to wait for the next
    # message sent using this method.
    #
    def receive
    end

    #
    # Receives an ACL message from the agent message queue.
    # This method is non-blocking and returns the first message in the queue, if any.
    # Therefore, polling and busy waiting are required to wait for the next
    # message sent using this method.
    #
    def receive_if(&blk)
    end
    
    #
    # Receives an ACL message from the agent message queue, waiting at most a specified amount of time.
    #
    def blocking_receive(millis=nil)
    end

    #
    # Receives an ACL message from the agent message queue, waiting at most a specified amount of time.
    #
    def blocking_receive_if(millis=nil, &blk)
    end
    
    #
    # Puts a received ACL message back into the message queue.
    # This method can be used from an agent behavior when it realizes it read
    # a message of interest for some other behavior.
    # The message is put in front of the message queue, so it will be the first
    # returned by a subsequent #receive call.
    #
    def put_back(msg)
    end
    
    #
    # Put a received message into the agent message queue.
    # The message is put at the back end of the queue.
    # This method is called by RAGE runtime system when a message arrives, but
    # can also be used by an agent, and is just the same as sending a message
    # to oneself (though slightly faster).
    #
    def post_message(msg)
    end
    
    #
    # Run
    #
    def run
      loop do
        # something
      end
    end
  end
end

