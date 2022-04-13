require 'pry-byebug'

class Cell
  INITIAL_MARKER = " "

  attr_accessor :token

  def initialize(str = INITIAL_MARKER)
    @token = str
  end

  def to_s
    token
  end

  def unmarked?
    token == INITIAL_MARKER
  end
end

class Player
  attr_reader :token, :name

  def initialize(name, token)
    @name = name
    @token = token
  end
end

class Human < Player
  def initialize(token)
    # method to get user input for name and token (default to X or O)
    super('John Doe', token)
  end
end

class Computer < Player
  def initialize(token)
    # choose name (randomly?) from a list
    # choose token from X or O (choose whichever hasnt been chosen by human)
    super('Comp-u-tor', token)
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

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9],
                   [1, 4, 7], [2, 5, 8], [3, 6, 9],
                   [9, 5, 1], [3, 5, 7]]

  attr_reader :cells

  def initialize
    @cells = {}
    (1..9).each { |key| @cells[key] = Cell.new }
  end

  def get_cell_at(key)
    @cells[key]
  end

  def set_cell_at(key, token)
    @cells[key].token = token
  end

  def empty_cell_keys
    cells.select { |_, cell_obj| cell_obj.unmarked? }.keys
  end

  def full?
    empty_cell_keys.empty?
  end

  def someone_won?
    !!detect_winner?
  end

  def detect_winner?
    WINNING_LINES.each do |line|
      if line.all? { |cell_n| cells[cell_n].token == TTTGame::HUMAN_TOKEN }
        return TTTGame::HUMAN_TOKEN
      elsif line.all? { |cell_n| cells[cell_n].token == TTTGame::COMPUTER_TOKEN }
        return TTTGame::COMPUTER_TOKEN
      end
    end
    nil
  end
end


class TTTGame
  HUMAN_TOKEN = 'X'
  COMPUTER_TOKEN = 'O'

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Human.new(HUMAN_TOKEN)
    @computer = Computer.new(COMPUTER_TOKEN)
  end

  def display_welcome_message
    puts "Welcome to Tic-Tac-Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic-Tac-Toe! Goodbye"
  end

  def display_board
    system 'clear'
    puts "You're a #{human.token}, Computer is a #{computer.token}"
    puts ""
    puts "     |     |     "
    puts "  #{board.get_cell_at(1)}  |  #{board.get_cell_at(2)}  |  #{board.get_cell_at(3)}  "
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "  #{board.get_cell_at(4)}  |  #{board.get_cell_at(5)}  |  #{board.get_cell_at(6)}  "
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "  #{board.get_cell_at(7)}  |  #{board.get_cell_at(8)}  |  #{board.get_cell_at(9)}  "
    puts "     |     |     "
  end

  def display_result
    display_board

    case board.detect_winner?
    when human.token
      puts "You Won!"
    when computer.token
      puts "Computer Won!"
    else
      puts "It's a tie!"
    end
  end

  def human_moves
    puts "Choose a cell (#{board.empty_cell_keys.join(', ')}):"
    cell = nil
    loop do
      cell = gets.chomp.to_i
      break if (board.empty_cell_keys).include?(cell)
      puts "Sorry, that's not a valid choice"
    end

    board.set_cell_at(cell, human.token)
  end

  def computer_moves
    board.set_cell_at(board.empty_cell_keys.sample, computer.token)
  end

  def play_again?
    puts "Do you want to play again? (y/n):"
    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if 'yn'.include?(answer)
      puts "Invalid input"
    end
    answer.include?('y')
  end

  # rubocop:todo Metrics/MethodLength
  def play
    display_welcome_message
    loop do # session loop which is exited if user chooses NOT to play again
      display_board
      loop do
        human_moves
        break if board.full? || board.someone_won?
        
        computer_moves
        display_board
        break if board.full? || board.someone_won?
      end
      display_result
      break unless play_again?
    end
    display_goodbye_message
  end

end

# NOTE: TODOS:  the board does not reset after user chooses to play again

game = TTTGame.new
game.play
