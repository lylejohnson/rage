require 'rage/agent'
require 'rage/message'
require 'rage/platform'

# Bob is the seller
class Bob < RAGE::Agent
  
  def initialize(params={})
    super
  end
  
  def register_capabilities
    service_description = RAGE::ServiceDescription.new(
      :name => "Bob's Books",
      :type => "bookseller"
    )
    agent_description = RAGE::DFAgentDescription.new(
      :name => aid,
      :services => [service_description]
    )
    df.register(agent_description)
  end
  
  def run
    sleep 10
    register_capabilities
    loop do
      # do something
    end
  end

end

class Sam < RAGE::Agent
  
  def initialize(params={})
    super
  end
  
  def run
    loop do
      sellers = lookup_booksellers
      unless sellers.empty?
        logger.info "Found a bookseller!"
        contact_booksellers(sellers)
      else
        logger.info "No booksellers available, sleeping..."
        sleep 5
      end
    end
  end
  
  def lookup_booksellers
    service_description = RAGE::ServiceDescription.new(:type => "bookseller")
    agent_description = RAGE::DFAgentDescription.new(:services => [service_description])
    df.search(agent_description)
  end
  
  def contact_booksellers(agents)
    msg = RAGE::Message.new(
      :performative => "query", 
      :sender => aid.name,
      :content => "content goes here"
    )
    agents.each do |agent|
      msg.receiver = agent.name
      send_message(msg)
    end
  end

end

if __FILE__ == $0
  
  RAGE::Platform.new(:config => "example.yaml").run
  Thread.list.each { |t| t.join if t != Thread.main }
 
end