require 'test/unit'
require 'rage/stringcodec'

class TC_StringCodec < Test::Unit::TestCase
  def test_encode
    msg = RAGE::ACLMessage.new
    msg.performative = "request"
    msg.sender = RAGE::AgentIdentifier.new(:name => "dummy@foo.com", :addresses => ["iiop://foo.com/acc"])
    msg.receivers << RAGE::AgentIdentifier.new(:name => "ams@foo.com", :addresses => ["iiop://foo.com/acc"])
    msg.language = "fipa-sl0"
    msg.protocol = "fipa-request"
    msg.ontology = "fipa-agent-management"
    str = RAGE::StringCodec.new.encode(msg)
  end

  def test_decode1
    src = File.open("request-message-1.txt").read
    msg = RAGE::StringCodec.new.decode(src)
    assert_equal("request", msg.performative)

    assert_equal("dummy@foo.com", msg.sender.name)
    assert_equal("iiop://foo.com/acc", msg.sender.address)

    assert_equal(1, msg.receivers.length)
    assert_equal("ams@foo.com", msg.receiver.name)
    assert_equal(1, msg.receiver.addresses.length)
    assert_equal("iiop://foo.com/acc", msg.receiver.address)
    
    assert_equal("fipa-sl0", msg.language)
    assert_equal("fipa-request", msg.protocol)
    assert_equal("fipa-agent-management", msg.ontology)
  end
end

