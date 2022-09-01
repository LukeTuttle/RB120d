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
    take_turn(player)
    take_turn(dealer)
    show_result
  end

  def disp_welcome_msg
    puts "===== Hello and Welcome to 21! ====="
    puts ''
  end

  def deal_cards
    2.times do
      player.hand.push(dealer.deal)
      dealer.hand(false).push(dealer.deal)
    end
  end

  def show_initial_cards
    [dealer, player].each { |prsn| puts "#{prsn.name} has #{prsn.hand}" }
  end

  def take_turn(participant)
    puts ''
    puts "#{participant.class.to_s.upcase} TURN!"
    name = participant.name
    hand = participant.hand
    loop do
      break puts "#{name} chose to stay!" unless participant.hit?
      hand << dealer.deal
      puts "#{name} chose to hit! => #{hand.last}"
      puts "#{name} total: #{participant.total}"
    end
  end
end

class Player
  attr_accessor :hand
  attr_reader :name

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

  def total
    hand_value = hand.map do |card|
      face = card.match(/\d{1,2}|[JQKA]/)[0]
      Deck::FACE_VALUES[face]
    end
    hand_value.sum
    # needs to handle aces
  end
end

class Dealer
  DEALER_NAME = 'Dealer'

  attr_reader :name

  def initialize(deck = nil)
    @name = DEALER_NAME
    @deck = deck
    @hand = []
  end

  def deal
    deck.delete(deck.sample)
  end

  def hand(keep_private = true)
    return @hand if !keep_private
    public_cards = @hand.slice(1..@hand.length)
    public_cards
  end

  private

  def deck
    @deck.cards
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
end

Game.new.start
=begin
Player turn works but the Player#total method needs to handle aces
=end