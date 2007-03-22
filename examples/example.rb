require 'rage/rage'

# Bob is the seller
class Bob < RAGE::Agent
  
  def initialize(params={})
    super
    add_behavior {
      sleep 10
      register_capabilities
    }
  end
  
  def register_capabilities
    service = RAGE::ServiceDescription.new(
      :name => "Bob's Books",
      :type => "bookseller"
    )
    agent_description = RAGE::DFAgentDescription.new(
      :name => aid,
      :services => [ service ]
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
    }
  end
  
  def lookup_booksellers
    service_description = RAGE::ServiceDescription.new(:type => "bookseller")
    agent_description = RAGE::DFAgentDescription.new(:services => [ service_description ])
    df.search(agent_description)
  end
  
  def contact_booksellers(agent_descriptions)
    msg = RAGE::Message.new(
      :performative => "query-if", 
      :receivers => agent_descriptions.map { |x| x.name },
      :content => "content goes here"
    )
    send_message(msg)
  end

end

if __FILE__ == $0
  
  Thread.abort_on_exception = true
  RAGE::Container.new(:container => true, :config => "example.yaml").run
 
end