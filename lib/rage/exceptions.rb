module RAGE

  # Corresponds to the failure message sent from one agent to another
  class FailureError < RuntimeError
    
    attr_reader :predicate_symbol

    def initialize(predicate_symbol)
      @predicate_symbol
    end
    
  end # class FailureError
  
  # Corresponds to a not-understood message sent from one agent to another
  class NotUnderstoodError < RuntimeError
  end # class NotUnderstoodError
  
  class StateTransitionError < RuntimeError
    
    attr_reader :old_state
    attr_reader :new_state

    def initialize(old_state, new_state)
      @old_state = old_state
      @new_state = new_state
    end

  end # class StateTransitionError
  
end
