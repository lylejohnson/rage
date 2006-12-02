module RAGE
  class Behavior
    # The agent this behavior belongs to.
    attr_reader :agent

    # A reference to the enclosing behavior (if present).
    attr_reader :parent

    # The name for this behavior instance.
    attr_accessor :name

    #
    # Return an initialized Behavior instance.
    #
    def initialize(agent)
      @agent = agent
      @parent = nil
    end
    
    #
    # Runs the behavior.
    #
    def action
    end
    
    #
    # Blocks this behavior.
    #
    def block(millis=nil)
    end
    
    #
    # Return +true+ if this behavior is not currently blocked.
    #
    def runnable?
    end

    #
    # Return if this behavior is done.
    #
    def done?
    end
  end
  
  #
  # An atomic behavior.
  # This abstract class models behaviors that are made by a single, monolithic
  # task and cannot be interrupted.
  #
  class SimpleBehavior < Behavior
    #
    # Return an initialized CompositeBehavior instance.
    #
    def initialize(agent)
      super(agent)
    end
  end

  #
  # Atomic behavior that must be executed forever.
  # This abstract class can be extended by application programmers to create
  # behaviors that keep executing continuously (e.g. simple reactive behaviors).
  #
  class CyclicBehavior < SimpleBehavior
    #
    # Return an initialized CyclicBehavior instance.
    #
    def initialize(agent)
      super(agent)
    end

    #
    # This is the method that makes CyclicBehavior cyclic, because it always
    # returns +false+.
    #
    def done?
      false
    end
  end

  #
  # This abstract class implements a behavior that periodically executes a
  # user-defined piece of code. The user is expected to extend this class
  # re-defining the method tick() and including the piece of code that must
  # be periodically executed into it.
  #
  class TickerBehavior < SimpleBehavior
    #
    # Return an initialized TickerBehavior instance.
    #
    def initialize(agent, period)
      @period = period
    end
    
    #
    # Subclasses are expected to define this method specifying the action that
    # must be performed at every tick.
    #
    def tick
    end
  end

  #
  # An abstract superclass for behaviors composed by many parts.
  # This class holds inside a number of child behaviors.
  # When a CompositeBehavior receives its execution quantum from the agent
  # scheduler, it executes one of its children according to some policy. This
  # class must be extended to provide the actual scheduling policy to apply
  # when running child behaviors.
  #
  class CompositeBehavior < Behavior
    #
    # Return an initialized CompositeBehavior instance.
    #
    def initialize(agent)
      super(agent)
    end
  end
end

