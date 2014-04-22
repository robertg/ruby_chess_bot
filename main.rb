require_relative 'control'
require_relative 'ai'
require 'json'

def start()
  chess = nil
  ai = Bot::AI.new(:depth => 3)

  #Let's start a new game.
  chess = Control::ChessDotCom.new(:user => "L337_COOL", :pass => "password")

  callback = -> (chess: nil) do
    while true
      pkg = ai.next_move(:game_state => chess.get_board)
      r = Random.new
      from = pkg.move.before
      to = pkg.move.after
      printf("to: %s from:%s\n", to, from)
      chess.move_piece(from, to)
    end
  end

  chess.find_game(:callback => callback)
end

start()