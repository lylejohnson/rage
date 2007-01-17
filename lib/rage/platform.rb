require 'rage/ams_agent'
require 'rage/df_agent'

require 'yaml'
require 'logger'
require 'socket'

module RAGE

  class Platform

    # A reference to the Agent Management System (AMS)
    attr_reader :ams

    # A reference to the Directory Facilitator (DF) for this Agent Platform.
    attr_reader :df

    # A reference to the Logger instance.
    attr_reader :logger

    # A reference to the Agent Communication Channel (ACC) for this Agent Platform
    attr_reader :acc

    #
    # Return an initialized Platform instance.
    #
    def initialize(params={})
      # Initialize standard services
      @logger = Logger.new(STDOUT)
      @ams = AgentManagementSystem.new(:name => fully_qualified_agent_name("ams"), :addresses => agent_transport_addresses, :logger => logger)
      @df = DirectoryFacilitator.new(:name => fully_qualified_agent_name("df"), :addresses => agent_transport_addresses, :logger => logger)
      @acc = AgentCommunicationChannel.new(:logger => logger, :ams => ams)
      @config = params[:config] || "rage.yaml"
    end
    
    def start_ams_agent
      agent = AMSAgent.new(
        :ams => ams,
        :df => df,
        :acc => acc,
        :logger => logger,
        :name => fully_qualified_agent_name("ams"),
        :addresses => agent_transport_addresses
      )
      Thread.new { agent.run }
    end
    
    def start_df_agent
      agent = DFAgent.new(
        :ams => ams,
        :df => df,
        :acc => acc,
        :logger => logger,
        :name => fully_qualified_agent_name("df"),
        :addresses => agent_transport_addresses
      )
      Thread.new { agent.run }
    end

    #
    # Return a Class given its name, borrowed from http://www.rubygarden.org/ruby?FindClassesByName.
    #
    def get_class(name)
      name.split(/::/).inject(Object) { |p, n| p.const_get(n) }  
    end

    private :get_class

    #
    # Start running.
    #
    def run
      # Start platform agents
      start_ams_agent
      start_df_agent
      
      # Start up agents listed in configuration file
      if File.exist?(@config)
        hostname = Socket.gethostname
        startup = YAML::load(File.open(@config, "r"))
        startup.each do |description|
          agent_name = description["name"]
          agent_src = description["src"]
          src = File.open(agent_src).read
          load agent_src
          agent_class = nil
          begin
            class_name = description["classname"]
            agent_class = get_class(class_name)
          rescue NameError
            logger.error "Couldn't instantiate an agent of class #{className}"
          end
          agent = agent_class.new(
            :ams => ams,
            :df => df,
            :acc => acc,
            :logger => logger,
            :name => fully_qualified_agent_name(agent_name),
            :addresses => agent_transport_addresses
          )
          Thread.new { agent.run }
        end
      end
    end
    
    def hostname
      Socket.gethostname
    end
    
    def agent_transport_addresses
      [ "druby://localhost:9001" ]
    end
    
    def fully_qualified_agent_name(name)
      "#{name}@#{hostname}"
    end
    
  end # class Platform
  
end # module RAGE

if __FILE__ == $0
  RAGE::Platform.new.run
  Thread.list.each { |t| t.join if t != Thread.main }
end

