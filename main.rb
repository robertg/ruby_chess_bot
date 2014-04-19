require_relative 'control'
chess = nil

#Let's start a new game.
chess = Control::ChessDotCom.new(:user => "L337_COOL", :pass => "password")

callback = -> (chess: nil) do
  while true
    p chess.get_board.length
    r = Random.new
    from = r.rand('a'.ord...('h'.ord+1)).chr + r.rand(1..8).to_s
    to = r.rand('a'.ord...('h'.ord+1)).chr + r.rand(1..8).to_s
    printf("to: %s from:%s\n", to, from)
    chess.move_piece(from, to)
  end
end

chess.find_game(:callback => callback)