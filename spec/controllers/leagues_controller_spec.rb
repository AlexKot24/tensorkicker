# encoding: utf-8

require 'spec_helper'

describe LeaguesController, type: :controller do

  describe '#create' do

    context 'successful' do
      before do
        expect(AdminMailer).to receive_message_chain(:new_league, :deliver)
        expect(controller).to receive(:set_current_league)
      end

      specify do
        post :create, league: { name: 'Hammerwerfers Bockenbruch!', slug: 'Hammerwerfers Bockenbruch!', contact_email: 'contact@hammerwerfer.de' }
        expect(response).to redirect_to new_league_user_path(League.last)
        expect(flash[:notice]).to eql I18n.t('leagues.create.success')
      end
    end

    context 'unsuccessful' do
      specify do
        post :create, league: { name: 'Hammerwerfers Bocklemünd', slug: nil }
        expect(response).to be_success
        expect(response).to render_template 'leagues/new'
        expect(flash[:alert]).to eql I18n.t('leagues.create.failure')
      end
    end

  end

  describe 'index' do
    let(:league1) { FactoryGirl.create(:league, slug: 'league1') }
    let(:league2) { FactoryGirl.create(:league, slug: 'league2') }
    before do
      session[:league] = 'the-league'
      get :index
    end
    it{ expect(session[:league]).to be_nil }
    it{ expect(assigns[:leagues]).to match [league1, league2] }
  end

  describe 'new' do
    before { get :new }
    it{ expect(response).to be_success }
    it{ expect(response).to render_template 'leagues/new' }
  end

  describe 'show' do
    let!(:league) { FactoryGirl.create(:league, slug: 'the-league') }
    let(:match1) { FactoryGirl.create(:match, league: league) }
    let(:match2) { FactoryGirl.create(:match, league: league) }
    before do
      expect(controller).to receive(:set_current_league)
      get :show, id: 'the-league'
    end
    it{ expect(response).to be_success }
    it{ expect(response).to render_template 'leagues/show' }
    it{ expect(assigns[:league]).to eql league }
    it{ expect(assigns[:matches]).to match [match1, match2] }
  end

  describe 'badges' do
    let!(:league) { FactoryGirl.create(:league, slug: 'the-league') }
    before do
      expect(controller).to receive(:set_current_league)
      get :badges, id: 'the-league'
    end
    it{ expect(response).to be_success }
    it{ expect(response).to render_template 'leagues/badges' }
    it{ expect(assigns[:league]).to eql league }
  end

end
