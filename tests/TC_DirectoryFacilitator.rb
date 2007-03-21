require 'flexmock'
require 'rage/aid'
require 'rage/df'
require 'test/unit'

class TC_DirectoryFacilitator < Test::Unit::TestCase
  
  include FlexMock::TestCase
  
  private
  
  def sample_agent_identifier
    agent_identifier = RAGE::AgentIdentifier.new(
      :name => 'cameraproxy1@foo.com',
      :addresses => [ 'iiop://foo.com/acc' ]
    )
  end
  
  def sample_service_1
    RAGE::ServiceDescription.new(
      :name => 'description-delivery-1',
      :type => 'description-delivery',
      :ontologies => [ 'traffic-surveillance-domain' ],
      :properties => { 'camera-id' => 'camera1', 'baud-rate' => '1' },
      :languages => [ 'fipa-sl', 'fipa-sl1' ]
    )
  end
  
  def sample_service_2
    RAGE::ServiceDescription.new(
      :name => 'agent-feedback-information-1',
      :type => 'agent-feedback-information',
      :ontologies => [ 'traffic-surveillance-domain' ],
      :properties => { 'camera-id' => 'camera1' }
    )
  end
  
  def sample_entry
    entry = RAGE::DFAgentDescription.new(
      :name => sample_agent_identifier,
      :services => [ sample_service_1, sample_service_2 ],
      :protocols => [ 'fipa-request', 'fipa-query' ],
      :ontologies => [ 'traffic-surveillance-domain', 'fipa-agent-management' ],
      :languages => [ 'fipa-sl' ]
    )
  end
  
  public
  
  def setup
    mock_logger = flexmock("logger")
    mock_logger.should_receive(:info)
    @df = RAGE::DirectoryFacilitator.new(:logger => mock_logger)
    @df.register(sample_entry)
  end

  def test_search
    desired_service = RAGE::ServiceDescription.new(
      :type => 'description-delivery',
      :ontologies => [ 'traffic-surveillance-domain' ],
      :properties => { 'camera-id' => 'camera1' },
      :languages => [ 'fipa-sl' ]
    )
    pattern = RAGE::DFAgentDescription.new(
      :services => [ desired_service ]
    )
    results = @df.search(pattern)
    assert_equal(1, results.size)
  end
  
  def test_modify
    entry = sample_entry
    entry.services.pop
    @df.modify(entry)
    results = @df.search(RAGE::DFAgentDescription.new(:name => sample_agent_identifier))
    assert_equal(1, results.length)
  end
  
  def test_deregister
    search_entry = RAGE::DFAgentDescription.new(:name => sample_agent_identifier)
    results = @df.search(search_entry)
    assert_equal(1, results.length)
    @df.deregister(search_entry)
    results = @df.search(search_entry)
    assert_equal(0, results.length)
  end
  
  def test_new_with_service
    s = sample_service_1
    desc = RAGE::DFAgentDescription.new(:service => s)
    assert_equal(1, desc.services.length)
    assert_equal(s, desc.services.first)
    assert_equal(s, desc.service)
  end
  
  def test_new_with_protocol
    desc = RAGE::DFAgentDescription.new(:protocol => "fipa-request")
    assert_equal(1, desc.protocols.length)
    assert_equal("fipa-request", desc.protocols.first)
    assert_equal("fipa-request", desc.protocol)
  end
  
  def test_new_with_ontology
    desc = RAGE::DFAgentDescription.new(:ontology => "http://www.example.org/example.owl")
    assert_equal(1, desc.ontologies.length)
    assert_equal("http://www.example.org/example.owl", desc.ontologies.first)
    assert_equal("http://www.example.org/example.owl", desc.ontology)
  end
  
  def test_new_with_language
    desc = RAGE::DFAgentDescription.new(:language => "sparql")
    assert_equal(1, desc.languages.length)
    assert_equal("sparql", desc.languages.first)
    assert_equal("sparql", desc.language)
  end

end
