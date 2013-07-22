# encoding:utf-8

require 'emeals/dish'

class Emeals::Meal
  attr_reader :entree, :side, :flags, :times

  def initialize(entree = nil, side = nil, flags = [], times = {})
    @entree = entree
    @side = side
    @flags = flags
    @times = times
  end

  def self.parse(meal_text)
    Emeals::MealParser.new(meal_text).parse
  end

  FLAGS = {
    "Slow Cooker"    => :slow_cooker,
    "On the Grill"   => :on_the_grill,
    "Super Fast"     => :super_fast,
    "Marinate Ahead" => :marinate_ahead
  }

  FLAGS.values.each do |flag|
    define_method "#{flag}?" do
      @flags.include? flag
    end
  end
end

class Emeals::MealParser
  def initialize(meal_text)
    @meal_text = meal_text
  end

  def parse
    entree_name = side_name = flags = nil
    names = entree_ingredients = side_ingredients = []
    times = {}
    parse_state = :header
    entree_instructions = []
    side_instructions = []
    @meal_text.split("\n").each do |line|
      case parse_state
      when :header
        flags, parse_state = parse_flags(line)
      when :names
        entree_name, side_name, names, entree_ingredients, parse_state = parse_names(line, names)
      when :times
        times, parse_state = parse_times(line)
      when :entree_ingredients
        entree_ingredients, parse_state = parse_entree_ingredients(line, entree_ingredients)
      when :side_ingredients
        side_ingredients, entree_instructions, parse_state = parse_side_ingredients(line, side_ingredients)
      when :entree_instructions
        entree_instructions, parse_state = parse_entree_instructions(line, entree_instructions)
      when :side_instructions
        side_instructions, parse_state = parse_side_instructions(line, side_instructions)
      else
        break
      end
    end
    entree = Emeals::Dish.new(entree_name, entree_ingredients, format_instructions(entree_instructions))
    side   = Emeals::Dish.new(side_name,   side_ingredients,   format_instructions(side_instructions))
    Emeals::Meal.new(entree, side, flags, times)
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
    [Emeals::Meal::FLAGS.select {|flag, sym| line.include? flag }.values, :names]
  end

  def parse_names(line, names)
    if line =~ /Prep Cook Total/
      entree_name, side_name = separate_entree_and_side_names(names)
      [entree_name, side_name, nil, [], :times]
    elsif line =~ /^#{NUMBER_PATTERN}/
      entree_name, side_name = separate_entree_and_side_names(names)
      [entree_name, side_name, nil, *parse_entree_ingredients(line, [])]
    else
      [nil, nil, names + [line], [], :names]
    end
  end

  def parse_times(line)
    times = line.split(" ")
    [{prep: times.first, cook: times[1], total: times[2..-1].join(" ")}, :entree_ingredients]
  end

  def parse_entree_ingredients(line, ingredients)
    if line.include? "-------"
      [ingredients, :side_ingredients]
    else
      [find_ingredients(ingredients, line), :entree_ingredients]
    end
  end

  def parse_side_ingredients(line, ingredients)
    if line =~ /^[A-Z]/ and not line =~ /^Zest/
      [ingredients, [line], :entree_instructions]
    else
      [find_ingredients(ingredients, line), nil, :side_ingredients]
    end
  end

  def parse_entree_instructions(line, instructions)
    if line.include? "-------"
      [instructions, :side_instructions]
    else
      [instructions + [line], :entree_instructions]
    end
  end

  def parse_side_instructions(line, instructions)
    if line =~ /^Copyright/
      [instructions[0..-3], nil]
    else
      [instructions + [line], :side_instructions]
    end
  end

  NUMBER_PATTERN = Emeals::Ingredient::NUMBER_PATTERN
  INGREDIENT_REGEX = /(?:#{NUMBER_PATTERN})+ .+?(?=, (?:#{NUMBER_PATTERN})+|$)/

  def find_ingredients(ingredients, line)
    if line =~ /^#{NUMBER_PATTERN}/
      ingredients + line.scan(INGREDIENT_REGEX).map do |match|
        Emeals::Ingredient.parse(match)
      end
    elsif line =~/^Zest/
      # Special case this
      ingredients + [Emeals::Ingredient.new(1, nil, line)]
    else
      # TODO we shouldn't be modifying this in-place
      ingredients.last.description << " #{line}"
      ingredients
    end
  end

  def format_instructions(instructions)
    instructions.join(" ").split(/\. ?/)
  end
end
