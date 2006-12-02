module RAGE
  class IdentifyingExpression
  
    attr_reader :op

    def initialize(op)
      @op = op
    end
  end

  class ActionExpression
  end
  
  class BasicActionExpression < ActionExpression
  end
  
  class ActionExpressionSequence < ActionExpression
    def initialize(first, last)
      @actions  = [first, last]
    end
  end
  
  class ActionExpressionAlternative < ActionExpression
    def initialize(first, last)
      @actions  = [first, last]
    end
  end

  class Proposition
  end

  class Content
    attr_reader :expressions

    #
    # Return an initialized Content instance.
    #
    def initialize
      @expressions = []
    end
    
    #
    # Add an expression to the content.
    #
    def add_expression(expr)
      @expressions << expr
    end
    
    #
    # Iterate over all of the expressions.
    #
    def each_expression(&blk)
      expressions.each(&blk)
    end
  end
end

