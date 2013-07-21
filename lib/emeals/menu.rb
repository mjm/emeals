require 'emeals/meal'

class Emeals::Menu
  attr_reader :meals

  def initialize(meals)
    @meals = meals
  end

  def count
    @meals.size
  end

  def self.parse(menu_text)
    Emeals::MenuParser.new(menu_text).parse
  end
end

class Emeals::MenuParser
  def initialize(menu_text)
    @menu_text = menu_text
  end

  def parse
    buffer = []
    meals  = []
    add_to_buffer = false

    @menu_text.split("\n").each do |line|
      if line =~ /Meal (\d+)/
        if add_to_buffer and !buffer.empty?
          meals << Emeals::Meal.parse(buffer.join("\n"))
        end

        add_to_buffer = meals.size < $1.to_i
        buffer = add_to_buffer ? [line] : []
        next unless add_to_buffer
      else
        buffer << line if add_to_buffer
      end
    end

    Emeals::Menu.new(meals)
  end
end

