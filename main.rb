require_relative 'control'
chess = nil

def callback(chess: nil)
  puts "yay it worked"
end
#Let's start a new game.
chess = Control::ChessDotCom.new(:user => "L337_COOL", :pass => "password")
chess.find_game(:callback => method(:callback))
