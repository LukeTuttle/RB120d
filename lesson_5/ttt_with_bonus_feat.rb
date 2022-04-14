require 'pry-byebug'
class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_reader :marker, :name

  def initialize(marker, name = nil)
    @marker = marker
    @name = name
  end
end

class Human < Player
  attr_accessor :name, :marker
  # def prompt_for_name(name = nil)
  #   # @name = name unless name == 'prompt user' #incase I want to hard code @name when human is initialized
  #   name = nil
  #   puts "What is your name?:"
  #   loop do
  #     name = gets.chomp
  #     break unless name.empty?
  #     puts "I didn't get that, please try again:"
  #   end
  #   @name = name
  # end
end

class Computer < Player
  def initialize(marker, name)
    super
  end
  
  def name
    "'#{@name}'"
  end
end

class Score
  def initialize
    @data = {}
  end

  def to_s; end
end


class TTTGame
  HUMAN_MARKER = "X"
  COMPUTER_MARKER = "O"
  FIRST_TO_MOVE = HUMAN_MARKER
  POSSIBLE_AI_NAMES = [
    'Mr. Robo 3000', 'The Terminator', 'Jazz Hands', 'Tricky Dick Nixon'
  ]

  attr_reader :board, :human, :computer, :score

  def initialize
    @board = Board.new
    @human = Human.new(HUMAN_MARKER)
    @computer = Computer.new(COMPUTER_MARKER, POSSIBLE_AI_NAMES.sample)
    @current_marker = FIRST_TO_MOVE
  end

  def initialize_score
    # add the human and computer's @name instance vars as keys to the TTTGame's @score's @data instance variable (a hash)
  end

  # def play
  #   clear
  #   welcome_and_get_name
  #   # display_welcome_message
  #   main_game
  #   display_goodbye_message
  # end

  def play
    clear
    display_welcome_message
    prompt_for_name_and_marker
    main_game
    display_goodbye_message
  end

  private

  def main_game
    loop do
      display_board
      player_move
      display_result
      break unless play_again?
      reset
      display_play_again_message
    end
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def prompt_for_name_and_marker
    @human.name = prompt_for_name
    puts "Hello #{human.name}, today you will be playing against #{computer.name}."
    puts ""
    @human.marker = prompt_for_marker
    puts ""
    binding.pry
  end

  def prompt_for_name
    name = nil
    puts "What is your name?:"
    loop do
      name = gets.chomp.strip
      break unless name.empty?
      puts "I didn't get that, please try again:"
    end
    name
  end

  def prompt_for_marker
    marker = nil
    puts "Please choose a marker for yourself. You may choose any single character other than 'O':"
    loop do
      marker = gets.chomp.strip[0] #incase they enter more than one character
      break unless marker.nil? || marker.empty?
      puts "I didn't get that, please try again:"
    end
    marker
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end

  def display_board
    puts "You're a #{human.marker}. Computer is a #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def joinor(arr, delimiter=', ', word='or')
    case arr.size
    when 0 then ''
    when 1 then arr.first
    when 2 then arr.join(" #{word} ")
    else
      arr[-1] = "#{word} #{arr.last}"
      arr.join(delimiter)
    end
  end

  def human_moves
    puts "Choose a square (#{joinor board.unmarked_keys}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    board[board.unmarked_keys.sample] = computer.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = HUMAN_MARKER
    end
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def clear
    system "clear"
  end

  def reset
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end
end

game = TTTGame.new
game.play
