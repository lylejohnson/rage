require 'test/unit'
require 'rage/xmlcodec'

class TC_XMLCodec < Test::Unit::TestCase
  def test_decode
    src = File.open("fipaMessageExample.xml").read
    msg = RAGE::XMLCodec.new.decode(src)
    assert_equal("confirm", msg.performative)
#   assert_equal("some conversation id", msg.conversation_id)
    assert_equal(1, msg.receivers.length)
    assert_equal("some agent id", msg.receiver.name)
    assert_equal("http://foo.com/receiver", msg.receiver.address)
#   assert_equal("blabla user-defined1", msg.receiver.user_defined)
    assert_equal("some ref to an agent id", msg.sender.name)
    assert_equal("http://foo.com/sender", msg.sender.address)
#   assert_equal("blabla user-defined2", msg.sender.user_defined)
    assert_equal("some contenturl", msg.content)
    assert_equal("some languageurl", msg.language)
    assert_equal("some encoding url", msg.encoding)
    assert_equal("some ontologi url", msg.ontology)
    assert_equal("some protocol url", msg.protocol)
    assert_equal("reply-with url", msg.reply_with)
    assert_equal("in reply-to url", msg.in_reply_to)
    assert_equal("sometime..", msg.reply_by.time)
    assert_equal("some reply-by url", msg.reply_by.url)
    assert_equal(1, msg.reply_to.length)
    assert_equal("some ref to an agent id that receives..", msg.reply_to.first.name)
    assert_equal("http://foo.com/reply-to", msg.reply_to.first.address)
#   assert_equal("blabla user-defined2", msg.reply_to.first.user_defined)
    assert_equal("some conversation id url", msg.conversation_id)
  end
end

