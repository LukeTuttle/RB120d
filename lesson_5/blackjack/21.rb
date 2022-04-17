require 'pry-byebug'

# rubocop:todo Layout/TrailingWhitespace

class Deck
  SUITS = ['hearts', 'diamonds', 'clovers', 'spades']
  FACES = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)

  def initialize
    @cards = build_deck.shuffle
  end
  
  def deal
    @cards.pop
  end

  private

  def build_deck
    deck = []
    SUITS.each do |suit|
      FACES.each { |face| deck << Card.new(face, suit) }
    end
    deck
  end
end

class Card
  FACE_VALUES = Deck::FACES.zip(
    [2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 11]
  ).to_h

  def initialize(face, suit)
    @face = face
    @suit = suit
  end

  def to_s
    "#{@face} of #{@suit}"
  end

  def value
    FACE_VALUES[@face]
  end 
end

module Hand
  def add_card(new_card)
    cards << new_card
  end

  def total
    card_vals = cards.map(&:value)
    sum = card_vals.reduce(:+)

    card_vals.count(11).times do
      sum -= 10 unless sum < 22
    end
    sum
  end

  def show_hand
    cards.map(&:to_s).join(', ')
  end
  
  def busted?
    total > 22
  end

  def stay_msg
    puts "#{name} chose to stay!"
    sleep 0.5
    puts "#{name} now shows #{show_hand}"
    puts ""
    sleep 0.5
  end
end

class Participant
  attr_reader :name
  
  def initialize(name)
    @name = name
    @cards = []
  end

  def clear_cards
    @cards = []
  end

  private

  attr_reader :cards
end

class Player < Participant
  include Hand

  def initialize
    name = 'Luke'
    # name = ask_for_name
    super(name)
  end

  def hit?
    answer = nil
    puts "Would you like to hit or stay? (h/s):"
    loop do 
      answer = gets.chomp.downcase.strip
      break if ['h', 's'].include?(answer)
      puts "Invalid answer. h = hit, s = stay."
    end

    answer == 'h'
  end

  private

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
end

class Dealer < Participant
  include Hand

  def show_hand(reveal_hidden = false)
    reveal_hidden ? super() : show_public_hand
  end

  private

  def show_public_hand
    @cards.slice(1..).map(&:to_s).join(', ') + ', and ?' 
  end
end

class Game
  DEALER_NAMES = ["The Great Khan"]
  
  def initialize
    @dealer = Dealer.new(DEALER_NAMES.sample) 
    @player = Player.new
    @deck = Deck.new
  end

  def start
    welcome_player
    loop do
      single_game
      break unless play_again?
      reset
    end
    display_goodbye_message
  end

  private

  attr_reader :deck, :player, :dealer


  def single_game
    deal_cards
    show_initial_cards
    player_turn
    return display_result if player.busted?
    dealer_turn
    return display_result if dealer.busted?
    display_result
  end

  def reset
    binding.pry
    system 'clear'
    @deck = Deck.new
    player.clear_cards
    dealer.clear_cards
  end

  
  def welcome_player
    puts "Welcome to Twenty One. Good Luck!\n\n"
  end

  def deal_cards
    2.times do
      [player, dealer].each { |plyr| plyr.add_card(deck.deal) }
    end
  end

  def show_initial_cards
    puts "#{player.name} has: #{player.show_hand}"
    puts "Total: #{player.total}"
    puts ""
    
    puts "#{dealer.name} has: #{dealer.show_hand}"
    puts ""
  end
  
  def display_result
    !!who_busted? ? display_winner_by_bust : display_winner_by_cards
  end      
  
  def who_busted?
    return dealer if dealer.busted?
    return player if player.busted?
    nil
  end

  def display_winner_by_bust
    ppl = [player, dealer].sort_by { |prsn| prsn == who_busted? ? 0 : 1 }
    puts "#{ppl.first.name} busted!\n\n"
    puts "======= #{ppl.last.name} Wins! ======="
    show_final_cards
  end

  def show_final_cards
    puts "#{player.name} shows: #{player.show_hand}"
    puts "Total: #{player.total}"
    puts ""
    
    puts "#{dealer.name} shows: #{dealer.show_hand(true)}"
    puts "Total: #{dealer.total}"
    puts ""
  end

  def display_winner_by_cards
    winner = [player, dealer].max_by(&:total)
    puts "======= #{winner.name} Wins! ======="
    show_final_cards
    sleep 0.5
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n):"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end
    answer == 'y'
  end

  def display_goodbye_message
    puts "Thanks for playing! Goodbye!"
  end
  
  def player_turn
    loop do
      break unless player.hit?
      player.add_card(deck.deal)
      break if player.busted?
      #hit_msg could replace code below
      puts "You now have: #{player.show_hand}\n\nTotal: #{player.total}"
      sleep 0.5
    end
    player.stay_msg unless player.busted?
  end

  def dealer_turn
    puts "Dealer shows #{dealer.show_hand}"
    sleep 0.7
    until dealer.total >= 17
      puts "Dealer chose to hit!"
      dealer.add_card(deck.deal)
      break if dealer.busted?
    end
    dealer.stay_msg unless dealer.busted?
  end
end

Game.new.start
# rubocop:enable Layout/TrailingWhitespace

=begin
Progress: 

Next: need methods to hand displaying the game result

=end
