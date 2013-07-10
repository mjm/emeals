# encoding: utf-8

class Emeals::Dish
  attr_reader :name, :ingredients, :instructions

  def initialize(name, ingredients = [], instructions = [])
    @name = name
    @ingredients = ingredients
    @instructions = instructions
  end
end

class Emeals::Quantity
  UNITS = %w(teaspoon tablespoon cup oz lb bag clove).map(&:to_sym)
  UNITS_WITH_PLURALS = UNITS + UNITS.map {|u| "#{u}s".to_sym }

  attr_reader :amount, :unit

  def initialize(amount, unit = nil)
    @amount = to_amount(amount)
    @unit   = unit && unit.to_sym
  end

  def ==(other)
    other.amount == @amount && other.unit == @unit
  end

  private

  def to_amount(str)
    case str
      when "\xC2\xBC"; '1/4'
      when "\xC2\xBD"; '1/2'
      else             str
    end.to_r
  end
end

class Emeals::Ingredient
  attr_reader :quantity, :description

  def initialize(amount, unit, description)
    @quantity = Emeals::Quantity.new(amount, unit)
    @description = description
  end

  PARSE_REGEX = /((?:\d|\xC2\xBC|\xC2\xBD)+) (?:(#{Emeals::Quantity::UNITS_WITH_PLURALS.join("|")}) )?(.+)/

  def self.parse(line)
    if line =~ PARSE_REGEX
      amount, unit, description = $1, $2, $3
      new(amount, unit && unit.sub(/s$/, ''), description)
    else
      raise "tried to parse improperly formatted ingredient: #{line.inspect}"
    end
  end

  def ==(other)
    other.quantity == @quantity && other.description == @description
  end
end
