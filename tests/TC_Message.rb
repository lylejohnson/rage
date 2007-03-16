require 'test/unit'
require 'rage/Message'

class TC_Message < Test::Unit::TestCase
  
  def test_nil_performative
    assert_raises(ArgumentError) { RAGE::Message.new }
    assert_raises(ArgumentError) { RAGE::Message.new(:performative => nil) }
  end
  
  def test_bad_performative
    msg = RAGE::Message.new(:performative => "query-ref")
    assert_nothing_raised        { msg.performative = "cfp" }
    assert_raises(ArgumentError) { msg.performative = "foo" }
  end
  
end

