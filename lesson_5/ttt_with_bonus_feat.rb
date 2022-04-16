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

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
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
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # method takes a string so it can be used as a general purpose method for
  # board rather than being hard coded to play against human player only in
  # case this TTTGame is expanded to include multiple human or computer players
  def sq_key_needed_to_win(marker)
    WINNING_LINES.each do |sq_keys_in_line|
      if line_near_complete?(sq_keys_in_line, marker)
        sq_keys_in_line.each do |sq_key|
          return sq_key if @squares.fetch(sq_key).marker == Square::INITIAL_MARKER
        end
      end
    end
    nil
  end

  def middle_square_available?
    @squares.fetch(5).marker == Square::INITIAL_MARKER
  end

  def player_can_win_on_next_turn(markers)
    markers.each do |marker|
      return marker if !!sq_key_needed_to_win(marker)
    end
    nil
  end

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end

  def line_near_complete?(arr, marker)
    square_values = @squares.values_at(*arr).map(&:marker)
    square_values.count(marker) == 2
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

class Human
  attr_accessor :name, :marker

  def initialize(marker = nil, name = nil)
    @marker = marker
    @name = name
  end
end

class Computer
  attr_reader :name, :marker

  def initialize(marker = nil, name = nil)
    @marker = marker
    @name = name
  end
end

class Score
  attr_reader :data

  def initialize(human_name, computer_name)
    @data = { human_name => 0, computer_name => 0 }
  end

  def to_s
    @data.map { |player, score| "#{player}: #{score}" }.join("\n")
  end
end

# TO DO: HUMAN_MARKER is no longer passed into the @marker instance var for
# the @human (Human) collaborator object. Code needs to be refactored for this.
# I'm just waiting until I start working on allowing the user to choose who
# decides which player goes first (ie. user chooses to let themself decide
# or computer decide)
class TTTGame
  MAX_SCORE = 3
  # HUMAN_MARKER = "X"
  COMPUTER_MARKER = "O"
  # ASK_ = HUMAN_MARKER
  POSSIBLE_AI_NAMES = [
    'Mr. Robo 3000', 'The Terminator', 'Jazz Hands', 'Tricky Dick Nixon'
  ]

  attr_reader :board, :human, :computer, :score

  def initialize
    @board = Board.new
    @human = Human.new
    @computer = Computer.new(COMPUTER_MARKER, POSSIBLE_AI_NAMES.sample)
    # @current_marker = ASK_
  end

  def play
    clear
    display_welcome_message
    ask_for_name_and_marker
    determine_who_goes_first
    initialize_score
    main_game
    display_goodbye_message
  end

  private

  def main_game
    loop do
      execute_single_game
      break if max_score_achieved?
      display_result
      break unless ask_play_again?
      reset
      display_play_again_message
    end
    close_out_match
  end

  def execute_single_game
    display_score
    display_board
    players_take_turns
    increment_score
  end

  def close_out_match
    clear
    display_board
    display_match_result
  end

  def players_take_turns
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = computer.marker
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def human_turn?
    @current_marker == human.marker
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
    board[determine_computer_move] = computer.marker
  end

  def determine_computer_move
    markers = { human: human.marker, computer: computer.marker }
    chance_to_win = board.player_can_win_on_next_turn(markers.values)

    return offensive_move if chance_to_win == markers[:computer]
    return deffensive_move if chance_to_win == markers[:human]
    return 5 if board.middle_square_available?
    board.unmarked_keys.sample
  end

  def offensive_move
    board.sq_key_needed_to_win(computer.marker)
  end

  def deffensive_move
    board.sq_key_needed_to_win(human.marker)
  end

  def max_score_achieved?
    @score.data.values.max >= MAX_SCORE
  end

  def display_match_result
    case @score.data.key(MAX_SCORE)
    when human.name
      puts "Congratulations #{human.name}! You won!"
    when computer.name
      puts "WhaapWhaap! #{computer.name} won!"
    end
    puts "The final score is:\n#{@score}"
    puts ""
  end

  def ask_for_name_and_marker
    @human.name = ask_for_name
    puts ""
    puts "Hello #{human.name}, '#{computer.name}' will be your opponent today."
    puts ""
    @human.marker = ask_for_marker
    puts ""
  end

  # def determine_who_goes_first
  #   first_player =
  #     if human_wants_to_go_first?
  #       human.marker
  #     else
  #       comp_choice = [human.marker, computer.marker].sample
  #       display_computer_choice(comp_choice)
  #       comp_choice
  #     end
  #   @first_to_move = first_player
  #   @current_marker = @first_to_move
  #   clear
  # end

  # def display_computer_choice(choice)
  #   to_go_first = choice == computer.marker ? computer.name : human.name
  #   puts "Computer chose #{to_go_first} to go first!\n"
  #   sleep 0.5
  # end

  def determine_who_goes_first
    first_player =
      if ask_who_should_decide == 'human'
        ask_who_goes_first == 'human' ? human.marker : computer.marker
      else
        computer_chooses_first_to_move
      end
    @first_to_move = first_player
    @current_marker = @first_to_move
    # binding.pry
    clear
  end

  def computer_chooses_first_to_move
    marker_choice = [human.marker, computer.marker].sample
    name = marker_choice == computer.marker ? computer.name : human.name
    puts "Computer chose #{name} to go first!\n"
    sleep 0.5
    marker_choice
  end

  def ask_who_should_decide
    choice = nil
    loop do
      puts "Do you want to choose who goes first? (y/n):"
      choice = gets.chomp.downcase
      break if ['y', 'n'].include?(choice)
      puts "Invalid input. Please try again."
    end
    choice == 'y' ? 'human' : 'computer'
  end

  def ask_who_goes_first
    choice = nil
    loop do
      puts "Do you want to go first? (y/n):"
      choice = gets.chomp.downcase
      break if ['y', 'n'].include?(choice)
      puts "Invalid input. Please try again."
    end
    choice == 'y' ? 'human' : 'computer'
  end

  def ask_for_name
    name = nil
    puts "What is your name?:"
    loop do
      name = gets.chomp.strip
      break unless name.empty?
      puts "I didn't get that, please try again:"
    end
    name
  end

  def ask_for_marker
    marker = nil
    puts "Please choose a marker, any character other than 'O':"
    loop do
      marker = gets.chomp.strip[0] # incase they enter more than one character
      break unless marker.nil? || marker.empty?
      puts "I didn't get that, please try again:"
    end
    marker
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def initialize_score
    @score = Score.new(@human.name, @computer.name)
  end

  def display_score
    puts "Score is"
    puts @score
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_board
    puts "Your marker is a #{human.marker}. #{computer.name}'s is a #{computer.marker}."
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

  def display_result
    clear_screen_and_display_board
    winner = determine_game_winner
    puts !!winner ? "#{winner} won!" : "It's a tie!"
    puts "\nThe score is now:\n#{@score}\n"
  end

  def determine_game_winner
    case board.winning_marker
    when human.marker
      human.name
    when computer.marker
      computer.name
    end
  end

  def increment_score
    if !!determine_game_winner
      @score.data[determine_game_winner] += 1
    end
  end

  def ask_play_again?
    answer = nil
    loop do
      puts "The first player to win #{MAX_SCORE} games wins the match."
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
    @current_marker = @first_to_move
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end
end

game = TTTGame.new
game.play
