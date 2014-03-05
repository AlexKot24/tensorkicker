require 'spec_helper'

describe User do
  describe "scopes" do
    describe "ranked" do
      it "sorts by quote desc" do
        good_user = FactoryGirl.create(:user, quote: 1400)
        bad_user = FactoryGirl.create(:user, quote: 1000)
        medium_user = FactoryGirl.create(:user, quote: 1200)
        expect(User.ranked).to eq([good_user, medium_user, bad_user])
      end
    end
  end

  describe ".number_of_games" do
    it "adds up wins and looses" do
      user = FactoryGirl.build(:user, number_of_wins: 3, number_of_looses: 7)
      expect(user.number_of_games).to eq(10)
    end
  end

  describe ".win_percentage" do
    it "takes the QuoteCalculator" do
      user = FactoryGirl.build(:user, number_of_wins: 3, number_of_looses: 7)
      QuoteCalculator.stub(:win_loose_quote).and_return(20)
      expect(user.win_percentage).to eq(20)
    end
  end

  describe ".set_elo_quote" do
    context "win" do
      before do
        QuoteCalculator.stub(:elo_quote).and_return(5)
      end
      it "calculates without crawling" do
        match = double(win_for?: true, winner_team: double("w_team", elo_quote: 1200), looser_team: double("l_team", elo_quote: 1200), crawling: false, difference: 5)
          subject.set_elo_quote(match)
        expect(subject.quote).to eql(1205)
        expect(subject.winning_streak).to eql(1)
      end
      it "calculates with crawling (+5)" do
        match = double(win_for?: true, winner_team: double("w_team", elo_quote: 1200), looser_team: double("l_team", elo_quote: 1200), crawling: true, difference: 5)
        subject.set_elo_quote(match)
        expect(subject.quote).to eql(1210)
        expect(subject.number_of_crawls).to eql(1)
      end
      it "updates the difference on a match" do
        match = FactoryGirl.create(:match, winner_team: FactoryGirl.create(:team), looser_team: FactoryGirl.create(:team))
        Team.any_instance.stub(:elo_quote).and_return(1200)
        subject.set_elo_quote(match)
        expect(match.difference).to eql(5)
      end
    end
    context "loose" do
      before do
        QuoteCalculator.stub(:elo_quote).and_return(-5)
      end
      it "calculates without crawling" do
        match = double(win_for?: false, winner_team: double("w_team", elo_quote: 1200), looser_team: double("l_team", elo_quote: 1200), crawling: false, difference: 5)
        subject.set_elo_quote(match)
        expect(subject.quote).to eql(1195)
      end
    end
  end

  describe ".active?" do
    let(:user) { FactoryGirl.create(:user, number_of_wins: 3, number_of_looses: 7) }
    context "is active" do
      specify do
        match = FactoryGirl.build(:match, date: 1.week.ago)
        user.stub(:matches).and_return([match])
        expect(user.active?).to be_true
      end
    end

    context 'not active' do
      it "has no matches" do
        expect(user.active?).to be_false
      end

      it 'has old matches' do
        match = FactoryGirl.build(:match, date: 3.week.ago)
        user.stub(:matches).and_return([match])
        expect(user.active?).to be_false
      end
    end
  end

  describe ".short_name" do
    let(:user) {FactoryGirl.build(:user, name: nil)}
    context "empty name" do
      specify{ expect(user.short_name).to eq('') }
    end
    context "name without whitespace" do
      specify do
        user.name = 'something'
        expect(user.short_name).to eq('so')
      end
    end
    context "name with at least one whitespace" do
      specify do
        user.name = 'Clark Kent'
        expect(user.short_name).to eq('CK')
      end
    end
  end
end
