# class House
#   attr_reader :price
  
#   include Comparable

#   def initialize(price)
#     @price = price
#   end

#   def <=> (other)
#     price <=> other.price
#   end

# end

# home1 = House.new(100_000)
# home2 = House.new(150_000)
# home2
# puts "Home 1 is cheaper" if home1 < home2
# puts "Home 2 is more expensive" if home2 > home1

# class Transform
#   def initialize(str)
#     @str = str
#   end

#   def uppercase
#     @str.upcase
#   end

#   def self.lowercase(str)
#     str.downcase
#   end
# end

# my_data = Transform.new('abc')
# puts my_data.uppercase
# puts Transform.lowercase('XYZ')

# class Wallet
#   include Comparable

#   def initialize(amount)
#     @amount = amount
#   end

#   def <=>(other_wallet)
#     amount <=> other_wallet.amount
#   end

#   protected

#    attr_reader :amount

# end

# bills_wallet = Wallet.new(500)
# pennys_wallet = Wallet.new(465)
# if bills_wallet > pennys_wallet
#   puts 'Bill has more money than Penny'
# elsif bills_wallet < pennys_wallet
#   puts 'Penny has more money than Bill'
# else
#   puts 'Bill and Penny have the same amount of money.'
# end

require 'pry-byebug'

# class Pet
#   attr_reader :type, :name

#   def initialize(type, name)
#     @type = type
#     @name = name
#   end
# end

# class Shelter
#   attr_reader :adoptions

#   def initialize
#     @adoptions = Hash.new
#   end

#   def adopt(owner, pet)
#     @adoptions[owner.name] = [] unless @adoptions.key?(owner.name)
#     @adoptions[owner.name].push [pet.type, pet.name]
#     owner.add_pet
#   end

#   def print_adoptions
#     @adoptions.each_pair do |owner, pets|
#       puts "#{owner} has adopted the following pets:"
#       pets.each { |(type, name)| puts "a #{type} named #{name}" }
#       puts ''
#     end
#   end
# end

# class Owner
#   attr_reader :name

#   def initialize(name)
#     @name = name
#     @n_pets = 0
#   end

#   def number_of_pets
#     @n_pets
#   end

#   # protected

#   def add_pet
#     @n_pets += 1
#   end
# end

# class Pet
#   attr_reader :animal, :name

#   @@existing_pets = []

#   def self.existing_pets
#     @@existing_pets
#   end

#   def initialize(animal, name)
#     @animal = animal
#     @name = name
#     @@existing_pets << self
#   end

#   def to_s
#     "a #{animal} named #{name}"
#   end
# end

# class Owner
#   attr_reader :name, :pets

#   def initialize(name)
#     @name = name
#     @pets = []
#   end

#   def add_pet(pet)
#     @pets << pet
#   end

#   def number_of_pets
#     pets.size
#   end

#   def print_pets
#     puts pets
#   end
# end

# class Shelter
#   def initialize
#     @owners = {}
#     @pets = Pet.existing_pets
#   end

#   def adopt(owner, pet)
#     owner.add_pet(pet)
#     @owners[owner.name] ||= owner
#     @pets.delete(pet)
#   end

#   def pets_under_care
#     @pets.each { |pet| puts pet }
#   end

#   def print_adoptions
#     @owners.each_pair do |name, owner|
#       puts "#{name} has adopted the following pets:"
#       owner.print_pets
#       puts
#     end
#   end

#   def print_available_for_adoption
#     puts "The Animal Shelter has the following unadopted pets:"
#     @pets.each {|pet| puts pet}
#   end
# end

# butterscotch = Pet.new('cat', 'Butterscotch')
# pudding      = Pet.new('cat', 'Pudding')
# darwin       = Pet.new('bearded dragon', 'Darwin')
# kennedy      = Pet.new('dog', 'Kennedy')
# sweetie      = Pet.new('parakeet', 'Sweetie Pie')
# molly        = Pet.new('dog', 'Molly')
# chester      = Pet.new('fish', 'Chester')


# phanson = Owner.new('P Hanson')
# bholmes = Owner.new('B Holmes')

# shelter = Shelter.new
# shelter.print_available_for_adoption
# shelter.adopt(phanson, butterscotch)
# shelter.adopt(phanson, pudding)
# shelter.adopt(phanson, darwin)
# shelter.adopt(bholmes, kennedy)
# shelter.adopt(bholmes, sweetie)
# # shelter.adopt(bholmes, molly)
# # shelter.adopt(bholmes, chester)

# shelter.print_adoptions
# puts "#{phanson.name} has #{phanson.number_of_pets} adopted pets."
# puts "#{bholmes.name} has #{bholmes.number_of_pets} adopted pets."

# shelter.print_available_for_adoption

# class Expander
#   def initialize(string)
#     @string = string
#   end

#   def to_s
#     self.expand(3)
#   end

#   private

#   def expand(n)
#     @string * n
#   end
# end

# expander = Expander.new('xyz')
# puts expander

# didnt complete this on my own but read through the explanation
# module Walkable
#   def walk
#     if self.class == "Noble"
#       puts "#{name}"
#     puts "#{name} #{gait} forward"
#   end
# end

# class Person
#   attr_reader :name
#   include Walkable
#   def initialize(name)
#     @name = name
#   end

#   private

#   def gait
#     "strolls"
#   end
# end

# class Cat
#   attr_reader :name
#   include Walkable
#   def initialize(name)
#     @name = name
#   end

#   private

#   def gait
#     "saunters"
#   end
# end

# class Cheetah
#   attr_reader :name
#   include Walkable
#   def initialize(name)
#     @name = name
#   end

#   private

#   def gait
#     "runs"
#   end
# end

# class Noble
#   attr_reader :name, :title
#   include Walkable

#   def initialize(name, title)
#     @name = name
#     @title = title
#   end

#   private

#   def gait
#     "struts"
#   end

# end

# mike = Person.new("Mike")
# mike.walk
# # => "Mike strolls forward"

# kitty = Cat.new("Kitty")
# kitty.walk
# # => "Kitty saunters forward"

# flash = Cheetah.new("Flash")
# flash.walk
# # => "Flash runs forward"

# byron = Noble.new("Byron", "Lord")
# p byron.walk
# # => "Lord Byron struts forward"