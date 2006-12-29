require 'test/unit'
require 'rage/slcodec'

class TC_SLCodec < Test::Unit::TestCase

  def test_decode
    src = <<END
      (
        (action
          (agent-identifier :name j)
          (deliver box017 (loc 12 19))
        )
        (priority order567 low)
      )
END
    content = RAGE::SLCodec.new.decode(src)
    assert_equal(2, content.expressions.length)
    action = content.expressions.shift
    assert_kind_of(RAGE::ActionExpression, action)
    assert_equal("j", action.agent) # the (agent-identifier :name j) is a FunctionalTerm, (FunctionSymbol ParameterName ParameterValue)
    proposition = content.expressions.shift
    assert_kind_of(RAGE::Proposition, proposition)
    assert_equal("priority", proposition)
  end

end

