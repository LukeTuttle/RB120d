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
      puts "Please choose the size of the board:"
      size = gets.chomp
      break unless size.to_i.to_s != size
      puts "Error: Please enter an interger."
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
        execute_player_turn(player)
        board.update_status
        break unless board.status == 'winnable'
      end
      break unless board.status == 'winnable'
    end
  end

  def execute_player_turn(player)
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

  def take_turn
    #should return the id for a square
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

  def take_turn
    #should return the id for a square
  end
end

class Board
  attr_reader :squares, :status, :size

  def initialize(size)
    @size = size
    @squares = []
  end

  def update_square(player, index); end

  def update_status; end

  def display; end
end

class Square
  attr_accessor :token

  def initialize(position)
    @token = nil
    @id = {position => @token}
  end
end

TTTGame.new.start