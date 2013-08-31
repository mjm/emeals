require 'multi_json'

module Emeals::JSON
  def to_json
    MultiJson.dump(meals.map { |meal| meal_json(meal) }, pretty: true)
  end

  private

  def meal_json(meal)
    {entree: dish_json(meal.entree), side: dish_json(meal.side)}
  end

  def dish_json(dish)
    {name: dish.name, ingredients: ingredients_json(dish.ingredients), instructions: dish.instructions.join("\n")}
  end

  def ingredients_json(ingredients)
    ingredients.map do |ing|
      {amount: format_amount(ing.quantity.amount), unit: ing.quantity.unit, description: ing.description}
    end
  end

  def format_amount(number)
    num_str = number.to_s
    if num_str.end_with? "/1"
      num_str[0..-3]
    else
      num_str
    end
  end
end
