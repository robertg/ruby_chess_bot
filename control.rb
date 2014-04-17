require 'rubygems'
require 'watir'
require 'watir-webdriver'
require 'watir-webdriver/wait'

module Control
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
        @browser = Watir::Browser.new :chrome
      end

      #Login
      @browser.goto@base_url + @locations[:login]
      @browser.text_field(:id => "c1").set @username
      @browser.text_field(:id => "loginpassword").set @password
      @browser.button(:id => "btnLogin").click
      @browser.goto @base_url + @locations[:play]

      if @browser.button(:class => "dialog_welcome_close_window_button").exists?
        @browser.button(:class => "dialog_welcome_close_window_button").click
      end

      #@browser.button(:id => "new_game_pane_create_button").click

      #done
      callback.call(:chess => self)
    end

    def get_board()
      #t = @browser.div(:id => "moves")
      #p t.lis.length
    end
  end
end
