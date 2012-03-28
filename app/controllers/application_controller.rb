class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :redirector

  def redirector
    logger.info { "New tester comes or what?" }
    if (session[:user])

      @user = session[:user]
      logger.info { "Ah just old one, will find him his place" }
    else
      logger.info { "Really it`s new user! WHOHY!" }
      redirect_to :controller => :index, :action => :index
    end
  end
end
