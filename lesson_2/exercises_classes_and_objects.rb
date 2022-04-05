
#### OO Basics: Classes and Objects 1 ####

# module Walkable
#   def walk
#     puts "Let's go for a walk"
#   end
# end

# class Cat
#   include Walkable

#   attr_accessor :name

#   def initialize(name)
#     @name = name
#   end

#   def greet
#     puts "Hello! My name is #{name}!"
#   end
# end


# kitty = Cat.new('Sophie')
# kitty.greet
# kitty.name = 'Luna'
# kitty.greet
# kitty.walk

#### OO Basics: Classes and Objects 2 ####

# class Cat
#   attr_reader :name

#   @@n_cats = 0

#   def initialize(name)
#     @name = name
#     @@n_cats += 1
#   end

#   def indentify
#     self
#   end
  
#   def personal_greeting
#     puts "Hi! I'm #{name}!"
#   end

#   def self.total
#     puts @@n_cats
#   end

#   def self.generic_greeting
#     puts "Hello! I'm a cat!"
#   end
# end
# mittens = Cat.new('mittens')
# patches = Cat.new('patches')
# Cat.generic_greeting
# mittens.personal_greeting
# Cat.total

class Person
  attr_writer :secret

  def compare_secret(person)
    @secret == person.secret
  end

  private

  attr_reader :secret
end

person1 = Person.new
person1.secret = 'Shh.. this is a secret!'

person2 = Person.new
person2.secret = 'Shh.. this is a different secret!'

puts person1.compare_secret(person2)