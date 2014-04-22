require_relative 'chess_rules'
require_relative 'ext'
require 'json'

module Bot
  Piece = Struct.new(:name, :value, :colour)
  Score = Struct.new(:white, :black) 
  Move = Struct.new(:colour, :before, :after) 
  State = Struct.new(:move, :children, :board, :score) 
  Package = Struct.new(:move, :score) 

  LOW = -100000
  HIGH = 100000

  class AI 
    attr_accessor :depth, :board, :board_state
    def initialize(depth: 10)
      ChessRules.init()

      @board_state = []
      @depth = depth
      @score = Score.new(0,0)
      @board = {} #board is a hashmap
      ('a'..'h').each do |x|
        ('1'..'8').each do |y|
          @board[x + y] = nil
        end
      end
      board_init = JSON.parse(File.new("board_init.json", "r").read)

      board_init.each do |x|
        piece = Piece.new
        piece.name = x["piece"].to_sym
        piece.colour = x["colour"].to_sym
        piece.value = ChessRules::PieceCostMap[piece.name]

        @board[x["position"]] = piece
      end
    end

    #compute the next move using the state_delta
    def next_move(game_state: nil)
      #We add only what is new, just in case the state_delta contains less info...
      new_moves = []
      if @board_state.length < game_state.length
        (@board_state.length...game_state.length).each do |i|  
          @board_state << game_state[i] 
          new_moves << game_state[i]
        end
      end
      moves = translate_acn(new_moves, board)
      update_board(@board, moves, @score)
      return decide_best_move @board, @score, @depth
    end

    def translate_acn(acn_moves, board) #acn_moves in an array of BoardMovements (:color, :movement)
      translated = []
      acn_moves.each do |move|
        #Observe the waterfall of logic
        get_move = nil
        str = move.movement

        str.gsub!(/x/,'')
        str.gsub!(/\+/,'')
        if str.length == 4
            #Handle these later, these are the special conditions of algebriac chess notation
            #cheatography.com/davechild/cheat-sheets/chess-algebraic-notation/
          end
          if str.length == 3
            get_move = ChessRules.find_move(
              board, 
              ChessRules::SymbolMap[str[0]], 
              str[1..2],
              move.colour)
          end
        if str.length == 2 #This is a pawn
          get_move = ChessRules.find_move(board, :pawn, str, move.colour)
        end

        translated << get_move if get_move
      end
      return translated
    end

    def update_board(board, moves, score)
      moves.each do |move|
        to_move = board[move.before]
        dead = board[move.after]

        if !dead.nil?
          if dead.colour == :white
           score.black += dead.value
         else 
          score.white += dead.value
        end
      end

      board[move.after] = to_move
      board[move.before] = nil
      return board
    end
  end

  def decide_best_move(board, score, depth)
    state_tree = construct_state_tree(nil, board, score, depth, :white)
    min_max(state_tree)
  end

  def compare_scores(a,b,focus) 
    return -1 if a[focus] - a[ChessRules::inverse(focus)] < b[focus] - b[ChessRules::inverse(focus)]
    return 0 if a[focus] - a[ChessRules::inverse(focus)] == b[focus] - b[ChessRules::inverse(focus)]
    return 1 # >
  end

  #maximizer is a label that represents the colour that needs to be maximized.
  #this function returns a package
  def min_max(state_root, focus=:white, maximize=true)
    compare = maximize ? -> (a,b) { a < b } : -> (a,b) { a > b }
    ret = nil
    begin
      worst_score = Score.new
      worst_score[focus] = maximize ? LOW : HIGH
      worst_score[ChessRules::inverse(focus)] = maximize ? HIGH : LOW
      ret = Package.new(state_root.move, worst_score)
    end

      #State = Struct.new(:move, :children, :board, :score)
      state_root.children.each do |node|
        if node
          ret = Package.new(node.move, node.score) if 
          compare.call(compare_scores(ret.score, node.score, focus), 0)

          recurse = min_max(node, focus, maximize) 
          ret = Package.new(node.move, recurse.score) if 
          compare.call(compare_scores(ret.score, recurse.score, focus), 0)
        end
      end

      return ret
    end

    def construct_state_tree(move, board, score, depth, colour)
      return nil if depth <= 0
      good_pieces = @board.select { |k,v| v && v.colour == colour }

      state_node = State.new
      state_node.board = board
      state_node.move = move
      state_node.score = score
      state_node.children = []

      good_pieces.each do |position, piece|
        all_moves = ChessRules::MoveFnMap[piece.name].call(position, colour)
        all_moves.each do |after|
          new_move = Move.new(colour, position, after)
          if ChessRules.valid_move(new_move, board)
            score_clone = score.clone

            #Recurse and generate children:
            child = construct_state_tree(
              new_move, 
              update_board(board.deep_dup, [new_move], score_clone),
              score_clone, 
              depth - 1,
              ChessRules::inverse(colour)) 
            state_node.children << child if child
          end
        end
      end

      return state_node
    end

    private :decide_best_move, :update_board, :min_max, :compare_scores, :construct_state_tree,
    :translate_acn
    public :next_move
  end
end