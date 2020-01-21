module Molinillo
  # A state that a {Resolution} can be in
  # @attr [String] name the name of the current requirement
  # @attr [Array<Object>] requirements currently unsatisfied requirements
  # @attr [DependencyGraph] activated the graph of activated dependencies
  # @attr [Object] requirement the current requirement
  # @attr [Object] possibilities the possibilities to satisfy the current requirement
  # @attr [Integer] depth the depth of the resolution
  # @attr [Hash] conflicts unresolved conflicts, indexed by dependency name
  # @attr [Array<UnwindDetails>] unused_unwind_options unwinds for previous conflicts that weren't explored
  class ResolutionState(R, S)
    property name : String?
    property requirements : Array(R)
    property activated : DependencyGraph(Resolver::PosibilitySet(R, S)?, R)
    property requirement : R?
    property possibilities : Array(S)
    property depth : Int32
    property conflicts : Hash(String, Nil)
    property unused_unwind_options : Array(Nil)

    def initialize(@name, @requirements, @activated, @requirement,
                   @possibilities, @depth, @conflicts, @unused_unwind_options)
    end

    # Returns an empty resolution state
    # @return [ResolutionState] an empty state
    def self.empty
      new(nil, Array(R).new, DependencyGraph(Resolver::PosibilitySet(R, S)?, R).new, nil,
        Array(S).new, 0, Hash(String, Nil).new, Array(Nil).new)
    end
  end

  # A state that encapsulates a set of {#requirements} with an {Array} of
  # possibilities
  class DependencyState(R, S) < ResolutionState(R, S)
    # Removes a possibility from `self`
    # @return [PossibilityState] a state with a single possibility,
    #  the possibility that was removed from `self`
    def pop_possibility_state
      PossibilityState(R, S).new(
        name,
        requirements.dup,
        activated,
        requirement,
        [possibilities.pop],
        depth + 1,
        conflicts.dup,
        unused_unwind_options.dup
      ).tap do |state|
        state.activated.tag(state)
      end
    end
  end

  # A state that encapsulates a single possibility to fulfill the given
  # {#requirement}
  class PossibilityState(R, S) < ResolutionState(R, S)
  end
end
