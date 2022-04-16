require 'pry-byebug'

class Player
  def intialize
    # what would the "data" or "states" of a Player object entail?
    # maybe cards? a name?
  end
  
  def hit; end
  
  def stay; end
  
  def busted?; end
  
  def total; end
end

class Dealer
  def intialize
    # what would the "data" or "states" of a Player object entail?
    # maybe cards? a name?
  end

  def deal; end # does the dealer deal or the deck? 
  
  def hit; end
  
  def stay; end
  
  def busted?; end
  
  def total; end
end

class Participant
  # what hsould go here? redundant behaviors between dealer and player?
end

class Deck
  SUITS = ['hearts', 'diamonds', 'clovers', 'spades']
  FACES = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)

  def initialize
    @current_deck = create_deck
    # what states or data should deck have?
    # what data structure should contain the cards
    # Card will probably be a collaborator object
  end

  def create_deck
    deck = []
    SUITS.each do |suit|
      FACES.each { |face| deck << Card.new(face, suit) }
    end
    binding.pry
    deck
  end

  def deal(n)
    # takes an arg for how many cards to deal and returns an array of card objects (even if only 1 el)
    removed_from_deck = []
    n.times { removed_from_deck << @current_deck.delete(@current_deck.sample) }
    removed_from_deck
  end

end

class Card
  def initialize(face, suit)
    @face = face
    @suit = suit
    # @value = face_value(face) # this may not be needed, a method in another (or this) class could compute from @face
  end

  def to_s; end #should be able to display its face and suit

  def value; end # should return its value based on its face. HOW TO HANDLE ACES?
end

class Game
  def initialize
    # what collaborator objects should this have?
    # what does Game need access to in order to orchestrate the game flow?
  end

  def start
    # welcome_player
    deal_cards
    show_initial_cards
    player_turn
    dealer_turn
    show_result
  end
end

# Game.new.start

my_deck = Deck.new
my_deck.deal(2)