class Person
  attr_accessor :first_name, :last_name

  def initialize(full_name)
    parse_and_set_name(full_name)
  end

  def name
    "#{first_name} #{last_name}".strip
  end

  def name=(full_name)
    parse_and_set_name(full_name)
  end

  private

  def parse_and_set_name(full_name)
    full_name_arr = full_name.split
    self.first_name = full_name_arr.first
    self.last_name = full_name_arr.last if full_name_arr.size > 1
  end
end



bob = Person.new('Robert')
p bob.name                  # => 'Robert'
p bob.first_name            # => 'Robert'
p bob.last_name             # => ''
bob.last_name = 'Smith'
p bob.name                  # => 'Robert Smith'

bob.name = "John Adams"
p bob.first_name            # => 'John'
p bob.last_name             # => 'Adams'
puts bob
