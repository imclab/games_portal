class PortalController < ApplicationController
  #before_filter :present_login
  #before_filter :must_consent

  def index
    if current_user
     #redirect_to game_url

    end

    @games = Game.all
  end
end
