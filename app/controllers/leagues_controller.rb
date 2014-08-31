class LeaguesController < ApplicationController

  before_filter :require_league, only: [:badges]

  def index
    clear_current_league
    @leagues = League.order(:name)
  end

  def new
    @league = League.new
  end

  def create
    @league = League.new(league_params)
    if @league.save
      set_current_league
      redirect_to league_path(@league), notice: 'Liga erfolgreich erzeugt!'
    else
      render :new, alert: 'Liga konnte nicht gespeichert werden'
    end
  end

  def show
    @league = League.find_by!(slug: params[:id])
    set_current_league
    @matches = @league.matches.limit(30)
    respond_to do |format|
      format.html # index.html.erb
      format.atom
      format.json {
        render json: @matches, include: {
          winner_team: { only: [:player1, :player2], include: {player1: {only: [:name, :image]}, player2: {only: [:name, :image]}} },
          looser_team: { only: [:player1, :player2], include: {player1: {only: [:name, :image]}, player2: {only: [:name, :image]}} }
        }
      }
    end
  end

  def badges
    @league = League.find_by!(slug: params[:id])
    @order = params[:order] || 'longest_winning_streak_games'
    @users = @league.users.order("#{@order} desc").select{|user| user.active? }

  end

  private

  def league_params
    params.require(:league).permit(:name, :slug)
  end
end
