# encoding: utf-8

require 'emeals/dish'

include Emeals

describe Ingredient do
  describe "#parse" do

    it "correctly parses lbs" do
      result = Ingredient.new('1/4', 'lb', 'ground pork sausage')
      expect(Ingredient.parse("\xC2\xBC lb ground pork sausage")).to eq result
    end

    it "correctly parses teaspoons" do
      result = Ingredient.new('1/4', 'teaspoon', 'kosher salt')
      expect(Ingredient.parse("\xC2\xBC teaspoon kosher salt")).to eq result
    end

    it "correctly parses tablespoons" do
      result = Ingredient.new(1, 'tablespoon', 'olive oil')
      expect(Ingredient.parse("1 tablespoon olive oil")).to eq result
    end

    it "correctly parses ounces" do
      result = Ingredient.new(14, 'oz', 'can diced tomatoes')
      expect(Ingredient.parse("14 oz can diced tomatoes")).to eq result
    end

    it "correctly parses cups" do
      result = Ingredient.new(1, 'cup', 'organic beef broth')
      expect(Ingredient.parse("1 cup organic beef broth")).to eq result
    end

    it "correctly parses cloves" do
      result = Ingredient.new(1, 'clove', 'garlic, minced')
      expect(Ingredient.parse("1 clove garlic, minced")).to eq result
    end

    it "correctly parses ingredients with no known unit" do
      result = Ingredient.new(1, nil, 'large egg')
      expect(Ingredient.parse("1 large egg")).to eq result
    end

    it "correctly parses plural units" do
      result = Ingredient.new(2, 'clove', 'garlic, minced')
      expect(Ingredient.parse("2 cloves garlic, minced")).to eq result
    end

  end
end