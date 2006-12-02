require 'rage/ams'
require 'rage/df'
require 'rage/mts'

require 'yaml'
require 'logger'

module RAGE
  class Platform

    # A reference to the Agent Management System (AMS)
    attr_reader :ams
    
    # A reference to the Directory Facilitator (DF) for this Agent Platform.
    attr_reader :df
    
    # A reference to the Logger instance.
    attr_reader :logger
    
    # A reference to the message transport system (MTS)
    attr_reader :mts

    #
    # Return an initialized Platform instance.
    #
    def initialize
      # Initialize standard services
      @ams = AgentManagementSystem.new
      @df = DirectoryFacilitator.new
      @mts = MessageTransportSystem.new
      @logger = Logger.new("rage.log")
    end

    #
    # Return a Class given its name, borrowed from http://www.rubygarden.org/ruby?FindClassesByName.
    #
    def get_class(name)
      name.split(/::/).inject(Object) { |p, n| p.const_get(n)}  
    end

    private :get_class

    #
    # Start running.
    #
    def run
      # Start up agents listed in configuration file
      if File.exist?("rage.yml")
        startup = YAML::load(File.open("rage.yml", "r"))
	startup.each do |description|
	  agentName = description["name"]
	  agentSrc = description["src"]
	  src = File.open(agentSrc).read
          load agentSrc
	  agentClass = nil
	  begin
	    className = description["classname"]
	    agentClass = get_class(className)
	  rescue NameError
	    logger.error "Couldn't instantiate an agent of class #{className}"
	  end
	  agent = agentClass.new
	  @ams.register(agent, agentName)
	  Thread.new { agent.run }
	end
      end
    end
  end
end

if __FILE__ == $0
  RAGE::Platform.new.run
  Thread.list.each { |t| t.join if t != Thread.main }
end

