class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(str = INITIAL_MARKER)
    @marker = str
  end

  def to_s
    marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_reader :marker

  def initialize(marker)
    @marker = marker
  end
end

class Human < Player
  def initialize(marker)
    super(marker)
  end
end

class Computer < Player
  def initialize(marker)
    super(marker)
  end
end

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9],
                   [1, 4, 7], [2, 5, 8], [3, 6, 9],
                   [9, 5, 1], [3, 5, 7]]

  attr_reader :squares

  def initialize
    @squares = {}
    reset
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def get_square_at(key)
    @squares[key]
  end

  def set_square_at(key, marker)
    @squares[key].marker = marker
  end

  def empty_square_keys
    squares.select { |_, square_obj| square_obj.unmarked? }.keys
  end

  def full?
    empty_square_keys.empty?
  end

  def someone_won?
    !!detect_winner?
  end

  def count_human_marker(squares)
    squares.collect(&:marker).count(TTTGame::HUMAN_MARKER)
  end

  def count_computer_marker(squares)
    squares.collect(&:marker).count(TTTGame::COMPUTER_MARKER)
  end

  def detect_winner?
    WINNING_LINES.each do |line|
      if count_human_marker(@squares.values_at(*line)) == 3
        return TTTGame::HUMAN_MARKER
      elsif count_computer_marker(@squares.values_at(*line)) == 3
        return TTTGame::COMPUTER_MARKER
      end
    end
    nil
  end
end

class TTTGame
  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Human.new(HUMAN_MARKER)
    @computer = Computer.new(COMPUTER_MARKER)
  end

  def display_welcome_message
    puts "Welcome to Tic-Tac-Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic-Tac-Toe! Goodbye"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_board
    puts "You're a #{human.marker}, Computer is a #{computer.marker}"
    puts ""
    puts "     |     |     "
    puts "  #{board.get_square_at(1)}  |  #{board.get_square_at(2)}  |  #{board.get_square_at(3)}  "
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "  #{board.get_square_at(4)}  |  #{board.get_square_at(5)}  |  #{board.get_square_at(6)}  "
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "  #{board.get_square_at(7)}  |  #{board.get_square_at(8)}  |  #{board.get_square_at(9)}  "
    puts "     |     |     "
  end

  def display_result
    clear_screen_and_display_board

    case board.detect_winner?
    when human.marker
      puts "You Won!"
    when computer.marker
      puts "Computer Won!"
    else
      puts "It's a tie!"
    end
  end

  def human_moves
    puts "Choose a square (#{board.empty_square_keys.join(', ')}):"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if (board.empty_square_keys).include?(square)
      puts "Sorry, that's not a valid choice"
    end

    board.set_square_at(square, human.marker)
  end

  def computer_moves
    board.set_square_at(board.empty_square_keys.sample, computer.marker)
  end

  def play_again?
    puts "Do you want to play again? (y/n):"
    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      puts "Sorry, must y or n"
    end
    answer == 'y'
  end

  def clear
    system 'clear'
  end

  # rubocop:todo Metrics/MethodLength
  def play
    clear
    display_welcome_message

    loop do
      display_board

      loop do
        human_moves
        break if board.full? || board.someone_won?

        computer_moves
        break if board.full? || board.someone_won?

        clear_screen_and_display_board
      end
      display_result
      break unless play_again?
      board.reset
      puts "Let's play again!"
    end
    display_goodbye_message
  end
end

game = TTTGame.new
game.play