require 'emeals'

TEMPLATE_DIR = File.join(File.dirname(__FILE__), '..', 'fixtures')

DEFAULT_MEAL_OPTIONS = {
  entree: "Spicy Sausage and Egg\nScramble",
  side: "Oregano Roasted Zucchini",
  flags: "",
  prep_time: '10m',
  cook_time: '20m',
  total_time: '30m',
  entree_ingredients: "",
  side_ingredients: "",
  entree_instructions: "",
  side_instructions: "",
  before: "",
  after: ""
}

def make_meal(options = {})
  options = DEFAULT_MEAL_OPTIONS.merge(options)

  ctx = Object.new
  def ctx.evaluate(options)
    options.each {|k,v| instance_variable_set("@#{k}", v) }
    ERB.new(File.read(File.join(TEMPLATE_DIR, 'meal.erb')), nil, '-').result(binding)
  end
  Emeals::MealParser.new(ctx.evaluate(options)).parse
end
