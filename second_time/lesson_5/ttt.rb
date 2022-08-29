require 'pry-byebug'

module SqWinnable #square + winnable
  def get_winning_token(squares)
    lines = get_lines(Integer.sqrt(squares.size))

    lines.each do |line|
      target_token = squares[line.first].token
      next if target_token == ' '
      return target_token if line.all? { |cell_idx| squares[cell_idx].token == target_token}
    end
    nil
  end

  def get_lines(size)
    lines = []
    cells = (1..size).to_a.repeated_permutation(2)
    cells.each_slice(size) { |line| lines << line << line.map(&:reverse) }

    diagonals = [(1..size).zip((1..size)), (1..size).zip((1..size).to_a.reverse)]
    lines.concat(diagonals)
  end

  def middle_square_avail?(squares)
    true
    # mid = (squares.size / 2.0).ceil
    # squares[[mid, mid]].token == ' '
  end

  def avail_squares(squares)
    squares.select { |_, square| square.token == ' ' }.keys
  end
end

class TTTGame
  include SqWinnable

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
    confirm_game_start
    loop do
      players_take_turns
      display_outcome
      break unless play_again?
      system 'clear'
      @board = Board.new(board.size) # this preserves the board size initially chose
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
    [Human, Computer].each do |type|
      choose_n_players(type).times { |_| players.push(type.new) }
    end

    players.each do |player|
      player.name = player.choose_name
      player.token = player.choose_token(unavail_chars)
    end
  end

  def confirm_game_start
    puts ''
    puts "======= Players and Tokens ======="
    [Human, Computer].each { |type| puts "#{type} players: #{format_names_and_tokens(type)}" }
    puts ''
    puts "During your turn, choose a square by entering the row#, col# as shown below:"
    display_grid_ids
    puts 'Press any key to begin the match'
    gets.chomp
    system 'clear'
  end

  def display_grid_ids
    board.squares.map { |id, square| square.token = id.to_s.delete("[] ") }
    board.display(true) # the true formats the board to accept the square ids
    board.squares.map { |_, square| square.token = ' ' }
  end

  def format_names_and_tokens(type)
    players_subset = players.select { |player| player.class == type }
    names_and_tokens = players_subset.map { |player| "#{player.name}: '#{player.token}'" }
    names_and_tokens.join(', ')
  end

  def choose_n_players(type)
    type = type.to_s.downcase
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
    board.display
    loop do
      players.each do |player|
        execute_turn(player)
        puts ''
        board.display
        break if board.status == 'closed'
      end
      break if board.status == 'closed'
    end
  end

  def execute_turn(player)
    square_id = player.choose_square(board.squares)
    board.update_square(player, square_id)
    if player.class == Computer
      sleep 0.8
      system 'clear'
      puts "#{player.name} chose #{square_id.to_s.delete('[] ')}!"
    end
  end

  def display_outcome
    if !!get_winning_token(board.squares)
      winner = players.select { |player| player.token == get_winning_token(board.squares) }.first
      display_winner(winner.name)
    else
      display_game_is_draw
    end
  end

  def display_winner(name)
    puts ''
    puts ''
    puts "====#{name} won!===="
  end

  def display_game_is_draw
    if board.is_full?
      puts "Game is a draw!"
    elsif boad.is_a_draw?
      puts "No winning moves remain. Games is a draw!"
    else
      puts 'Error: game ended for unknown reasons'
    end
  end

  def play_again?
    puts "Do you want to play again? (y/n):"
    input = nil
    loop do
      input = gets.chomp.downcase
      break if 'yn'.chars.include?(input)
      puts "Error: Please enter 'y' or 'n'."
    end
    input == 'y'
  end

  def goodbye
    puts "Thanks for playing! Goodbye!"
  end
end

class Player
  include SqWinnable

  attr_accessor :name, :token, :order

  def initialize
    @name = nil
    @token = nil
  end
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
    puts "Please choose a token (A-Z) to mark your board squares."
    loop do
      token = gets.chomp
      break unless !(TTTGame::VALID_TOKENS.include?(token)) || (unavail_chars.include?(token))
      puts "Your choice is either invalid or has already been taken. Please try again."
    end
    token
  end

  def choose_square(squares)
    puts "#{name}'s turn!"
    puts "Please choose a square by entering a row#, col#:"
    answer = nil
    loop do
      answer = gets.chomp.chars
      answer = answer.select { |char| char.to_i.to_s == char }.map(&:to_i)
      break if avail_squares(squares).include?(answer) && answer.size == 2
      puts "Error: That square is already taken or the input was invalid. Please enter: row#, col#"
    end
    [answer.first, answer.last]
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

  def choose_square(squares)
    sleep 0.5
    # binding.pry
    if !!find_own_winning_move(squares)
      # binding.pry
      find_own_winning_move(squares)
    elsif !!find_others_winning_move(squares)
      find_others_winning_move(squares)
    elsif middle_square_avail?(squares)
      mid = Integer.sqrt(squares.size)
      [mid, mid]
    else
      avail_squares(squares).sample
    end
  end

  def find_others_winning_move(squares)
    lines = get_lines(squares.size)
    lines.each do |line|
      line = squares.select { |id, _| line.include?(id) }
      line_tokens = line.values.map(&:token)
      next unless line_tokens.uniq.size == 2 && line_tokens.count(' ') == 1
      winning_move = line.select { |_, square| square.token == ' ' }.keys
      return winning_move.flatten
    end
    nil
  end

  def find_own_winning_move(squares)
    lines = get_lines(squares.size)
    lines.each do |line|
      line = squares.select { |id, _| line.include?(id)}
      line_tokens = line.values.map(&:token)
      next unless line_tokens.count(token) == squares.size - 1
      winning_move = line.select { |_, square| square.token == ' ' }.keys
      return winning_move.flatten
    end
    nil
  end
end

  # Write a method which takes an array of square objects and returns the id of an available square for a line
#   which is under threat (i.e. has `size`-1 squares with the same non- ' ' token in the line).
#   algorith
#   - iterate through the set of lines
#   - if a line has more than one player token then skip and check the next line
#   - if a line has only one player token, get a count of its appearances; if count less than size -1 skip and check the next line
#   - if line is under threat, return the square id of the square that is available
#   - if no lines are under threat, return nil

class Board
  include SqWinnable

  attr_reader :squares, :size

  def initialize(size)
    @size = size
    @squares = create_squares(size)
  end

  def status(update = true)
    update_status if update
    @status
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

  def display(format_for_id = false)
    draw_grid(format_for_id)
  end

  def draw_grid(format_for_id = false)
    rows = []
    1.upto(size) do |row_i|
      rows << squares.filter { |k, _| k.first == row_i }
    end

    rows.each_with_index do |row, i|
      draw_row(size, row, format_for_id)
      draw_seperator_line unless i == size - 1
    end
    nil
  end

  def draw_row(size, arr, format_for_id)
    middle_line = ''
    arr.each do |key, square|
      cell = format_for_id ? " #{square.token} " : "  #{square.token}  "
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
    squares[key].token = player.token
  end

  def is_full?
    squares.all? { |_, square| square.token != ' ' }
  end

  def is_a_draw?
    false # hard coded for now
  end

  private

  def update_status
    self.status = (is_full? || is_a_draw? || !!get_winning_token(squares)) ? 'closed' : 'open'
  end

  attr_writer :status
end

class Square
  attr_accessor :token

  def initialize
    @token = ' '
  end
end

TTTGame.new.start

=begin
At this point the game functions with no major issues as long as the user knows what they're doing
What needs to happen next is:
 - incorporate computer logic
 - make visuals a bit better
 - add features like score keeping, and ending as soon as a draw is certain
=end

=begin
# Write a method which takes an array of square objects and returns the id of an available square for a line
#   which is under threat (i.e. has `size`-1 squares with the same non- ' ' token in the line).
#   algorith
#   - iterate through the set of lines
#   - if a line has more than one player token then skip and check the next line
#   - if a line has only one player token, get a count of its appearances; if count less than size -1 skip and check the next line
#   - if line is under threat, return the square id of the square that is available
#   - if no lines are under threat, return nil

=end
