require 'spec_helper'

require 'emeals/meal'

describe Emeals::MealParser do
  describe "entree names" do
    let(:entree1) { make_meal(entree: 'Baked Cod Provencal').entree.name }
    let(:entree2) { make_meal(entree: 'Baked Cod Provencal',
                              side:   "A Side That Wraps Onto\nTwo Lines").entree.name }
    let(:entree3) { make_meal.entree.name }
    let(:entree4) { make_meal(side: "A Side That Wraps Onto\nTwo Lines").entree.name }

    it "reads the names of entrees when entree and side are single-line" do
      expect(entree1).to eq "Baked Cod Provencal"
    end

    it "reads the names of entrees when the side wraps to two lines" do
      expect(entree2).to eq "Baked Cod Provencal"
    end

    it "reads the names of entrees which wrap to two lines" do
      expect(entree3).to eq "Spicy Sausage and Egg Scramble"
    end

    it "reads the names of entrees when both the side and entree wrap to two lines" do
      expect(entree4).to eq "Spicy Sausage and Egg Scramble"
    end
  end

  describe "side names" do
    let(:side1) { make_meal(entree: 'Baked Cod Provencal').side.name }
    let(:side2) { make_meal.side.name }
    let(:side3) { make_meal(entree: 'Baked Cod Provencal',
                              side:   "A Side That Wraps Onto\nTwo Lines").side.name }
    let(:side4) { make_meal(side: "A Side That Wraps Onto\nTwo Lines").side.name }

    it "reads the names of sides when entree and side are single-line" do
      expect(side1).to eq "Oregano Roasted Zucchini"
    end

    it "reads the names of sides when the side wraps to two lines" do
      expect(side2).to eq "Oregano Roasted Zucchini"
    end

    it "reads the names of sides which wrap to two lines" do
      expect(side3).to eq "A Side That Wraps Onto Two Lines"
    end

    it "reads the names of sides when both the side and entree wrap to two lines" do
      expect(side4).to eq "A Side That Wraps Onto Two Lines"
    end
  end

  describe "flags" do
    let(:slow_cooker)    { make_meal flags: "Slow Cooker" }
    let(:on_the_grill)   { make_meal flags: "On the Grill" }
    let(:super_fast)     { make_meal flags: "Super Fast" }
    let(:marinate_ahead) { make_meal flags: "Marinate Ahead" }

    it "reads the slow cooker flag correctly" do
      expect(slow_cooker.flags).to eq [:slow_cooker]
      expect(slow_cooker).to be_slow_cooker
    end

    it "reads the on the grill flag correctly" do
      expect(on_the_grill.flags).to eq [:on_the_grill]
      expect(on_the_grill).to be_on_the_grill
    end

    it "reads the super fast flag correctly" do
      expect(super_fast.flags).to eq [:super_fast]
      expect(super_fast).to be_super_fast
    end

    it "reads the marinate ahead flag correctly" do
      expect(marinate_ahead.flags).to eq [:marinate_ahead]
      expect(marinate_ahead).to be_marinate_ahead
    end

    it "reads a meal with no flags correctly" do
      expect(make_meal.flags).to eq []
      expect(make_meal).to_not be_slow_cooker
    end
  end

  describe "times" do
    it "reads prep times correctly" do
      expect(make_meal.times[:prep]).to eq "10m"
      expect(make_meal(prep_time: "15m").times[:prep]).to eq "15m"
    end

    it "reads cook times correctly" do
      expect(make_meal.times[:cook]).to eq "20m"
      expect(make_meal(cook_time: "4h").times[:cook]).to eq "4h"
    end

    it "reads total times correctly" do
      expect(make_meal.times[:total]).to eq "30m"
      expect(make_meal(total_time: "4h 10m").times[:total]).to eq "4h 10m"
    end
  end
end

