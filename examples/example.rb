require 'rage/agent'
require 'rage/message'
require 'rage/platform'

# Bob is the seller
class Bob < RAGE::Agent
  
  def initialize(params={})
    super
    add_behavior {
      Thread.new do
        sleep 10
        register_capabilities
      end
    }
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
  
  def handle_query(msg)
    logger.info "#{name} received message with content: #{msg.content}"
  end
  
end

class Sam < RAGE::Agent
  
  def initialize(params={})
    super
    add_behavior {
      Thread.new do
        loop do
          sellers = lookup_booksellers
          unless sellers.empty?
            logger.info "Found a bookseller!"
            contact_booksellers(sellers)
            break
          else
            logger.info "No booksellers available, sleeping..."
            sleep 5
          end
        end
      end
    }
  end
  
  def lookup_booksellers
    service_description = RAGE::ServiceDescription.new(:type => "bookseller")
    agent_description = RAGE::DFAgentDescription.new(:services => [service_description])
    df.search(agent_description)
  end
  
  def contact_booksellers(agent_descriptions)
    msg = RAGE::Message.new(
      :performative => "query", 
      :sender => aid,
      :receivers => agent_descriptions.map { |x| x.name },
      :content => "content goes here"
    )
    send_message(msg)
  end

end

if __FILE__ == $0
  
  RAGE::Platform.new(:config => "example.yaml").run
  Thread.list.each { |t| t.join if t != Thread.main }
 
end