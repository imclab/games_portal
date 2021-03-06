class SessionController < ApplicationController
  skip_authorization_check
  before_filter :login_required, except: [:from_oauth, :destroy, :create_guest, :testpost]

  def from_oauth
    omniauth = env['omniauth.auth']

    unless omniauth.nil?
      session[:token] = omniauth['credentials']['token']
      session[:player_name] = omniauth['extra']['raw_info']['info']['player_name']
      session[:auth] = omniauth['extra']['raw_info']['info']['auth']
      session[:ada_id] = omniauth['uid']

      User.create_from_session(session)
    end

    redirect_to return_path
  end

  def login
    redirect_to root_url
  end

  def destroy
    reset_session
    flash[:notice] = %Q[You have been logged out of the Fairplay but are still logged into your <a href="http://ada.production.eriainteractive.com">GLS account.</a>].html_safe

    redirect_to root_url
  end

  def failure
    render :text => params[:message]
  end

  def create_guest
    body = {
      client_id: ENV['ADAName'],
      client_secret: ENV['ADASecret']
    }

    auth_response = HTTParty.post(ENV['ADAURL']+"/auth/guest.json", body: body)

    token = auth_response["access_token"]
    body = {oauth_token: token}

    auth_response = HTTParty.get(ENV['ADAURL']+"/auth/ada/user.json", body: body)

    if auth_response.code == 200
      session[:token] = token
      session[:guest] = true
      session[:ada_id] = auth_response['uid']
      session[:player_name] = auth_response['info']['player_name']
      session[:auth] = auth_response['info']['auth']

      User.create_from_session(session)
    end

    redirect_to return_path
  end
end