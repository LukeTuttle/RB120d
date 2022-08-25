require 'pry-byebug'

class TTTGame
  MAX_PLAYERS = 3
  VALID_TOKENS = [('A'..'Z').to_a, ('a'..'z').to_a].flatten

  attr_reader :players, :board

  def initialize
    @players = []
    @board = nil
  end

  def start
    greeting
    set_grid_size
    set_player_names_and_tokens
    loop do 
      players_take_turns
      display_outcome
      break unless play_again?
    end
    goodbye
  end

  private

  attr_writer :players, :board

  def greeting
    system 'clear'
    puts "======Welcome to Tic-Tac-Toe======"
    puts ''
  end

  def set_grid_size
    self.board = Board.new(user_chooses_board_size)
  end

  def user_chooses_board_size
    size = nil
    loop do
      puts "Please choose the size of the board (3, 5, 9):"
      size = gets.chomp
      break if [3, 5, 9].include?(size.to_i)
      puts "Error: Please enter 3, 5, or 9."
    end
    size.to_i
  end

  def set_player_names_and_tokens
    choose_n_players('human').times { |_| players.push(Human.new) }
    choose_n_players('computer').times { |_| players.push(Computer.new) }

    players.each { |player| player.name = player.choose_name }
    puts "Players include: #{players.map(&:name)}"
    players.each { |player| player.token = player.choose_token(unavail_chars) }
  end

  def choose_n_players(type)
    n = nil
    loop do
      puts "How many #{type} players are there?:"
      n = gets.chomp
      break unless n.to_i.to_s != n && (1..MAX_PLAYERS) === n.to_i
      puts "Error: Please enter an integer between 1 and #{MAX_PLAYERS}."
    end
    n.to_i
  end

  def unavail_chars
    players.map(&:token)
  end

  def players_take_turns
    loop do
      players.each do |player|
        execute_turn(player)
        board.update_status
        break unless board.status == 'winnable'
      end
      break unless board.status == 'winnable'
    end
  end
  
  def execute_turn(player)
    board.display if player.class == Human
    square_id = player.choose_square
    board.update_square(player, square_id)
    board.display
  end

  def display_outcome
    board.status == 'unwinnable' ? display_game_unwinnable : display_winner
  end

  def display_game_unwinnable
    #something like 'the board is such  that the game is unwinnable'
  end

  def display_winner
    winner = determine_winner
    #something like congrats winner won!
  end

  def determine_winner
    # looks at the board and returns the player who won
  end

  def play_again?
    # should reset the game board if user choose to play again
  end
end

class Player
  attr_accessor :name, :token, :order

  def initialize
    @name = nil
    @token = nil
  end

  def place_token; end
end

class Human < Player
  def choose_name
    name = nil
    puts "What is your name?:"
    loop do
      name = gets.chomp
      break unless name.empty?
      puts "Error: Invalid input. Please try again."
    end
    name
  end

  def choose_token(unavail_chars)
    token = nil
    # unavail_chars may show up weird
    puts "Please choose a token to mark your board squares. #{unavail_chars} are already taken"
    loop do
      token = gets.chomp
      break unless !(TTTGame::VALID_TOKENS.include?(token)) || (unavail_chars.include?(token))
      puts "Your choice is either invalid or has already been taken. Please try again."
    end
    token
  end

  def choose_square # this obviously will be built out more, just simplifying to make sure other code works
    puts "Choose a square"
    answer = gets.chomp.chars
    [answer.first.to_i, answer.last.to_i]
  end
end

class Computer < Player
  NAMES = ['Ash', 'Misty', 'Brock']
  PREFFERED_CHARS = ['X', 'O']

  def choose_name
    NAMES.sample
  end

  def choose_token(unavail_chars)
    return PREFFERED_CHARS.sample unless PREFFERED_CHARS.any? {|char| unavail_chars.include?(char)}
    return (PREFFERED_CHARS - unavail_chars).sample unless (PREFFERED_CHARS - unavail_chars).empty?
    (TTTGame::VALID_TOKENS - unavail_chars).sample
  end

  def choose_square
    #should return the id for a square
  end
end

class Board
  attr_reader :squares, :status, :size

  def initialize(size)
    @size = size
    @squares = create_squares(size)
  end

  def create_squares(size)
    keys = []
    1.upto(size) do |row_i|
      1.upto(size) { |col_i| keys << [row_i, col_i] }
    end

    sq_hsh = Hash.new
    keys.each { |key| sq_hsh[key] = Square.new }
    @squares = sq_hsh
  end

  def display
    draw_grid
  end

  def draw_grid # this has to be rethought
    rows = []
    1.upto(size) do |row_i|
      rows << squares.filter { |k, _| k.first == row_i }
    end

    rows.each_with_index do |row, i|
      draw_row(size, row)
      draw_seperator_line unless i == size - 1
    end
    nil
  end

  def draw_row(size, arr)
    middle_line = ''
    arr.each do |key, square|
      cell = "  #{square.token}  "
      cell << '|' unless key.last == size 
      middle_line << cell
    end

    top_bottom_line =  "#{'     |' * (size - 1)}     "
    puts top_bottom_line
    puts middle_line
    puts top_bottom_line
  end

  def draw_seperator_line
    puts "#{'-----+' * (size - 1)}-----"
  end

  def update_square(player, key)
    binding.pry
    squares[key].token = player.token
  end

  def update_status; end
end

class Square
  attr_accessor :token

  def initialize
    @token = ' '
    # @id = {position => @token}
  end
end

TTTGame.new.start

# notes: 
=begin
I need to restructure the Square class. It doesn't need an id just a token. The board can store the squares in a hash wherein each square is stored with a key.
The key will be an array object [row, col]. This will require modifying how the board draws the grid and how it creates the square. The benefits are that it should make accessing the squares much 
easiers because you wont have to index deeply through arrays and hashes. It's not a bad idea to draw it all out visually–how it flows and how things are accessed. 
=end