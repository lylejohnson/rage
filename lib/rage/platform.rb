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
    
    # Returns a reference to the Platform instance
    def Platform.instance
      @@instance
    end

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
      @@instance = self
    end
    
    def create_ams_agent
      AMSAgent.new(
        :ams => ams,
        :df => df,
        :acc => acc,
        :logger => logger,
        :name => fully_qualified_agent_name("ams"),
        :addresses => agent_transport_addresses
      )
    end
    
    def create_df_agent
      DFAgent.new(
        :ams => ams,
        :df => df,
        :acc => acc,
        :logger => logger,
        :name => fully_qualified_agent_name("df"),
        :addresses => agent_transport_addresses
      )
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
      # Create platform agents
      create_ams_agent
      create_df_agent
      
      # Create agents listed in configuration file
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
        end
      end
      
      # Start (invoke) all agents
      ams.invoke_all_agents
      
      # Start the dashboard
#     start_dashboard
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
    
    def start_dashboard
      require 'rage/web/dashboard'
      Thread.new { RAGE::Web::Server.new.start }
    end
    
  end # class Platform
  
end # module RAGE

if __FILE__ == $0
  RAGE::Platform.new.run
  Thread.list.each { |t| t.join if t != Thread.main }
end
