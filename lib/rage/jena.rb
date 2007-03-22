require 'java'

module RAGE
  
  module Jena
    
    include_class 'com.hp.hpl.jena.db.DBConnection'
    include_class 'com.hp.hpl.jena.rdf.model.ModelFactory'
    
  end # module Jena
  
  module SPARQL
    
    include_class 'com.hp.hpl.jena.query.QueryExecutionFactory'
    include_class 'com.hp.hpl.jena.query.QueryFactory'
    include_class 'com.hp.hpl.jena.query.ResultSetFormatter'
    
  end # module SPARQL
  
end # module RAGE