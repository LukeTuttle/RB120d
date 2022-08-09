class MinilangError < StandardError; end
class InvalidTokenError < MinilangError; end
class StackEmptyError < MinilangError; end

class Minilang
  @@rcgnzd_cmnds = %w(PUSH ADD SUB MULT DIV MOD POP PRINT)

  def initialize(commands)
    @commands = commands
  end

  def eval(*args)
    @register = 0
    @stack = []
    commands = format(@commands, *args)
    commands.split.each { |cmd| eval_cmd(cmd) }
  rescue MinilangError => e
    puts e.message
  end

  def eval_cmd(cmd)
    if @@rcgnzd_cmnds.include?(cmd)
      send(cmd.downcase)
    elsif cmd =~ /\A[-+]?\d+\z/
      self.register = cmd.to_i
    else
      raise InvalidTokenError, "Invalid token: #{cmd}"
    end
  end

  def integer?(str)
    str =~ /\A[-+]?\d+\z/
  end

  def push
    stack << register
  end

  def add
    self.register += stack.pop
  end

  def sub
    self.register -= stack.pop
  end

  def mult
    self.register *= stack.pop
  end

  def div
    self.register /= stack.pop.to_f
  end

  def mod
    self.register %= stack.pop
  end

  def pop
    raise(StackEmptyError, "Empty Stack!") if stack.empty?
    self.register = stack.pop
  end

  def print
    puts register
  end

  private

  attr_accessor :register
  attr_reader :stack, :commands
end

Minilang.new('PRINT').eval
# 0

Minilang.new('5 PUSH 3 MULT PRINT').eval
# 15

Minilang.new('5 PRINT PUSH 3 PRINT ADD PRINT').eval
# 5
# 3
# 8

Minilang.new('5 PUSH 10 PRINT POP PRINT').eval
# 10
# 5

Minilang.new('5 PUSH POP POP PRINT').eval
# Empty stack!

Minilang.new('3 PUSH PUSH 7 DIV MULT PRINT ').eval
# 6

Minilang.new('4 PUSH PUSH 7 MOD MULT PRINT ').eval
# 12
Minilang.new('-3 PUSH 5 XSUB PRINT').eval
# Invalid token: XSUB

Minilang.new('-3 PUSH 5 SUB PRINT').eval
# 8

Minilang.new('6 PUSH').eval
# (nothing printed; no PRINT commands)

puts '============='

CENTIGRADE_TO_FAHRENHEIT =
'5 PUSH %<degrees_c>d PUSH 9 MULT DIV PUSH 32 ADD PRINT'
Minilang.new(format(CENTIGRADE_TO_FAHRENHEIT, degrees_c: 100)).eval
# 212
Minilang.new(format(CENTIGRADE_TO_FAHRENHEIT, degrees_c: 0)).eval
# 32
Minilang.new(format(CENTIGRADE_TO_FAHRENHEIT, degrees_c: -40)).eval
# -40

puts '============='

CENTIGRADE_TO_FAHRENHEIT =
  '5 PUSH %<degrees_c>d PUSH 9 MULT DIV PUSH 32 ADD PRINT'
minilang = Minilang.new(CENTIGRADE_TO_FAHRENHEIT)
minilang.eval(degrees_c: 100)
# 212
minilang.eval(degrees_c: 0)
# 32
minilang.eval(degrees_c: -40)
# -40

puts '============='

MILES_PER_HOUR_TO_KM = '5 PUSH 3 DIV PUSH %<mph>d DIV PRINT'
minilang = Minilang.new(MILES_PER_HOUR_TO_KM)
minilang.eval(mph: 100)
