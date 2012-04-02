# -*- encoding : utf-8 -*-
class QuestionsController < ApplicationController
  def firstRound
  end

  def lastRound
  end

  def lastSituations
  end

  def moneyChange
    @gameId = session[:game]
    @game = session[@gameId]
  end
  
  def moneyBack
    @gameId = session[:game]
    @game = session[@gameId]
  end

  def firstSubmit
    session[:questions1] = [params[:question1],params[:question2],params[:question3],params[:question4]]
    @gameId = session[:game]
    @game = session[@gameId]
    @game.state.name = 'bid_conversation'
    session[@gameId] = @game
    redirect_to :controller => :game, :action => :game
  end
  
  def secondSubmit
    session[:questions2] = [params[:question1],params[:question2],params[:question3],params[:question4],params[:question5],params[:question6]]
    redirect_to :action => :lastSituations
  end
  
  def moneySubmit
    session[:moneyToPlayers] = [params[:player1],params[:player2],params[:player3]]
    @gameId = session[:game]
    @game = session[@gameId]
    sum = 0
    player_sum = 0
    @game.players.each_with_index do |player,index|
      player_sum = player_sum + player.money
      player.money=player.money.to_i+session[:moneyToPlayers][index].to_i*3
      sum=sum+session[:moneyToPlayers][index].to_i      
    end        
    @game.current_player.money=@game.current_player.money-sum+player_sum        
    
    redirect_to :action => :moneyBack
  end
  
  def lastSituationsSubmit
    questions = {}
    questions[:player1] = []
    questions[:player2] = []
    questions[:player3] = []        
    (1..10).each do |i|
      questions[:player1] << params["question"+i.to_s+"_player1"]
      questions[:player2] << params["question"+i.to_s+"_player2"]      
      questions[:player3] << params["question"+i.to_s+"_player3"]      
    end
    
    session[:questions3] = questions
    redirect_to :action => :win
  end
  
  def moneyBackSubmit
    session[:moneyBackToPlayers] = [params[:player1],params[:player2],params[:player3]]
    @gameId = session[:game]
    @game = session[@gameId]
    sum = 0
    @game.players.each_with_index do |player,index|
      player.money=player.money.to_i+session[:moneyBackToPlayers][index].to_i
      sum=sum+session[:moneyBackToPlayers][index].to_i
    end
    @game.current_player.money=@game.current_player.money-sum
    redirect_to :action => :lastRound
  end
  
  def win
    @user = session[:user]
    #Save results to database here
    @gameId = session[:game]
    @game = session[@gameId]
    @user.result = {:game => @game, :moneyToPlayers => session[:moneyToPlayers], :moneyBackToPlayers => session[:moneyBackToPlayers], :questions1 => session[:questions1], :questions2 => session[:questions2], :questions3 => session[:questions3]}.to_json
    @user.save
    @otherMax = @game.players.max {|a,b| a.money <=> b.money }
    if (@game.current_player.money<@otherMax.money) 
      @winner = @otherMax.name
    else
      @winner = "currentPlayer"
    end
  end
end
