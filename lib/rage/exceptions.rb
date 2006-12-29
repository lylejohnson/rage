module RAGE

  class FailureException < RuntimeError
    
    attr_reader :predicate_symbol

    def initialize(predicate_symbol)
      @predicate_symbol
    end
    
  end
  
end
