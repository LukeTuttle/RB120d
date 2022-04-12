#Q1
#my initial attempt
# module Fuelable
#   def set_fuel_efficiency(km_traveled_per_liter)
#     @fuel_efficiency = km_traveled_per_liter
#   end

#   def set_fuel_capacity(liters_of_fuel_capacity)
#     @fuel_capacity = liters_of_fuel_capacity
#   end

#   def range
#     @fuel_capacity * @fuel_efficiency
#   end
# end


# class WheeledVehicle
#   attr_accessor :speed, :heading

#   include Fuelable

#   def initialize(tire_array, km_traveled_per_liter, liters_of_fuel_capacity)
#     @tires = tire_array
#     set_fuel_efficiency(km_traveled_per_liter)
#     set_fuel_capacity(liters_of_fuel_capacity)
#   end

#   def tire_pressure(tire_index)
#     @tires[tire_index]
#   end

#   def inflate_tire(tire_index, pressure)
#     @tires[tire_index] = pressure
#   end
# end

# class Auto < WheeledVehicle
#   def initialize
#     # 4 tires are various tire pressures
#     super([30,30,32,32], 50, 25.0)
#   end
# end

# class Motorcycle < WheeledVehicle
#   def initialize
#     # 2 tires are various tire pressures
#     super([20,20], 80, 8.0)
#   end
# end

# class Catamaran
#   attr_reader :propeller_count, :hull_count
#   attr_accessor :speed, :heading

#   include Fuelable

#   def initialize(num_propellers, num_hulls, km_traveled_per_liter, liters_of_fuel_capacity)
#     @propeller_count = num_propellers
#     @hull_count = num_hulls
#     set_fuel_efficiency(km_traveled_per_liter)
#     set_fuel_capacity(liters_of_fuel_capacity)
#   end
# end

## LS Solution
module Moveable
  attr_accessor :speed, :heading
  attr_writer :fuel_capacity, :fuel_efficiency

  def range
    modifier = self.class.ancestors.include?(WaterVehicle) ? 10 : 0
    (@fuel_capacity * @fuel_efficiency) + modifier
  end
end

class WheeledVehicle
  include Moveable

  def initialize(tire_array, km_traveled_per_liter, liters_of_fuel_capacity)
    @tires = tire_array
    self.fuel_efficiency = km_traveled_per_liter
    self.fuel_capacity = liters_of_fuel_capacity
  end

  def tire_pressure(tire_index)
    @tires[tire_index]
  end

  def inflate_tire(tire_index, pressure)
    @tires[tire_index] = pressure
  end
end

class WaterVehicle
  include Moveable

  attr_reader :propeller_count, :hull_count

  def initialize(num_propellers, num_hulls, km_traveled_per_liter, liters_of_fuel_capacity)
    @num_hulls = num_hulls
    @num_propellers = num_propellers
    self.fuel_efficiency = km_traveled_per_liter
    self.fuel_capacity = liters_of_fuel_capacity
  end
end

class Motorboat < WaterVehicle
  def initialize(km_traveled_per_liter, liters_of_fuel_capacity)
    super(1, 1, km_traveled_per_liter, liters_of_fuel_capacity)
  end
end

class Catamaran < WaterVehicle
    # ... other code to track catamaran-specific data omitted ...
end

# puts Motorboat.new(20, 40).inspect
# puts Catamaran.new(2,2, 2, 10).inspect

catamaran = Catamaran.new(2,2, 2, 10)
moto = WheeledVehicle.new([2], 2, 10)
puts catamaran.range 
puts moto.range