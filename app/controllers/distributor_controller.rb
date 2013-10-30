class DistributorController < ApplicationController
  before_filter :present_login
  before_filter :must_consent

  def index
   if current_user.control_group?
      redirect_to "http://fairplay.control.dev.eriainteractive.com"
    else
      redirect_to game_url
    end
  end
end