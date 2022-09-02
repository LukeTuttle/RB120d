require 'pry-byebug'

class Game
  attr_reader :deck, :dealer, :player

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new(@deck)
  end

  def start
    disp_welcome_msg
    player.ask_for_name
    deal_cards
    show_initial_cards
    main_game_loop
    show_result
  end

  def disp_welcome_msg
    puts "===== Hello and Welcome to 21! ====="
    puts ''
  end

  def deal_cards
    2.times do
      [player, dealer].each { |prsn| prsn.recieve_card(deck.deal) }
    end
  end

  def show_initial_cards
    [dealer, player].each { |prsn| puts "#{prsn.name} has #{prsn.hand}" }
    puts ''
    puts "Press enter to start your turn"
    gets
    system 'clear'
  end

  def main_game_loop
    loop do
      player_turn
      break if player.busted?
      dealer_turn
      break
    end
    binding.pry
  end

  def player_turn
    puts "#{player.name.upcase}'S TURN!"
    puts ''
    puts "Cards: #{player.hand}"
    puts "Total: #{player.total}"
    puts ''
    player.take_turn(deck)
  end

  def dealer_turn
    puts "#{dealer.name.upcase}'S TURN!"
    puts ''
    puts "Cards: #{dealer.hand}"
    puts "Total: #{dealer.total}"
    puts ''
    dealer.take_turn(deck)
  end
end

class Participant
  attr_reader :name

  def hand
    self.class == Dealer ? @hand.slice(1..@hand.length) : @hand
  end

  def total
    faces_and_values = hand_to_hash(hand)
    sum_from_hash(faces_and_values)
  end

  # def sum_from_hash(cards)
  #   sum = cards.values.sum
  #   return sum unless sum > 21

  #   aces = cards.keys.select { |face| face == 'A' }
  #   aces.each { |_| sum -= 10 unless sum < 21 }
  #   sum
  # end
  
  def sum_from_hash(cards)
    sum = cards.last.sum
    return sum unless sum > 21

    aces = cards.first.select { |face| face == 'A' }
    aces.each { |_| sum -= 10 unless sum < 21 }
    sum
  end

  def faces_and_values(cards)
    faces = []
    values = []
    cards.each do |card|
      face = card.match(/\d{1,2}|[JQKA]/)[0]
      faces << face
      values << Deck::FACE_VALUES[face]
    end
    [faces, values]
  end

  def take_turn(deck)
    loop do
      break puts "#{name} chose to stay!" unless hit?
      recieve_card(deck.deal)
      puts "#{name} chose to hit! => #{hand.last}"
      puts "Cards: #{hand}"
      puts "Total: #{total}"
      break if busted?
    end
  end

  def busted?
    local_total = self.class == Dealer ? secret_total : total
    local_total > 21
  end

  def recieve_card(card)
    @hand << card
  end
end

class Player < Participant
  def initialize
    @name = nil
    @hand = []
  end

  def ask_for_name
    puts "What is your name?:"
    sleep 0.25
    @name = "Luke"
  end

  def hit?
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

  def initialize(deck = nil)
    @name = DEALER_NAME
    @deck = deck
    @hand = []
  end

  def hit?
    secret_total < 17
  end

  private

  def secret_total
    binding.pry
    faces_and_values = faces_and_values(@hand)
    sum_from_hash(faces_and_values)
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
The names of the method used by #total and #secret_total need to be looked over and renamed if not reworked.
Also need to create methods for displaying result
=end