require 'test/unit'
require 'rage/aid'
require 'rage/df'

class TC_DirectoryFacilitator < Test::Unit::TestCase
  
  def setup
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
    @df = RAGE::DirectoryFacilitator.new
    @df.register(entry)
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

end
