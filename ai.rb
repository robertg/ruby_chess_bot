module Chess

  class StateNode
    attr_accessor :move :left :right :state
    def initialize(move:nil, state: nil)
      @move = value
      @left = nil
      @right = nil
      @board_state = state
    end
  end

  class AI
    def initialize(depth: 30)
      @depth = depth
      @board_state = nil
    end

    #compute the next move using the state_delta
    def nextmove(state_delta:nil)
      @board_state << state_delta
    end

    def decide_best_move()

    end

    private :decide_best_move 
  end
end
