require 'logger'
require 'thread'

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
    
    # The life cycle state of the agent (one of :initiated, :active, :suspended, :waiting, :transit or :unknown)
    attr_reader :state

    # Return an initialized agent description
    def initialize(params={})
      @name = params[:name]
      @ownership = params[:ownership]
      @state = params[:state]
    end
    
    # Return +true+ if this agent description matches the pattern
    def matches?(pattern)
      return false if (pattern.name && !self.name.matches?(pattern.name))
      return false if (pattern.ownership && ownership != pattern.ownership)
      return false if (pattern.state && state != pattern.state)
      true
    end
    
  end

  class AgentManagementSystem
    
    #
    # Return an initialized AgentManagementSystem (AMS) instance.
    #
    def initialize(params={})
      @agents = {}
      @agent_descriptions = {}
      @mutex = Mutex.new
      @logger = params[:logger] || Logger.new(STDOUT)
      @addresses = params[:addresses]
    end
    
    def hostname
      Socket.gethostname
    end

    #
    # Register an agent with the specified AMSAgentDescription.
    #
    def register(agent_description, agent)
      @mutex.synchronize do
        unless @agents.key? agent_description.name
          @agents[agent_description.name] = agent
          @agent_descriptions[agent_description.name] = agent_description
          @logger.info "registered agent #{agent_description.name.name}"
        else
          raise FailureException.new("already-registered")
        end
      end
    end
    
    def deregister(agent_description)
      @mutex.synchronize do
        if @agents.key? agent_description.name
          @agents.delete(agent_description.name)
          @agent_descriptions.delete(agent_description.name)
        else
          raise FailureException.new("not-registered")
        end
      end
    end
    
    def modify(agent_description)
      @mutex.synchronize do
        if @agents.key? agent_description.name
          @agent_descriptions[agent_description.name] = agent_description
        else
          raise FailureException.new("not-registered")
        end
      end
    end
    
    #
    # Search for an agent identified by the supplied pattern.
    # Return the AMS agent description(s) of the matching agent(s).
    #
    def search(pattern, search_constraints=nil)
      matches = []
      @mutex.synchronize do
        @agent_descriptions.each_value do |agent_description|
          matches << agent_description if agent_description.matches? pattern
        end
      end
      matches
    end
    
    # Return the platform profile of the AP for this AMS
    def get_description
      response = nil
      @mutex.synchronize do
        if @description.nil?
          @description = APDescription.new(
            :name => "MyAPDescription",
            :services => [
              APService.new(
                :name => "MyDRbMTP",
                :type => "druby",
                :addresses => @addresses
              )
            ]
          )
        end
        response = @description
      end
      response
    end
    
    # Return a reference to the agent registered under this AgentIdentifier.
    def agent_for_name(name)
      agent = nil
      @mutex.synchronize do
        agent = @agents[name]
      end
      agent
    end
    
    def invoke_all_agents
      agents = nil
      @mutex.synchronize { agents = @agents.dup }
      agents.each_value do |agent|
        unless agent.active?
          agent.invoke
          Thread.new { agent.run }
        end
      end
    end
    
    def each_agent
      @mutex.synchronize do
        @agents.each_value { |desc| yield desc }
      end
    end
    
  end # class AgentManagementSystem
  
end # module RAGE

