require 'rage/ams_agent'
require 'rage/df_agent'

require 'drb'
require 'logger'
require 'socket'
require 'yaml'

module RAGE

  #
  # An agent container contains one or more agents.
  # An agent platform consists of one or more agent containers.
  # The first container created for a platform is designated its "main" container,
  # and it's the one that hosts the AMS and DF for that platform.
  #
  class Container

    # The name of this container (e.g. "Main-Container" or "Container-1")
    attr_reader :container_name
    
    # The name of the platform (e.g. "pepper.sentar.com:9001/RAGE")
    attr_reader :platform_name

    # A reference to the platform Agent Management System (AMS)
    attr_reader :ams

    # A reference to the platform Directory Facilitator (DF)
    attr_reader :df

    # A reference to the Logger instance.
    attr_reader :logger

    # A reference to the platform Agent Communication Channel (ACC)
    attr_reader :acc
    
    # A reference to the main container for this platform
    attr_reader :main_container
    
    #
    # Return an initialized Container
    #
    def initialize(params={})
      @logger = Logger.new(STDOUT)
      establish_main_container(params)
      if main?
        @ams = AgentManagementSystem.new(
          :addresses => agent_transport_addresses,
          :logger => logger
        )
        @df = DirectoryFacilitator.new(
          :logger => logger
        )
        @acc = AgentCommunicationChannel.new(
          :logger => logger,
          :ams => ams
        )
      else
        logger.debug "Obtaining reference to main container AMS..."
        @ams = main_container.ams
        logger.debug "Done obtaining reference to main container AMS."
        logger.debug "Obtaining reference to main container DF..."
        @df = main_container.df # FIXME: broken as of JRuby 0.9.8: see http://jira.codehaus.org/browse/JRUBY-572
        logger.debug "Done obtaining reference to main container DF."
        logger.debug "Obtaining reference to main container ACC..."
        @acc = main_container.acc
        logger.debug "Done obtaining reference to main container ACC."
      end
      @config = params[:config] || "rage.yaml"
    end
    
    #
    # Start running.
    #
    def run
      # Create main container agents
      if main?
        create_ams_agent
        create_df_agent
      end
      
      # Create agents listed in configuration file
      if File.exist?(@config)
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
      
      # Start (invoke) all agents for this container
      ams.invoke_all_agents
      
      # Start the dashboard
#     start_dashboard
      
      Thread.list.each { |t| t.join if t != Thread.main }

    end
    
  private
  
    #
    # Return a Class given its name, borrowed from http://www.rubygarden.org/ruby?FindClassesByName.
    #
    def get_class(name)
      name.split(/::/).inject(Object) { |p, n| p.const_get(n) }  
    end

    def start_dashboard
      require 'rage/web/dashboard'
      Thread.new { RAGE::Web::Server.new.start }
    end
    
    # Return the hostname for this machine
    def hostname
      Socket.gethostname
    end
    
    # Return an array containing the transport addresses for this platform
    def agent_transport_addresses
      [ @address ]
    end
    
    # Return the fully qualified agent name for the given nickname
    def fully_qualified_agent_name(nickname)
      "#{nickname}@#{platform_name}"
    end
    
    # Return true if this is the main container for the platform
    def main?
      main_container == self
    end
    
    # Return a new instance of AMSAgent for this platform
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
    
    # Return a new instance of DFAgent for this platform
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

    def default_container_name
      if main?
        "Main-Container"
      else
        "Container-1" # FIXME
      end
    end
    
    def establish_main_container(params)
      if params[:container]
        host = params[:host] || "localhost" # FIXME: use hostname instead of localhost?
        port = params[:port] || 9001
        DRb.start_service
        @address = "druby://#{host}:#{port}"
        @main_container = DRbObject.new(nil, @address)
        @platform_name = "#{host}:#{port}/RAGE"
      else
        host = params[:local_host] || "localhost" # FIXME: use hostname instead of localhost?
        port = params[:local_port] || 9001
        @address = "druby://#{host}:#{port}"
        DRb.start_service(@address, self)
        @main_container = self
        @platform_name = "#{host}:#{port}/RAGE"
      end
      @container_name = params[:container_name] || default_container_name
      logger.info "Agent container #{container_name}@#{platform_name} is ready."
    end
    
  end # class Container
  
end # module RAGE
