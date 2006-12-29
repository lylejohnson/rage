module RAGE

  class AgentIdentifier

    # The symbolic name of the agent (a string)
    attr_reader :name

    #
    # Return an initialized agent identifier.
    #
    def initialize(params)
      @name = params[:name]
      @addresses = params[:addresses] || []
      @resolvers = params[:resolvers] || []
    end
    
    #
    # Return an ordered list of addresses where the agent can be contacted.
    #
    def addresses
      @addresses
    end

    #
    # Iterate over the addresses.
    #
    def each_address(&blk) # :yields: url
      addresses.each(&blk)
    end

    #
    # Return the first address (if any), or +nil+ if no addresses
    # specified.
    #
    def address
      unless addresses.empty?
        addresses.first
      else
        nil
      end
    end

    #
    # Return an ordered list of addresses where the agent can be contacted.
    #
    def resolvers
      @resolvers
    end
    
    #
    # Iterate over the resolvers.
    #
    def each_resolver(&blk) # :yields: anAID
      resolvers.each(&blk)
    end
    
    #
    # Return the first resolver (if any), or +nil+ if no resolvers
    # specified.
    #
    def resolver
      unless resolvers.empty?
        resolvers.first
      else
        nil
      end
    end
    
    # Return +true+ if this agent identifier matches the pattern.
    def matches?(pattern)
      return false if (pattern.name && self.name != pattern.name)
      pattern.addresses.each do |address_pattern|
        return false unless self.addresses.include? address_pattern
      end
      pattern.resolvers.each do |resolver_pattern|
        this_pattern_matched = false
        self.resolvers.each do |resolver|
          if resolver.matches? resolver_pattern
            this_pattern_matched = true
            break
          end
        end
        return false unless this_pattern_matched
      end
    end
    
  end # class AgentIdentifier
  
end # module RAGE

