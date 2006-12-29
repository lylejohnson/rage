require 'test/unit'
require 'rage/aid'
require 'rage/df'

class TC_DFAgentDescription < Test::Unit::TestCase
  
  def setup
  end

  def sample_entry
    agent_identifier = RAGE::AgentIdentifier.new(
      :name => 'cameraproxy1@foo.com',
      :addresses => [ 'iiop://foo.com/acc' ]
    )
    service1 = RAGE::ServiceDescription.new(
      :name => 'description-delivery-1',
      :type => 'description-delivery',
      :ontologies => [ 'traffic-surveillance-domain' ],
      :properties => { 'camera-id' => 'camera1', 'baud-rate' => '1' },
      :languages => [ 'fipa-sl', 'fipa-sl1' ]
    )
    service2 = RAGE::ServiceDescription.new(
      :name => 'agent-feedback-information-1',
      :type => 'agent-feedback-information',
      :ontologies => [ 'traffic-surveillance-domain' ],
      :properties => { 'camera-id' => 'camera1' }
    )
    entry = RAGE::DFAgentDescription.new(
      :name => agent_identifier,
      :services => [ service1, service2 ],
      :protocols => [ 'fipa-request', 'fipa-query' ],
      :ontologies => [ 'traffic-surveillance-domain', 'fipa-agent-management' ],
      :languages => [ 'fipa-sl' ]
    )
  end
  
  def sample_pattern
    desired_service = RAGE::ServiceDescription.new(
      :type => 'description-delivery',
      :ontologies => [ 'traffic-surveillance-domain' ],
      :properties => { 'camera-id' => 'camera1' },
      :languages => [ 'fipa-sl' ]
    )
    pattern = RAGE::DFAgentDescription.new(
      :services => [ desired_service ]
    )
  end

  def test_matches
    assert(sample_entry.matches?(sample_pattern))
  end

end
