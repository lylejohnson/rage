require 'test/unit'
require 'rage/df'

class TC_ServiceDescription < Test::Unit::TestCase
  
  def test_matches?
    pattern = RAGE::ServiceDescription.new(
      :type => 'description-delivery',
      :ontologies => [ 'traffic-surveillance-domain' ],
      :properties => { 'camera-id' => 'camera1' },
      :languages => [ 'fipa-sl' ]
    )
    sample1 = RAGE::ServiceDescription.new(
      :name => 'description-delivery-1',
      :type => 'description-delivery',
      :ontologies => [ 'traffic-surveillance-domain' ],
      :properties => { 'camera-id' => 'camera1', 'baud-rate' => '1' },
      :languages => [ 'fipa-sl', 'fipa-sl1' ]
    )
    sample2 = RAGE::ServiceDescription.new(
      :name => 'agent-feedback-information-1',
      :type => 'agent-feedback-information',
      :ontologies => [ 'traffic-surveillance-domain' ],
      :properties => { 'camera-id' => 'camera1' }
    )
    assert(sample1.matches?(pattern))
    assert(!sample2.matches?(pattern))
  end
  
  def test_new_with_ontology
    s = RAGE::ServiceDescription.new(:ontology => "http://www.example.org/example.owl")
    assert_equal(1, s.ontologies.length)
    assert_equal("http://www.example.org/example.owl", s.ontologies.first)
    assert_equal("http://www.example.org/example.owl", s.ontology)
  end
  
  def test_new_with_language
    s = RAGE::ServiceDescription.new(:language => "sparql")
    assert_equal(1, s.languages.length)
    assert_equal("sparql", s.languages.first)
    assert_equal("sparql", s.language)
  end
  
  def test_new_with_protocol
    s = RAGE::ServiceDescription.new(:protocol => "fipa-query")
    assert_equal(1, s.protocols.length)
    assert_equal("fipa-query", s.protocols.first)
    assert_equal("fipa-query", s.protocol)
  end

end

