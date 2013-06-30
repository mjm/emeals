class Emeals::Meal
  attr_accessor :entree, :side

  def initialize(entree, side)
    @entree = entree
    @side = side
  end
end

class Emeals::Dish
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end

class Emeals::Menu
  attr_reader :count, :meals

  def initialize
    @count = 0
    @meals = []
  end

  def parse!(menu_text)
    menu_text.split("\n").each do |line|
      if line =~ /Meal (\d+)/
        next if @count >= $1.to_i
        @count = @count + 1
        @meals << Emeals::Meal.new(Emeals::Dish.new("Meal #{$1}"), nil)
      end
    end
    self
  end

  def self.parse(menu_text)
    new.parse!(menu_text)
  end
end