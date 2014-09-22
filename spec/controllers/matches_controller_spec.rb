require 'spec_helper'

describe MatchesController, type: :controller do

  describe '#create' do
    let(:league) { FactoryGirl.create(:league) }
    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }

    specify do
      post :create, { league_id: league.slug, team1: [ user.id.to_s, '' ], team2: [ user2.id.to_s, ''], set1: ['6', '3'], set2: ['7','5'], set3: ['',''] }
      expect(response).to redirect_to league_path(league)
    end

    it 'redirects to new_league_match if mobile' do
      allow(subject).to receive(:is_mobile_device?).and_return(true)
      post :create, { league_id: league.slug, team1: [ user.id.to_s, '' ], team2: [ user2.id.to_s, ''], set1: ['6', '3'], set2: ['7','5'], set3: ['',''] }
      expect(response).to redirect_to new_league_match_path(league, team1: [ user.id.to_s, '' ], team2: [ user2.id.to_s, ''], created: true)
    end
  end

  describe '#update' do
    let(:league) { FactoryGirl.create(:league) }
    let(:user) { FactoryGirl.create(:user, league: league, quota: 1200) }
    let(:user2) { FactoryGirl.create(:user, league: league, quota: 1200) }
    let(:team) { FactoryGirl.create(:team, player1_id: user.id) }
    let(:team2) { FactoryGirl.create(:team, player1_id: user2.id) }
    let!(:match) { FactoryGirl.create(:match, score: '6:1', winner_team_id: team.id, loser_team_id: team2.id, difference: 10, league_id: league.id) }
    it 'changes nothing if only result changes' do
      allow(subject).to receive(:current_league).and_return(league)
      patch :update, { id: match.id, league_id: league.id,  winner_score: '6', loser_score: '2', crawling: false }
      expect(user.reload.quota).to eql(1208)
      expect(user.reload.winning_streak).to eql(1)
      expect(user2.reload.quota).to eql(1192)
    end
    it 'changes points if crawling changes' do
      allow(subject).to receive(:current_league).and_return(league)
      patch :update, { id: match.id, league_id: league.id,  winner_score: '6', loser_score: '2', crawling: true }
      expect(user.reload.quota).to eql(1213)
      expect(user.reload.winning_streak).to eql(1)
      expect(user2.reload.quota).to eql(1187)
    end
    it 'swap teams if winner scored less scores then loser' do
      allow(subject).to receive(:current_league).and_return(league)
      patch :update, { id: match.id, league_id: league.id,  winner_score: '3', loser_score: '6', crawling: false }
      expect(user.reload.quota).to eql(1192)
      expect(user.reload.winning_streak).to eql(0)
      expect(user2.reload.quota).to eql(1208)
      expect(user2.reload.winning_streak).to eql(1)
      expect(match.reload.score).to eql('6:3')
    end
  end

end
