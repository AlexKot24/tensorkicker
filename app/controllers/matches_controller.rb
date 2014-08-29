# encoding: utf-8

class MatchesController < ApplicationController
  before_filter :require_league
  has_mobile_fu
  has_mobile_fu_for :new, :create
  before_filter :force_mobile_format

  def index
    @matches = Match.limit(30)
    respond_to do |format|
      format.html # index.html.erb
      format.atom
      format.json { render json: @matches }
    end
  end

  def new
    @match = Match.new
  end

  def create
    create_matches_from_params(params)
    if is_mobile_device?
      redirect_to new_league_match_path(current_league)
    else
      redirect_to league_path(current_league), notice: "Spiele wurden eingetragen."
    end
  end

  def edit
    @match = Match.find(params[:id])
  end

  def update
    @match = Match.find(params[:id])
    if params[:winner_score].to_i < params[:looser_score].to_i
      @match.score = @match.score_for_set(params[:looser_score], params[:winner_score])
      @match.revert_points
      @match.swap_teams
      @match.calculate_user_quotes
    else
      @match.score = @match.score_for_set(params[:winner_score], params[:looser_score])
    end
    if @match.save
      redirect_to league_path(current_league), notice: "Satz gespeichert."
    else
      flash.now[:alert] = "Satz konnte nicht gespeichert werden."
      render :edit
    end
  end

  def destroy
    @match = Match.find(params[:id])
    @match.revert_points
    @match.destroy
    redirect_to league_matches_path(current_league), notice: "Dieser Satz wurde gelöscht."
  end

  def shuffle
    @match = Match.new
    if params[:user_ids].select{|id| id.present?}.size == 4
      @teams = Team.shuffle(params[:user_ids])
      flash.now[:notice] = "Es spielen #{@teams.first.name} gegen #{@teams.last.name}"
      render :new
    else
      redirect_to shuffle_select_league_matches_path(current_league), alert: "Bitte wähle 4 Spieler aus!"
    end
  end

  def show
    redirect_to league_path(current_league)
  end

  def shuffle_select

  end

  private

  def create_matches_from_params(params)
    league = League.find_by!(slug: params[:league_id])
    3.times do |i| #Three possible sets
      set = params["set#{i+1}"]
      if set.first.present? && set.last.present? # If the set has been played
        result_params = { crawling: params["crawling#{i+1}"].present? }
        params["team1"].each_with_index do |user_id, index|
          result_params[user_id] = set.first.to_i
          result_params[params["team2"][index]] = set.last.to_i
        end
        result_params[:league_id] = league.id.to_s
        HistoryEntry.track(Match.create_from_set(result_params))
      end
    end
    league.update_badges
  end

  def force_mobile_html
    session[:mobile_view] = true
  end
end
