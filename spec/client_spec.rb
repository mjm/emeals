require 'spec_helper'
require 'emeals'

describe Emeals::Client do
  subject(:client) { Emeals::Client.new }
  let(:menu_path) { File.join(File.dirname(__FILE__), 'fixtures', 'menu.pdf') }

  before(:each) do
    @menu = client.parse(menu_path)
  end

  it "counts the number of meals in the menu" do
    expect(@menu.count).to eq 7
  end

  describe "entree names" do
    it "reads the names of entrees when the side wraps to two lines" do
      meal = @menu.meals[5]
      expect(meal.entree.name).to eq "Baked Cod Provencal"
    end

    it "reads the names of entrees which wrap to two lines" do
      meal = @menu.meals.first
      expect(meal.entree.name).to eq "Spicy Sausage and Egg Scramble"
    end

    it "reads the names of entrees when both the side and entree wrap to two lines" do
      meal = @menu.meals.last
      expect(meal.entree.name).to eq "Peppery Grilled Ribeye Steaks"
    end
  end

  describe "side names" do
    it "reads the names of sides that are a single line" do
      meal = @menu.meals.first
      expect(meal.side.name).to eq "Oregano Roasted Zucchini"
    end

    it "reads the names of sides that wrap to two lines" do
      meal = @menu.meals[5]
      expect(meal.side.name).to eq "Roasted Asparagus with Sun-Dried Tomatoes"
    end

    it "reads the names of sides when both the side and entree wrap to two lines" do
      meal = @menu.meals.last
      expect(meal.side.name).to eq "Heirloom Tomato and Spinach Salad"
    end
  end
end