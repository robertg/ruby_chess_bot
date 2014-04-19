module MoveMap
  Map = {}
  #Filters invalid positions
  def filter_pos(arr)
    arr.select! do |pos|
      return true if pos[0] === ('a'..'h') && Integer(pos[1]) === (1..8)
      return false
    end
    return arr
  end

  def initialize
    #Map is a hashmap of lambda functions that take in a position, and returns all new positions.
    #Position: x, y, where x is (a..h) and y is (1..8)
    #This map is relative to the White player.
    Map[:pawn] =  -> (pos) do 
      filter_pos([pos[0]+pos[1].next])
    end

    Map[:rook] = -> (pos) do
      ret = []
      ('a'..'h').each { |c| ret << c + pos[1] if c != pos[0] }
      (1..8).each { |i| ret << pos[0] + pos[1].to_str if i != Integer(pos[1]) }
      filter_pos(ret)
    end

    Map[:knight] = -> (pos) do

    end

    Map[:bishop] = -> (pos) do 

    end

    Map[:queen] = -> (pos) { Map[:bishop].call(pos) + Map[:rook].call(pos) }

    Map[:king] = -> (pos) {}
  end
end

module Chess

  class StateNode
    attr_accessor :move :left :right :state
    def initialize(move:nil, state: nil)
      @move = value
      @children = []
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
      #We add only what is new, just in case the state_delta contains less info...
      (@board_state.length...state_delta.length).each do |i| 
        @board_state << state_delta[i]
      end
    end

    def decide_best_move()

    end

    private :decide_best_move 
  end
end