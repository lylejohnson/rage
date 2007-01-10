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

end

