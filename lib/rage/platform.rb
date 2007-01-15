require 'rage/acc'
require 'rage/ams'
require 'rage/df'

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

    # A reference to the Agent Communication Channel (ACC) for this Agent Platform
    attr_reader :acc

    #
    # Return an initialized Platform instance.
    #
    def initialize(params={})
      # Initialize standard services
      @logger = Logger.new(STDOUT)
      @ams = AgentManagementSystem.new(:logger => logger)
      @df = DirectoryFacilitator.new(:logger => logger)
      @acc = AgentCommunicationChannel.new(:logger => logger, :ams => ams)
      @config = params[:config] || "rage.yaml"
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
      # Start up agents listed in configuration file
      if File.exist?(@config)
        startup = YAML::load(File.open(@config, "r"))
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
          agent = agentClass.new(:ams => ams, :df => df, :acc => acc, :logger => logger, :name => agentName)
          Thread.new { agent.run }
        end
      end
    end
    
  end # class Platform
  
end # module RAGE

if __FILE__ == $0
  RAGE::Platform.new.run
  Thread.list.each { |t| t.join if t != Thread.main }
end

