require 'spec_helper'
require 'emeals'

describe Emeals::Client do
  subject(:client) { Emeals::Client.new }
  let(:menu_path) { File.join(File.dirname(__FILE__), 'fixtures', 'menu.pdf') }

  before(:each) do
    @menu = client.parse(menu_path)
    @meals = @menu.meals
  end

  context "when given a File handle instead of a filename" do
    it "completes successfully" do
      File.open(menu_path) do |file|
        expect(client.parse(file).count).to eq 7
      end
    end
  end

  it "counts the number of meals in the menu" do
    expect(@menu.count).to eq 7
  end

  describe "entree names" do
    it "reads the names of entrees when the side wraps to two lines" do
      expect(@meals[5].entree.name).to eq "Baked Cod Provencal"
    end

    it "reads the names of entrees which wrap to two lines" do
      expect(@meals.first.entree.name).to eq "Spicy Sausage and Egg Scramble"
    end

    it "reads the names of entrees when both the side and entree wrap to two lines" do
      expect(@meals.last.entree.name).to eq "Peppery Grilled Ribeye Steaks"
    end
  end

  describe "side names" do
    it "reads the names of sides that are a single line" do
      expect(@meals.first.side.name).to eq "Oregano Roasted Zucchini"
    end

    it "reads the names of sides that wrap to two lines" do
      expect(@meals[5].side.name).to eq "Roasted Asparagus with Sun-Dried Tomatoes"
    end

    it "reads the names of sides when both the side and entree wrap to two lines" do
      expect(@meals.last.side.name).to eq "Heirloom Tomato and Spinach Salad"
    end
  end

  describe "flags" do
    it "reads a meal with no flags correctly" do
      expect(@meals.first.flags).to be_empty
    end

    it "reads the slow cooker flag correctly" do
      expect(@meals[1].flags).to eq [:slow_cooker]
      expect(@meals[1]).to be_slow_cooker
    end

    it "reads the on the grill flag correctly" do
      expect(@meals[3].flags).to eq [:on_the_grill]
      expect(@meals[3]).to be_on_the_grill
    end

    it "reads the super fast flag correctly" do
      expect(@meals[5].flags).to eq [:super_fast]
      expect(@meals[5]).to be_super_fast
    end

    it "reads the marinate ahead flag correctly" do
      expect(@meals[6].flags).to eq [:marinate_ahead]
      expect(@meals[6]).to be_marinate_ahead
    end
  end

  describe "times" do
    it "reads prep times correctly" do
      expect(@meals.first.times[:prep]).to eq "10m"
      expect(@meals[5].times[:prep]).to eq "15m"
    end

    it "reads cook times correctly" do
      expect(@meals.first.times[:cook]).to eq "20m"
      expect(@meals[1].times[:cook]).to eq "4h"
    end

    it "reads total times correctly" do
      expect(@meals.first.times[:total]).to eq "30m"
      expect(@meals[1].times[:total]).to eq "4h 10m"
    end
  end

  describe "entree ingredients" do
    include Emeals

    let(:dish) { @meals.first.entree }

    it "reads the correct number of ingredients" do
      expect(dish.ingredients.size).to be 5
    end

    it "reads the correct descriptions of ingredients" do
      expect(dish.ingredients[1].description).to eq "small onion, minced"
      expect(dish.ingredients[3].description).to eq "kosher salt"
      expect(dish.ingredients[4].description).to eq "pepper"
    end

    it "reads the correct quantities of ingredients" do
      expect(dish.ingredients[0].quantity).to eq Emeals::Quantity.new('1/4', 'lb')
      expect(dish.ingredients[1].quantity).to eq Emeals::Quantity.new('1/2')
      expect(dish.ingredients[2].quantity).to eq Emeals::Quantity.new('4')
    end
  end

  describe "side ingredients" do
    include Emeals

    let(:dish) { @meals[3].side }

    it "reads the correct number of ingredients" do
      expect(dish.ingredients.size).to be 5
    end

    it "reads the correct descriptions of ingredients" do
      expect(dish.ingredients[0].description).to eq "(5-oz) bag baby spinach"
      expect(dish.ingredients[1].description).to eq "drained and chopped roasted red bell peppers"
      expect(dish.ingredients[2].description).to eq "pitted kalamata olives, cut in half"
    end

    it "reads the correct quantities of ingredients" do
      expect(dish.ingredients[0].quantity).to eq Emeals::Quantity.new('1/2')
      expect(dish.ingredients[3].quantity).to eq Emeals::Quantity.new('2')
      expect(dish.ingredients[4].quantity).to eq Emeals::Quantity.new('1/4', 'cup')
    end
  end

  describe "entree instructions" do
    let(:dish) { @meals[2].entree }

    it "reads the correct number of instructions" do
      expect(dish.instructions.size).to be 7
    end

    it "reads the correct text of the instructions" do
      expect(dish.instructions[0]).to eq "Preheat oven to 425 degrees"
      expect(dish.instructions[4]).to eq "Dip fish in egg mixture; dredge in almond flour"
      expect(dish.instructions[6]).to eq "Bake 8 minutes or until fish flakes with a fork"
    end
  end

  describe "side instructions" do
    let(:dish) { @meals[2].side }

    it "reads the correct number of instructions" do
      expect(dish.instructions.size).to be 7
    end

    it "reads the correct text of the instructions" do
      expect(dish.instructions[0]).to eq "Preheat oven to 425 degrees"
      expect(dish.instructions[1]).to eq "Toss zucchini, 1 tablespoon oil, salt and pepper on a large baking sheet; spread into a single layer"
      expect(dish.instructions[6]).to eq "Bake 20 minutes or until center is set"
    end

    context "when the meal is the last on the page" do
      let(:dish) { @meals[3].side }

      it "reads the correct number of instructions" do
        expect(dish.instructions.size).to be 1
      end

      it "reads the correct instruction text" do
        expect(dish.instructions.first).to eq "Combine spinach, roasted bell peppers, olives, pepperoncini peppers and vinaigrette in a large bowl; toss well to coat"
      end
    end
  end
end
