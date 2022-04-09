class Move
  VALUES = ['rock', 'paper', 'scissors']

  def initialize(value)
    @value = value
  end

  def scissors?
    @value == 'scissors'
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def >(other_move)
    (rock? && other_move.scissors?) ||
      (paper? && other_move.rock?) ||
      (scissors? && other_move.paper?)
  end

  def <(other_move)
    (rock? && other_move.paper?) ||
      (paper? && other_move.scissors?) ||
      (scissors? && other_move.rock?)
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0
  end
end

class Human < Player
  def set_name
    n = ""
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value"
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, or scissors"
      choice = gets.chomp
      break if Move::VALUES.include? choice
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Wall-e', 'Sinbad', 'Chappie'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class RPSMatch
  attr_accessor :human, :computer, :max_score

  def initialize
    display_welcome_message
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors!"
    puts ""
  end

  def set_max_score
    puts "What would score would you like to play to? (max allowed is 10)"
    max = nil
    loop do
      max = gets.chomp
      break if (max.to_i.to_s == max) && (max.to_i < 11)
      puts "Invalid input. Must be an integer less than 11"
    end
    self.max_score = max.to_i
  end

  def record_score(result)
    if result == 'human'
      human.score += 1
    elsif result == 'computer'
      computer.score += 1
    end
  end

  def display_score
    puts "#{human.name}: #{human.score}"
    puts "#{computer.name}: #{computer.score}"
  end

  def match_finished?
    human.score == max_score || computer.score == max_score
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include? answer.downcase
      puts "Sorry, must by y or n."
    end

    return true if answer == 'y'
    false
  end

  def display_match_winner
    if human.score == max_score
      puts "Congratulations!!! You won the match!"
    elsif computer.score == max_score
      puts "#{computer.name} won the match...Better luck next time!"
    end
  end

  def play
    set_max_score
    loop do
      record_score(RPSGame.new(human, computer).play)
      display_score
      break if match_finished?
    end
    display_match_winner
    play_again?
  end
end
 
class RPSGame < RPSMatch
  def initialize(human, computer)
    @human = human
    @computer = computer
  end

  def display_moves
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
      'human'
    elsif human.move < computer.move
      puts "#{computer.name} won!"
      'computer'
    else
      puts "It's a tie!"
      'tie'
    end
  end

  def play
    human.choose
    computer.choose
    display_moves
    display_winner
  end
end


loop do
  break unless RPSMatch.new.play
end
puts "Thanks for playing. Good bye!"
