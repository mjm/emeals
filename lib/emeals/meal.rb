# coding: UTF-8

class Emeals::Meal
  attr_reader :entree, :side, :flags, :times

  def initialize
    @entree = entree
    @side = side
    @flags = []
    @times = {}
  end

  def parse!(meal_text)
    parse_state = :header
    names = []
    meal_text.split("\n").each do |line|
      case parse_state
        when :header
          parse_flags(line)
          parse_state = :names
        when :names
          if line =~ /Prep Cook Total/
            entree_name, side_name = separate_entree_and_side_names(names)
            @entree = Emeals::Dish.new(entree_name)
            @side = Emeals::Dish.new(side_name)
            parse_state = :times
          else
            names << line
          end
        when :times
          parse_times(line)
          parse_state = :entree_ingredients
        when :entree_ingredients
          if line.include? "-------"
            parse_state = :side_ingredients
          else
            line.scan(/((?:\d|¼|½)+) (.+?)(?=, (?:\d|¼|½)+|$)/).each do |quantity, description|
              @entree.ingredients << Emeals::Ingredient.new(quantity, description)
            end
          end
        else

      end
    end

    self
  end

  FLAGS = {
      "Slow Cooker"    => :slow_cooker,
      "On the Grill"   => :on_the_grill,
      "Super Fast"     => :super_fast,
      "Marinate Ahead" => :marinate_ahead
  }

  %w(slow_cooker on_the_grill super_fast marinate_ahead).each do |flag|
    define_method "#{flag}?" do
      @flags.include? flag.to_sym
    end
  end

  def parse_flags(line)
    FLAGS.each do |flag, sym|
      @flags << sym if line.include? flag
    end
  end

  def parse_times(line)
    times = line.split(" ")
    @times[:prep] = times.first
    @times[:cook] = times[1]
    @times[:total] = times[2..-1].join(" ")
  end

  private

  def separate_entree_and_side_names(names)
    case names.size
      when 2
        names
      when 3
        if names[1].length < names[0].length
          [join_names(names[0..1]), names[2]]
        else
          [names[0], join_names(names[1..2])]
        end
      else
        [join_names(names[0..1]), join_names(names[2..-1])]
    end
  end

  def join_names(names)
    names.join(" ").gsub('- ', '-')
  end
end

class Emeals::Dish
  attr_accessor :name, :ingredients, :instructions

  def initialize(name)
    @name = name
    @ingredients = []
    @instructions = []
  end
end

class Emeals::Ingredient
  attr_accessor :quantity, :description

  def initialize(quantity, description)
    @quantity = to_quantity(quantity)
    @description = description
  end

  private

  def to_quantity(str)
    case str
      when "¼"; '1/4'
      when "½"; '1/2'
      else      str
    end.to_r
  end
end