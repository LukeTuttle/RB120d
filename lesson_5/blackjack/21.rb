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
      # break if sum < 22
    end
    sum
  end

  def show_hand
    cards.map(&:to_s).join(', ')
  end

  # def hit; end
  
  def stay; end
  
  def busted?
    total > 22
  end
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

  # displaying hand note: if the method to do this is shared with Player
  # then its not a bad idea to have Dealer have its own version which can
  # handle showing their cards but hides the hidden one.. maybe something like:
  # def disp_hand
      # public_hand = @hand.hide_card # or something like that
      # super(public_hand)
  # end 

  def show_hand(reveal_hidden = false)
    reveal_hidden ? super : show_public_hand
  end

  private

  def show_public_hand
    @cards.slice(1..).map(&:to_s).join(', ') + ', and ?' 
  end

  
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
    loop do
      loop do
        deal_cards
        show_initial_cards
        player_turn
        break if human.busted?
        dealer_turn
        break if dealer.busted?
        # show_result # not sure I need this
      end
      # need a mthod to handle out put to stdout if someone busted
      # display_winner
      break unless play_again?
    end
    display_goodbye_message
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
    puts "Total: #{human.total}"
    puts ""
    
    puts "#{dealer.name} has: #{dealer.show_hand}"
    puts ""
  end
  
  def player_turn
    # clear
    loop do
      if human.hit?
        binding.pry
        human.add_card(deck.deal)
        break if human.busted?
        puts "You now have: #{human.show_hand}\n\nTotal: #{human.total}"
        sleep 0.5
      else
        break
      end
    end
    puts "#{human.name} chooses to stay." unless human.busted?
  end

  def dealer_turn
    puts "Dealer shows #{dealer.show_hand}"
    until dealer.total >= 17
      puts "Dealer chose to hit!"
      dealer.add_card(deck.deal)
      sleep 0.5
      if dealer.busted?
        puts "Dealer busted!"
        break
      end
      puts "Dealer now shows #{dealer.show_hand}"
      sleep 0.5
    end
    binding.pry
    puts "#{dealer.name} chooses to stay." unless dealer.busted?
  end

  def clear # unless this grows to more than one line you dont need it
    system 'clear'
  end
end

Game.new.start
# rubocop:enable Layout/TrailingWhitespace

=begin
Progress: Now have a way to show dealer hand (keeping hidden card hidden) and player hand 
using method with same name `show_hand`. 

Next: need to figure out player turn. How to handle consequences of player hitting-
(ie adding a card to players cards), cant add card to hand from inside player class 
because deck is not a collaborator object. Could do in the Game class but the player
  turn method will get pretty big. 

=end