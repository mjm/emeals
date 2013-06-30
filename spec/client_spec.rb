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

  it "reads the names of the entrees" do
    pending "need more work on parsing"

    meal = @menu.meals.first
    expect(meal.entree.name).to eq "Spicy Sausage and Egg Scramble"
  end
end