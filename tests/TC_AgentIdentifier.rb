require 'rage/aid'
require 'test/unit'

class TC_AgentIdentifier < Test::Unit::TestCase
  
  def test_new_with_no_args
    aid = RAGE::AgentIdentifier.new
    assert_not_nil(aid)
    assert_nil(aid.name)
    assert_equal([], aid.addresses)
    assert_equal([], aid.resolvers)
  end
  
  def test_eql_same_names
    aid1 = RAGE::AgentIdentifier.new(:name => "Sam", :addresses => [ "http://www.sentar.com/Sam" ])
    aid2 = RAGE::AgentIdentifier.new(:name => "Sam", :addresses => [ "http://www.sentar.com/Sammy" ])
    assert aid1.eql?(aid2)
  end
  
  def test_eql_different_names
    aid1 = RAGE::AgentIdentifier.new(:name => "Sam")
    aid2 = RAGE::AgentIdentifier.new(:name => "Bob")
    assert !aid1.eql?(aid2)
  end

end

