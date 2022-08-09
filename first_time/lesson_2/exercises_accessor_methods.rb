# class Person
#   attr_writer :age
#   def older_than?(other)
#     age > other.age
#   end

#   protected 

#   attr_reader :age
# end

# person1 = Person.new
# person1.age = 17

# person2 = Person.new
# person2.age = 26

# puts person1.older_than?(person2)

# class Person
#   attr_reader :name
#   def name=(str)
#     @name = str.capitalize
#   end
# end

# person1 = Person.new
# person1.name = 'eLiZaBeTh'
# puts person1.name

# class Person
#   attr_writer :name
#   def name
#     "Mr. #{@name}"
#   end
# end

# person1 = Person.new
# person1.name = 'James'
# puts person1.name

# class Person
#   def initialize(name)
#     @name = name
#   end

#   def name
#     @name.clone
#   end
# end

# person1 = Person.new('James')
# person1.name.reverse!
# puts person1.name

# class Person
#   def age=(age)
#     @age = age * 2
#   end

#   def age
#     @age = @age * 2
#   end
# end

# person1 = Person.new
# person1.age = 20
# puts person1.age

class Person
  def name=(name)
    @first_name = name.split.first
    @last_name = name.split.last
  end

  def name
    [@first_name, @last_name].join ' '
  end
  
end

person1 = Person.new
person1.name = 'John Doe'
puts person1.name