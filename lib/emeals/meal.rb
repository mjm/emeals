# encoding:utf-8

require 'emeals/dish'

class Emeals::Meal
  attr_reader :entree, :side, :flags, :times

  def initialize(entree = nil, side = nil)
    @entree = entree
    @side = side
    @flags = []
    @times = {}
  end

  def parse!(meal_text)
    parse_state = :header
    names = []
    entree_instructions = []
    side_instructions = []
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
            add_ingredients_to_dish(line, @entree)
          end
        when :side_ingredients
          if line =~ /^[A-Z]/
            entree_instructions << line
            parse_state = :entree_instructions
          else
            add_ingredients_to_dish(line, @side)
          end
        when :entree_instructions
          if line.include? "-------"
            add_instructions_to_dish(entree_instructions, @entree)
            parse_state = :side_instructions
          else
            entree_instructions << line
          end
        when :side_instructions
          if line =~ /^Copyright/
            side_instructions = side_instructions[0..-3]
            break
          else
            side_instructions << line
          end
        else

      end
    end

    add_instructions_to_dish(side_instructions, @side)
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

  INGREDIENT_REGEX = /(?:\d|\xC2\xBC|\xC2\xBD)+ .+?(?=, (?:\d|\xC2\xBC|\xC2\xBD)+|$)/

  def add_ingredients_to_dish(line, dish)
    if line =~ /^\d|\xC2\xBC|\xC2\xBD/
      line.scan(INGREDIENT_REGEX).each do |match|
        dish.ingredients << Emeals::Ingredient.parse(match)
      end
    else
      dish.ingredients.last.description << " #{line}"
    end
  end

  def add_instructions_to_dish(lines, dish)
    dish.instructions = lines.join(" ").split(/\. ?/)
  end
end
