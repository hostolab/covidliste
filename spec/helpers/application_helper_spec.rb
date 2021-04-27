require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "distance_delta" do
    context "points under one kilometer away" do
      it "calculates the delta distance between two points" do
        # p1 (18 Boulevard Haussmann 75009 Paris France)
        # p2 (43 Boulevard Haussmann 75009 Paris France)
        p1 = { lat: 48.872624, lon: 2.336625 }
        p2 = { lat: 48.873342, lon: 2.329358 }
        expect(helper.distance_delta(p1, p2)).to eq({
          delta: 540,
          delta_in_words: "540 m",
        })
      end
    end
    context "points more than one kilometer away" do
      it "calculates the delta distance between two points" do
        # p1 (18 Boulevard Haussmann 75009 Paris France)
        # p2 (24 Boulevard Malesherbes 75009 Paris France)
        p1 = { lat: 48.872624, lon: 2.336625 }
        p2 = { lat: 48.872824, lon: 2.321619 }
        expect(helper.distance_delta(p1, p2)).to eq({
          delta: 1.1,
          delta_in_words: "1.1 km",
        })
      end
    end
    context "points more than one kilometer away" do
      it "calculates the delta distance between two points" do
        # p1 (18 Boulevard Haussmann 75009 Paris France)
        # p2 (60 Avenue de la Grande Armée 75017 Paris France)
        p1 = { lat: 48.872624, lon: 2.336625 }
        p2 = { lat: 48.8768581, lon: 2.284386 }
        expect(helper.distance_delta(p1, p2)).to eq({
          delta: 3.8,
          delta_in_words: "3.8 km",
        })
      end
    end
  end
end
