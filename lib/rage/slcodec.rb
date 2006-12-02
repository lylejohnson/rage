require 'rage/content'
require 'rage/npreader'

module RAGE
  class SLCodec
    def decode_action_expression(node)
      val = node.values.shift
      case val
        when "action"
          act = BasicActionExpression.new
          act
        when "|"
          act1 = decode_action_expression(node.values.shift)
          act2 = decode_action_expression(node.values.shift)
          ActionExpressionAlternative.new(act1, act2)
        when ";"
          act1 = decode_action_expression(node.values.shift)
          act2 = decode_action_expression(node.values.shift)
          ActionExpressionSequence.new(act1, act2)
      end
    end
    
    def decode_identifying_expression(node)
      ie = IdentifyingExpression.new(node.values.shift)
      ie
    end
    
    def decode_atomic_formula
    end

    def decode_proposition(node)
      proposition = Proposition.new
      proposition
    end

    def decode_term_or_ie(node)
      case node
        when NPNode
          case node.values.first
            when "iota", "any", "all"
              decode_identifying_expression(node)
            else
              # could be FunctionalTerm, ActionExpression, Sequence, Set
          end
        else
          # could be Variable or Constant
      end
    end

    private :decode_action_expression
    private :decode_identifying_expression
    private :decode_proposition
    private :decode_term_or_ie

    #
    # Return a new Content instance.
    #
    def decode(src)
      content = Content.new
      parser = NPReader.new
      ast = parser.parse(src)
      ast.values.each do |val|
        case val
          when NPNode
            case val.values.first
              when "action", "|", ";"
                content.add_expression(decode_action_expression(val))
              when "iota", "any", "all"
                content.add_expression(decode_identifying_expression(val))
              else
                content.add_expression(decode_proposition(val))
            end
          else
            # String
        end
      end
      content
    end
  end
end

