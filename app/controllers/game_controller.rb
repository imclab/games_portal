class GameController < ApplicationController
  before_filter :present_login
  before_filter :must_consent

  def player
    authorize! :read, :game
  end

  def landing
    @game =  Game.find_by_path(params[:game])
  end

  def show
    @game =  Game.find_by_path(params[:game])
    if @game.nil?
      #flash[:error] = "Game not found for "+params[:game]+"!"
      redirect_to root_url
    end
  end

  def create
    @game = Game.new(params[:game])
    if @game.save
      redirect_to root_url
    else
      render :new
    end
  end

  def update
    @game =  Game.find(params[:id])
    if @game.update_attributes params[:game]
      redirect_to root_url
    else
      render :edit
    end
  end

  def edit
    @game =  Game.find(params[:id])
  end

  def new
    @game = Game.new
  end

  def index
    @game = Game.all
  end
end