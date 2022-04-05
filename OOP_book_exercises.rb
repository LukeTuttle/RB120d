
module Towing
  def tow_baby_tow
    puts "Yeehaw! I'm haulin' a big one!"
  end

  def can_tow?(pounds)
    pounds < 2000
  end
end




class Vehicle
  attr_accessor :color
  attr_reader :year, :model

  @@n_vehicles = 0

  def self.n_vehicles
    puts "This program has created #{@@n_vehicles} vehicles."
  end

  def initialize(y, c, m)
    @@n_vehicles += 1
    @born = Time.now
    @year = y
    @color = c
    @model = m
    @speed = 0
  end

  def speed_up(amount)
    @speed += amount
  end

  def slow_down(amount)
    return 0 if (@speed - amount).negative?

    @speed -= amount
  end

  def current_speed
    puts "You are now going #{@speed}"
  end

  def shut_down
    @speed = 0
    puts "Let's park this beast!"
  end

  def spray_paint(color)
    self.color = color
    puts "Your new #{color} paint job looks great!"
  end

  def self.gas_mileage(gallons, miles)
    puts "#{miles / gallons} miles per gallon of gas"
  end

  def age
    puts "This #{self.model} is #{compute_age} years old"
  end

  private

  def compute_age
    (Time.now.year - self.year)
  end

end

class MyTruck < Vehicle
  include Towing

  NUMBER_OF_DOORS = 2

  def to_s
    "My truck is a #{self.color} #{self.year} #{self.model} travelling at #{@speed} mph"
  end
end

class MyCar < Vehicle
  NUMBER_OF_DOORS = 4

  def to_s
    "My car is a #{self.color} #{self.year} #{self.model} travelling at #{@speed} mph"
  end
end

class Student
  attr_accessor :name
  attr_writer :grade

  def initialize(name, grade)
    @name = name
    @grade = grade
  end

  def better_grade_than?(other_student)
    @grade > other_student.grade
  end

  protected

  def grade
    @grade
  end
end

fiesta = MyCar.new('2004', 'white', 'fiesta')
silverado = MyTruck.new('2010', 'red', 'silverado')
ridgeline = MyTruck.new('2014', 'grey', 'ridgeline')

# silverado = MyTruck.new(1997, 'white', 'silverado')
# silverado.speed_up(20)
# silverado.current_speed
# silverado.speed_up(20)
# silverado.current_speed
# silverado.slow_down(20)
# silverado.current_speed
# silverado.slow_down(20)
# silverado.current_speed
# silverado.shut_down
# MyCar.gas_mileage(13, 351)
# silverado.spray_paint("red")
# p silverado.model
# p silverado.year
# puts silverado
# silverado.age
# puts MyCar.ancestors
# puts MyTruck.ancestors
# puts Vehicle.ancestors

joe = Student.new('Joe', 90)
bob = Student.new('Bob', 84)
puts "Well done!" if joe.better_grade_than?(bob)