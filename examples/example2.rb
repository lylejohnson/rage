require 'rage/rage'

class AnswerAgent < RAGE::Agent
  
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
    service = RAGE::ServiceDescription.new(
      :protocol => "fipa-query",
      :ontology => "http://onto.ui.sav.sk/agents.owl",
      :language => "sparql"
    )
    agent_description = RAGE::DFAgentDescription.new(
      :name => aid,
      :service => service
    )
    df.register(agent_description)
  end
  
  def handle_query_ref(msg)

    # Create query from message content
    query = RAGE::SPARQL::QueryFactory.create(msg.content)
    
    # Execute the query and obtain results
    query_execution = RAGE::SPARQL::QueryExecutionFactory.create(query, model)
    results = query_execution.execSelect()
    
    # Output results
    RAGE::SPARQL::ResultSetFormatter.outputAsRDF("TURTLE", results)
    
    # Free up resources used running the query
    query_execution.close
  end
  
end

class AskAgent < RAGE::Agent
  
  def initialize(params={})
    super
    add_behavior {
      Thread.new do
        loop do
          sellers = lookup_booksellers
          unless sellers.empty?
            logger.info "Found a bookseller!"
            ask(sellers.first)
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
    service_description = RAGE::ServiceDescription.new(
      :language => "sparql",
      :ontology => "http://onto.ui.sav.sk/agents.owl"
    )
    agent_description = RAGE::DFAgentDescription.new(:service => service_description)
    df.search(agent_description)
  end
  
  def ask(agent_description)
    query = <<END
PREFIX ont: <http://onto.ui.sav.sk/agents.owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT ?x WHERE { ?x rdf:type ont:Computer }
END
    msg = RAGE::Message.new(
      :performative => "query-ref", 
      :receiver => agent_description.name,
      :content => query,
      :language => "sparql",
      :ontology => "http://onto.ui.sav.sk/agents.owl"
    )
    send_message(msg)
  end

end

if __FILE__ == $0
  
  Thread.abort_on_exception = true
  RAGE::Platform.new(:config => "example2.yaml").run
  Thread.list.each { |t| t.join if t != Thread.main }
 
end