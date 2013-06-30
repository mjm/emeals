class Emeals::Meal
  attr_reader :entree, :side

  def initialize(entree = nil, side = nil)
    @entree = entree
    @side = side
  end

  def parse!(meal_text)
    parse_state = :header
    names = []
    meal_text.split("\n").each do |line|
      case parse_state
        when :header
          parse_state = :names
        when :names
          if line =~ /Prep Cook Total/
            parse_state = :times
          else
            names << line
          end
        else

      end
    end

    entree_name, side_name = separate_entree_and_side_names(names)
    @entree = Emeals::Dish.new(entree_name)
    @side = Emeals::Dish.new(side_name)

    self
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
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end