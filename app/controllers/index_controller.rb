# -*- encoding : utf-8 -*-
class IndexController < ApplicationController
  
  skip_filter :redirector
  
  def index
    @user = User.new
    session[:user] = nil
    gameId = session[:game];
    session[:game] = nil
    session[gameId] = nil
    session[:moneyToPlayers] = nil
    session[:moneyBackToPlayers] = nil
    session[:questions1] = nil
    session[:questions2] = nil
  end
  
  def proceed_next
    @user = User.new(params[:user])

    if @user.save
      session[:user] = @user
      
      redirect_to :controller => :game, :action => :details
    else
      render :action => :index
    end
  end

end
