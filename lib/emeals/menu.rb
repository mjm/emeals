require 'emeals/meal'

class Emeals::Menu
  attr_reader :count, :meals

  def initialize
    @count = 0
    @meals = []
  end

  def parse!(menu_text)
    buffer = []
    add_to_buffer = false
    menu_text.split("\n").each do |line|
      if line =~ /Meal (\d+)/
        unless buffer.empty? and !add_to_buffer
          @count = @count + 1
          @meals << Emeals::Meal.new.parse!(buffer.join("\n"))
        end

        add_to_buffer = @count < $1.to_i
        buffer = add_to_buffer ? [line] : []
        next unless add_to_buffer
      else
        buffer << line if add_to_buffer
      end
    end
    self
  end

  def self.parse(menu_text)
    new.parse!(menu_text)
  end
end