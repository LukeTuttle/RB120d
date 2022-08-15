# teddy = Dog.new
# puts teddy.speak           # => "bark!"
# puts teddy.swim           # => "swimming!"

# Bulldog.new.swim

class Pet
  def run
    'running!'
  end

  def jump
    'jumping!'
  end
end

class Dog < Pet
  def speak
    'bark!'
  end

  def swim
    'swimming!'
  end

  def fetch
    'fetching!'
  end
end

class Bulldog < Dog
  def swim
    "can't swim!"
  end
end

class Cat < Pet
  def speak
   "meow!"
  end
end

pete = Pet.new
kitty = Cat.new
dave = Dog.new
bud = Bulldog.new

puts pete.run                # => "running!"
# pete.speak              # => NoMethodError

puts kitty.run               # => "running!"
puts kitty.speak             # => "meow!"
# kitty.fetch             # => NoMethodError

puts dave.speak              # => "bark!"

puts bud.run                 # => "running!"
puts bud.swim                # => "can't swim!"


=begin 
Q: What is the method lookup path and how is it important?

A: The method lookup path is the order in which ruby searches
through classes and modules in order to find the definition of the method
invoked. It is important because it is this order which allows us 
to override inherited methods and also to implement polymorphism across
classes. An example of this is that all classes inherit some basic functionality
from the Object class. 