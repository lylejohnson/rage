require 'test/unit'
require 'rexml/document'
require 'time'
require 'rage/envelope'

class TC_Envelope < Test::Unit::TestCase
  def test_from_xml1
    doc = REXML::Document.new(File.open("envelope1.xml"))
    env = RAGE::Envelope.from_xml(doc)
    assert_equal(1, env.receivers.length)
    assert_equal("receiver@foo.com", env.receiver.name)
    assert_equal("http://foo.com/acc", env.receiver.address)
    assert_equal("sender@bar.com", env.sender.name)
    assert_equal("http://bar.com/acc", env.sender.address)
    assert_equal(Time.parse("20000508T042651481"), env.date)
    assert_equal("fipa.acl.rep.xml.std", env.acl_representation)
    assert_equal("http://foo.com/acc", env.received.by)
    assert_equal(Time.parse("20000508T042651481"), env.received.date)
    assert_equal("123456789", env.received.id)
  end

  def test_from_xml2
    doc = REXML::Document.new(File.open("envelope2.xml"))
    env = RAGE::Envelope.from_xml(doc)
    assert_equal(1, env.receivers.length)
    receiver = env.receiver
    assert_equal("receiver@foo.com", receiver.name)
    assert_equal("http://foo.com/acc", receiver.address)
    assert_equal(1, receiver.resolvers.length)
    resolver = receiver.resolver
    assert_equal("resolver@bar.com", resolver.name)
    assert_equal(3, resolver.addresses.length)
    assert_equal("http://bar.com/acc1", resolver.addresses[0])
    assert_equal("http://bar.com/acc2", resolver.addresses[1])
    assert_equal("http://bar.com/acc3", resolver.addresses[2])

    sender = env.sender
    assert_equal("sender@bar.com", sender.name)
    assert_equal("http://bar.com/acc", sender.address)
    assert_equal(1, sender.resolvers.length)
    resolver = sender.resolver
    assert_equal("resolver@foobar.com", resolver.name)
    assert_equal(3, resolver.addresses.length)
    assert_equal("http://foobar.com/acc1", resolver.addresses[0])
    assert_equal("http://foobar.com/acc2", resolver.addresses[1])
    assert_equal("http://foobar.com/acc3", resolver.addresses[2])

    assert_equal("No comments!", env.comments)
    assert_equal("fipa.acl.rep.xml.std", env.acl_representation)
    assert_equal("US-ASCII", env.payload_encoding)
    assert_equal(Time.parse("20000508T042651481"), env.date)

    assert_equal(1, env.intended_receivers.length)
    intended_receiver = env.intended_receiver
    assert_equal("intendedreceiver@foobar.com", intended_receiver.name)
    assert_equal(3, intended_receiver.addresses.length)
    assert_equal("http://foobar.com/acc1", intended_receiver.addresses[0])
    assert_equal("http://foobar.com/acc2", intended_receiver.addresses[1])
    assert_equal("http://foobar.com/acc3", intended_receiver.addresses[2])
    assert_equal(1, intended_receiver.resolvers.length)
    resolver = intended_receiver.resolver
    assert_equal("resolver@foobar.com", resolver.name)
    assert_equal(3, resolver.addresses.length)
    assert_equal("http://foobar.com/acc1", resolver.addresses[0])
    assert_equal("http://foobar.com/acc2", resolver.addresses[1])
    assert_equal("http://foobar.com/acc3", resolver.addresses[2])

    assert_equal("http://foo.com/acc", env.received.by)
    assert_equal("http://foobar.com/acc", env.received.from)
    assert_equal(Time.parse("20000508T042651481"), env.received.date)
    assert_equal("123456789", env.received.id)
    assert_equal("http://bar.com/acc", env.received.via)
  end
  
  def test_to_xml
    env = RAGE::Envelope.new
    env.add_sender("sender@bar.com", "http://bar.com/acc")
    env.add_receiver("receiver@foo.com", "http://foo.com/acc")
    env.acl_representation = "fipa.acl.rep.xml.std"
    env.date = Time.parse("20000508T042651481")
  end
end

