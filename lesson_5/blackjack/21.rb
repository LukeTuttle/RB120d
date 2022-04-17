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
    # sum = 0
    cards.map(&:value).reduce(:+)
  end

  def show_hand
    @cards.map(&:to_s).join(', ')
  end

  def hit; end
  
  def stay; end
  
  def busted?; end
end

class Participant
  attr_reader :name
  
  def initialize(name)
    @name = name
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

  # displaying hand note: if the method to do this is shared with Player
  # then its not a bad idea to have Dealer have its own version which can
  # handle showing their cards but hides the hidden one.. maybe something like:
  # def disp_hand
      # public_hand = @hand.hide_card # or something like that
      # super(public_hand)
  # end
  
  def hit; end
  
  def stay; end
  
  def busted?; end
  
end

class Game
  DEALER_NAMES = ["The Great Khan"]
  
  def initialize
    welcome_player
    @dealer = Dealer.new(DEALER_NAMES.sample) 
    @human = Player.new
    @deck = Deck.new
    # @current_player ...do I need this? 
    # what does Game need access to in order to orchestrate the game flow?
  end

  def start
    # welcome_player
    # binding.pry
    deal_cards
    show_initial_cards
    player_turn
    dealer_turn
    show_result
  end

  private

  attr_reader :deck, :human, :dealer

  def welcome_player
    puts "Welcome to Twenty One. Good Luck!"
  end

  def deal_cards
    2.times do
      [human, dealer].each { |plyr| plyr.add_card(deck.deal) }
    end
  end

  def show_initial_cards
    puts "#{human.name} has: #{human.show_hand}"
    puts "Total: #{human.total}\n\n"
    
    puts "#{dealer.name} has: #{dealer.show_hand}"
    # binding.pry
    puts "Total: #{dealer.total}\n\n"
  end
  
  def clear
    #for clearing the screen
  end


end

Game.new.start
# rubocop:enable Layout/TrailingWhitespace

=begin
progress:

User is welcomed with message and prompted for their name upon initialization
of the Player object which is collaborator in the game class. After getting the
user name, the program deals 2 cards to the Dealer and the Player.

Next: 
- need to figure out how want to hand displaying a participants cards
- also wondering if I should expose getter/setter methods for Participant 'hand's 
- should I call @hand in Particpant instances @cards instead?. 
=end