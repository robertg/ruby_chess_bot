require 'rubygems'
require 'watir'
require 'watir-webdriver'
require 'watir-webdriver/wait'

module Control
  #Data Structures:
  BoardMovement = Struct.new(:colour, :movement) do
  end

  #Classes:
  class ChessGame #Interface for a chess game.

    #Find a game, and once found, calls callback.
    def find_game(callback)
      raise 'needs implementation'
    end

    #Queries and returns the board as a 2D array
    def get_board()
      raise 'needs implementation'
    end

    #Moves a piece from one board location to the next, 
    #returning #t or #f depending on success.
    def move_piece(from, to)
      raise 'needs implementation'
    end
  end

  #Chess.com implementation of ChessGame
  class ChessDotCom < ChessGame
    def initialize(user: "", pass: "")
      @browser = nil
      @base_url = "https://www.chess.com"
      @locations = {
        login: "/login",
        play: "/live"
      }
      @username = user
      @password = pass
    end

    def find_game(callback: nil) 
      if(@browser == nil)
        @browser = Watir::Browser.new :firefox
      end

      #Login
      @browser.goto @base_url + @locations[:login]
      @browser.text_field(:id => "c1").set @username
      @browser.text_field(:id => "loginpassword").set @password
      @browser.button(:id => "btnLogin").click
      @browser.goto @base_url + @locations[:play]

      close = @browser.span(:id => "dijitDialogCloseIcon")
      if close.exists? && clone.visible?
        close.click
      end

      play_button = @browser.button(:id => "new_game_pane_create_button")

      @browser.wait_until { play_button.exists? && play_button.visible? } 
      play_button.click

      @browser.div(:id => 'game_container').wait_until_present

      #done
      callback.call(:chess => self)
    end

    #[from, to] must be chess coordinates like "a7"
    def move_piece(from, to)
      from = @browser.image(:id, /img_chessboard.*#{from}/)
      to   = @browser.image(:id, /img_chessboard.*#{to}/)


      attempt = -> () do
        begin 
          #Selenium race condition requires error handling
          return nil if (!from.exists? || !to.exists?) && (from.visible? && to.visible?)

          from.drag_and_drop_on(to)
          return 1
        rescue Selenium::WebDriver::Error::ObsoleteElementError, 
          Watir::Exception::UnknownObjectException, 
          Selenium::WebDriver::Error::MoveTargetOutOfBoundsError, 
          Selenium::WebDriver::Error::UnknownError
          return nil
        end
    end

    count = 5
    while attempt.call == nil && count != 0
        count -= 1 #try again
      end
    end


    def get_board()
      ret = []
      white = true

      attempt = -> () do
        begin
          @browser.spans(:id, /movelist_\d\d?\d?/).each do | move |
            str = move.as[0].text
          if str != nil && str.length > 0 #This is a valid command
            add = BoardMovement.new
            add.colour = white ? :white : :black
            add.movement = str
            white = !white
            ret << add
          end
        end
      rescue Selenium::WebDriver::Error::ObsoleteElementError
        return nil
      end
      return ret
    end

    count = 5 #Try five times
    while (ret = attempt.call).nil? && count != 0 #We try until we get something.
      ret = [] #try again
      count -= 1
    end

    return ret
  end
end
end