class InvalidToken < StandardError; end
class StackEmpty < StandardError; end

require 'pry-byebug'

class Minilang
  @@rcgnzd_cmnds = %w(PUSH ADD SUB MULT DIV MOD POP PRINT)

  def initialize(commands)
    @register = 0
    @stack = []
    @commands = commands.split
  end

  def eval
    cmd_list = commands.map(&:downcase)
    cmd_list.each do |cmd|
      begin
        # binding.pry
        raise InvalidToken, "Invalid token: #{cmd}" unless valid_token?(cmd)
        raise(StackEmpty, "Empty Stack!") if stack.empty? && cmd_invalid_when_empty?(cmd)
        if integer?(cmd)
          self.register = cmd.to_i
        else
          send cmd
        end
      rescue InvalidToken => e
       puts e.message
       return nil
      rescue StackEmpty => e
       puts e.message
       return nil
      end
    end
  end

  def integer?(str)
    str =~ /\A[-+]?\d+\z/
  end

  def valid_token?(cmd)
    @@rcgnzd_cmnds.include?(cmd.upcase) || integer?(cmd)
  end

  def cmd_invalid_when_empty?(cmd)
    (@@rcgnzd_cmnds - ['PUSH', 'PRINT']).include?(cmd.upcase)
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
    self.register = register / stack.pop
  end

  def mod
    self.register = register % stack.pop
  end

  def pop
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