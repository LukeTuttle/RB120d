require 'pry-byebug'

class Game
  attr_reader :deck, :dealer, :player

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def start
    disp_welcome_msg
    loop do
      deal_cards
      show_initial_cards
      main_game_loop
      disp_result
      break unless play_again?
      reset_game
    end
    goodbye
  end

  def disp_welcome_msg
    puts "===== Hello and Welcome to 21! ====="
    puts ''
    sleep 0.5
    puts "Dealing cards..."
    sleep 1
  end

  def deal_cards
    2.times do
      [player, dealer].each { |prsn| prsn.recieve_card(deck.deal) }
    end
  end

  def show_initial_cards
    puts ''
    if player.name.nil?
      [dealer, player].each { |prsn| puts "#{prsn.class} has #{prsn.hand}" }
      puts "=> Enter your name and we'll get started"
      player.ask_for_name
    else
      [dealer, player].each { |prsn| puts "#{prsn.name} has #{prsn.hand}" }
      puts "=> Press 'Enter' and we'll get started"
      gets
    end
    system 'clear'
  end

  def main_game_loop
    loop do
      player_turn
      break if player.busted?
      dealer_turn
      break
    end
    puts ''
    puts "=> Press 'Enter' to see result."
    gets
  end

  def disp_result
    busted_participant = who_busted?
    if !!busted_participant
      disp_busted_msg(busted_participant)
    elsif player.total == dealer.secret_total
      puts "===== It's a tie! ====="
    else
      winner = who_won?
      disp_winner_msg(winner)
    end
    disp_final_cards_and_score
  end

  def who_busted?
    return player if player.busted?
    return dealer if dealer.busted?
    nil
  end

  def disp_busted_msg(buster)
    puts ''
    puts "===== #{buster.name} busted! ====="
  end

  def who_won?
    dealer.secret_total > player.total ? dealer : player
  end

  def disp_winner_msg(winner)
    puts ''
    puts "===== #{winner.name} won! ====="
  end

  def disp_final_cards_and_score
    [dealer, player].each do |prsn|
      hand = prsn.class == Dealer ? prsn.full_hand : prsn.hand
      total = prsn.class == Dealer ? prsn.secret_total : prsn.total
      puts "#{prsn.name} cards: #{hand}"
      puts "Total: #{total}\n\n"
    end
  end

  def player_turn
    puts "#{player.name.upcase}'S TURN!\n\n"
    puts "Cards: #{player.hand}"
    puts "Total: #{player.total}\n\n"
    player.take_turn(deck)
  end

  def dealer_turn
    puts "\n\n#{dealer.name.upcase}'S TURN!\n\n"
    puts "Cards: #{dealer.hand}"
    puts "Total: #{dealer.total}\n\n"
    sleep 0.8
    dealer.take_turn(deck)
  end

  def goodbye
    puts "Thanks for playing! Goodbye!"
  end

  def reset_game
    @deck = Deck.new
    dealer.reset_hand
    player.reset_hand
    system 'clear'
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include? answer
      puts "Sorry, must be y or n."
    end
    answer == 'y'
  end
end

class Participant
  attr_reader :name

  def hand
    class_is_dealer = self.class == Dealer
    class_is_dealer ? @hand.slice(1..@hand.length) : @hand
  end

  def total
    faces_and_values = parse_cards(hand)
    sum_parsed_cards(faces_and_values)
  end

  def sum_parsed_cards(cards)
    aces = []
    values = []
    cards.each do |face, value|
      aces << face if face == 'A'
      values << value
    end

    sum = values.sum
    return sum unless sum > 21
    aces.each { |_| sum -= 10 unless sum <= 21 }
    sum
  end

  def parse_cards(cards)
    faces_with_vals = []
    cards.each do |card|
      face = card.match(/\d{1,2}|[JQKA]/)[0]
      value = Deck::FACE_VALUES[face]
      faces_with_vals << [face, value]
    end
    faces_with_vals
  end

  def take_turn(deck)
    class_is_dealer = self.class == Dealer
    loop do
      break puts "#{name} chose to stay!" unless hit?
      recieve_card(deck.deal)
      puts "#{name} chose to hit! => #{hand.last}\n\n"
      break puts 'Busted!' if busted?
      sleep 1.5 if class_is_dealer
      puts "Cards: #{hand}"
      puts "Total: #{total}\n\n"
      sleep 1.5 if class_is_dealer
    end
  end

  def busted?
    local_total = self.class == Dealer ? secret_total : total
    local_total > 21
  end

  def recieve_card(card)
    @hand << card
  end

  def reset_hand
    @hand = []
  end
end

class Player < Participant
  def initialize
    @name = nil
    @hand = []
  end

  def ask_for_name
    name = ''
    loop do
      name = gets.chomp
      break unless name.empty?
      puts "Sorry, must enter a value."
    end
    @name = name
  end

  def hit?
    puts ''
    puts "Would you like to hit?"
    input = nil
    loop do
      input = gets.chomp
      break if ['y', 'n'].include?(input.downcase)
      puts "Error: Please enter either 'y' or 'n'"
    end
    input.downcase == 'y'
  end
end

class Dealer < Participant
  DEALER_NAME = 'Dealer'

  def initialize
    @name = DEALER_NAME
    @hand = []
  end

  def hit?
    secret_total < 17
  end

  def full_hand
    @hand
  end

  def secret_total
    faces_and_values = parse_cards(@hand)
    sum_parsed_cards(faces_and_values)
  end
end

class Deck
  attr_reader :cards

  SUITS = %w(D S C H)
  FACES = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  VALUES = [2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 11]
  FACE_VALUES = FACES.zip(VALUES).to_h

  def initialize
    @cards = create_cards
  end

  def create_cards
    deck = []
    SUITS.each do |suit|
      FACES.each do |face|
        deck << "#{face}:#{suit}"
      end
    end
    deck.shuffle
  end

  def deal
    @cards.pop
  end
end

Game.new.start
=begin
game functions well. could add '??' to printout of dealer hand to signify hidden card but it would require some restructuring
=end