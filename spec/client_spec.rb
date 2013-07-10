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

  describe "entree ingredients" do
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
