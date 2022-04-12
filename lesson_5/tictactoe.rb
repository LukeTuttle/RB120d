class Board
  attr_reader :grid

  def initialize
    # create a multi-dim array to represent the 3x3 board
    @grid = Array.new(3, nil).map {|arr| [[],[],[]]}
  end
end

class Player
  attr_reader :token, :name
  def initialize(name, token)
    @name = name
    @token = token # should be a string object
  end

  def place_token(row, column)
    # modify board by placing (player's) @token on 
    # (board's) @grid in board object
  end
end

class Human < Player
  def initialize
    #method to get user input for name and token (default to X or O)
    super(user_inputs)
  end

  def place_token
    #method to get user input for placing token
    super(user_input)
  end
end

class Computer < Player
  def initialize
    # choose name (randomly?) from a list
    # choose token from X or O (choose whichever hasnt been chosen by human)
    super(chosen_name, chosen_token)
  end

  def place_token
    # computer_choose is standin for computer choice logic method (returns col and row)
    super(computer_choose)
  end

  private
  
  def computer_choose
    # returns: row (integer), column (integer)  could return as array? 
    # this method should use the board's grid state to determine
      # where to place a token. method should return integers
      # for column and row to supply to Person#place_token
    # could just choose a random unoccupied spot on the board to start with
        # just while making sure the rest of the game works

    # I'm thinking it should be private because there's no reason for 
    # it to be used outside the class, that way no one can use it to 
    # determine where the player ought to move next according to the AI (comp logic)
  end 
end

class Cell
  attr_accessor :token
  def initialize
    @token = nil
  end
end

class TTTGame
  # need a way to establish who goes first, it shouldn't always be human or computer
    # maybe the user can choose who goes first? 
  attr_reader :board, :human, :computer, :turn # should turn be an attribute, if so in which class?

  def initialize
    # @board = Board.new
    # @human = Human.new
    # @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Tic-Tac-Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic-Tac-Toe! Goodbye"
  end

  def display_board
    puts ""
    puts "     |     |     "
    puts "     |     |     "
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "     |     |     "
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "     |     |     "
    puts "     |     |     "∏
  end

  def display_result
    puts "pretend I'm displaying the result"
  end

  # need methods for player and computer turn (ie first and seocnd player turns)

  def play_again?
    # asks user if they want to play again and returns a boolean
    nil
  end

  def play
    display_welcome_message
    loop do # session loop which is exited if user chooses NOT to play again
      winner = nil
      loop do
        display_board
        
        break
        first_player_moves # dont forget to increment @turn after each player takes their turn
        break if someone_won? || board_full?

        second_player_moves
        break if someone_won? || board_full?
      end
      display_result
      break unless play_again?
      
    end
    display_goodbye_message
  end

end

game = TTTGame.new
game.play
