module ChessRules
  Move = Struct.new(:colour, :before, :after) 
  MoveFnMap = {}
  PieceCostMap = {}
  SymbolMap =  {}

  #Finds the move associated to the chess notation
  def ChessRules.find_move(board, type, after_pos, colour)
    focus = board.select { |k,v| v && v.name == type }
    focus.each do |before, value|
      moves = MoveFnMap[type].call(before, colour)
      moves.each do |after|
        return Move.new(colour, before, after) if after_pos == after
      end
    end

    return nil
  end

  def ChessRules.inverse(colour)
    return :black if colour == :white
    return :white
  end

  #Checks if move is a valid move on the board.
  def ChessRules.valid_move(move, board)
    return false if board[move.before].nil?

    piece = board[move.before].name
    return true if piece == :knight || piece == :pawn || piece == :king #shortcircuit
    curW, curH = [0,0]

    new_pos = move.before
    while new_pos != move.after
      #Move closer to move.after
      curW += 1 if new_pos[0] < move.after[0]
      curW -= 1 if new_pos[0] > move.after[0]
      curH += 1 if new_pos[1] < move.after[1]
      curH -= 1 if new_pos[1] > move.after[1]

      new_pos = (move.before[0].ord + curW).chr + (move.before[1].ord + curH).chr 
      if !valid_pos(new_pos) || board[new_pos]
        return false
      end
    end

    return true
  end

  #Checks if pos is valid
  def ChessRules.valid_pos(pos)
    return ('a'..'h').member?(pos[0]) && ('1'..'8').member?(pos[1])
  end
  #Filters invalid positions
  def ChessRules.filter_pos(arr)
    arr.select! do |pos|
      valid_pos(pos)
    end
    return arr
  end

  def ChessRules.init()
    #MoveFnMap is a hashmap of lambda functions that take in a position, and returns all possible 
    #positions the piece can perform. Position: x, y, where x is (a..h) and y is (1..8)
    MoveFnMap[:pawn] =  -> (pos, colour=:white) do  #Relative to white player!
      #filter_pos([pos[0]+pos[1].next, pos[0] + pos[1].next.next])
      [pos[0] + pos[1].next ]
    end

    MoveFnMap[:knight] = -> (pos, colour=:white) do
      ret = [pos[0].next.next + pos[1].next, pos[0].next.next + (pos[1].ord - 1).chr,
      (pos[0].ord - 2).chr + pos[1].next, (pos[0].ord - 2).chr + (pos[1].ord - 1).chr,
      pos[0].next + pos[1].next.next, (pos[0].ord - 1).chr + pos[1].next.next,
      pos[0].next + (pos[1].ord - 2).chr, (pos[0].ord - 1).chr + (pos[1].ord - 2).chr]
      filter_pos(ret)
    end

    MoveFnMap[:rook] = -> (pos,colour=:white) do
      ret = []
      ('a'..'h').each { |c| ret << c + pos[1] if c != pos[0] }
      ('1'..'8').each { |i| ret << pos[0] + i.chr if i.chr != pos[1] }
      filter_pos(ret)
    end
    
    MoveFnMap[:bishop] = -> (pos,colour=:white) do 
      ret = []
      w,h = pos.split("") #w = (a..h), h = (1..8)
      ctr = 1

      while valid_pos(w + h)
        w = (w.ord + 1).chr
        ret << w + (h.ord + ctr).chr
        ret << w + (h.ord - ctr).chr
        ctr += 1
      end
      w,h = pos.split("") #reset
      ctr = 1
      while valid_pos(w + h)
        w = (w.ord - 1).chr
        ret << w + (h.ord + ctr).chr
        ret << w + (h.ord - ctr).chr
        ctr += 1
      end
      filter_pos(ret)
    end

    MoveFnMap[:queen] = -> (pos,colour=:white) do 
      filter_pos(MoveFnMap[:bishop].call(pos) + MoveFnMap[:rook].call(pos)) 
    end

    MoveFnMap[:king] = -> (pos,colour=:white) do
      ret = []
      (-1..1).each do |x| 
        (-1..1).each do |y| 
          ret << ((pos[0].ord + x).chr + (pos[1].ord + y).chr) if x != 0 || y != 0
        end
      end
      filter_pos(ret)
    end
    PieceCostMap[:pawn] = 1
    PieceCostMap[:king] = 1000
    PieceCostMap[:queen] = 9
    PieceCostMap[:knight] = 3
    PieceCostMap[:bishop] = 3
    PieceCostMap[:rook] = 5

    SymbolMap["K"] = :king
    SymbolMap["Q"] = :queen
    SymbolMap["R"] = :rook
    SymbolMap["N"] = :knight
    SymbolMap["S"] = :knight
    SymbolMap["B"] = :bishop
  end
end