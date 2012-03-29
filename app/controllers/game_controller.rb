class GameController < ApplicationController
  
  class Player
    attr_accessor :name,:money,:desisions, :bids
    
    def initialize(name)
      @name = name
      @money = 50
      @desisions = []
      @bids = []
    end
  end
  
  class AIPlayer < Player
    attr_accessor :logic,:truth
    
    def initialize(name, logic,truth)
      super(name)
      @truth = truth
      @logic = logic
    end
  end
  
  class GameState
    attr_accessor :timer_enabled,
                  :name,
                  :next_state,
                  :questions_done,
                  :desision_controls_enabled,
                  :bid_controls_enabled,
                  :waiting_enabled,
                  :waiting_time,
                  :waiting_duration,
                  :round_count,
                  :bid
    
    def initialize
      @name = "bid_conversation"
      @round_count = 1
      @bid = 50
      @waiting = false
      @questions_done = false
      @desision_controls_enabled = false
      @bid_controls_enabled = false
      @timer_enabled = false
    end
  end
  
  class Game
    attr_accessor :id, :start_time, :players, :current_player, :update_time, :state
    
    def initialize(user)
      @id = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
      @start_time = Date.new
      @players = [AIPlayer.new('player1', [0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1],true),
                  AIPlayer.new('player2', [0,1,0,0,1,0,1,1,0,1,0,0,1,1,0,1,0,1,0,1,1],true),
                  AIPlayer.new('player3', [0,1,1,1,0,0,0,1,0,0,1,0,0,0,1,1,1,0,1,0,1],false)]
      @current_player = Player.new(user.name)
      @state =  GameState.new
    end
  end
  
  def details
  end

  def game
     if (session[:game])
       @gameId = session[:game]
       @game = session[@gameId]
     else
       @game = Game.new(session[:user])
       session[@game.id] = @game
       session[:game] = @game.id
     end
  end
  
  def game_action
    @game = session[params[:id]];
    ga = params[:game_action]
    logger.debug("Processing action:"+ga)
    @game = process_game_action(ga,@game)
    @game.update_time = Date.new
    session[@game.id] = @game
    respond_to do |format|
      format.xml  { render :xml => @game }
      format.json { render :json => @game }
    end
  end
  
  def status
    
    @game = session[params[:id]];
    @game = process_game(@game)
    @game.update_time = Date.new
    session[@game.id] = @game
    respond_to do |format|
      format.xml  { render :xml => @game }
      format.json { render :json => @game }
    end
  end

private

  def process_game_action(ga,g)
    bid = 50*(2**(g.state.round_count/5))
    if (ga == 'make_bid' || ga == 'not_make_bid')
      #We are in the stage of ai thinking
      g.state.name = "waiting"
      g.state.next_state = "bid"
      g.current_player.desisions.push(ga)

    elsif (ga == 'bid' || ga == 'not_bid')
      g.state.bid = bid
      g.state.name = "waiting"
      g.state.next_state = "bid_conversation"
      #need to calculate money if exists
      g.current_player.bids.push(ga)
      num_bids = 0
      if (ga == 'bid')
        num_bids = 1
        g.current_player.money = g.current_player.money-bid
      end
      
      g.players.each do |player|
        logic = player.logic[g.state.round_count]
        if (logic==1)
          player.money = player.money-bid
        end
        num_bids=num_bids+logic
    
      end
      
      if (num_bids>2) 
        g.players.each do |player|
            player.money = player.money+bid*4
        end
        g.current_player.money = g.current_player.money+bid*4
      end
                  g.state.round_count = g.state.round_count+1
    end
    
    g = process_game(g)
    g
  end

  def process_game(g)

    if (g.state.round_count==10 && !g.state.questions_done)
      g.state.name = "questions1"
      g.state.questions_done = true
      return g        
    end
    
    if (g.state.round_count==20)
      g.state.name = "questions2"
      g.state.round_count = g.state.round_count+1
      return g        
    end

    if g.state.name == 'bid_conversation'                         
      
      g.state.desision_controls_enabled = true
      g.state.timer_enabled = true
    
    elsif g.state.name == 'waiting'
      logger.debug("Process waiting state")      
      g.state.desision_controls_enabled = false
      g.state.bid_controls_enabled = false
      g.state.timer_enabled = false
      g.state.waiting_enabled = true
      
      if (g.state.waiting_time != nil) 
        if (g.state.waiting_time+g.state.waiting_duration >= Date.new)
          logger.debug("Stop waiting proceed to next state"+g.state.next_state)
          g.state.name = g.state.next_state
          g.state.next_state = nil
          g.state.waiting_enabled = false
          g.state.waiting_time = nil
          g.state.waiting_duration = nil 
          
          process_game(g)     
        end
      else
        g.state.waiting_time = Date.new
        g.state.waiting_duration = (1..30).to_a[rand(30)]*1000

      end
    elsif (g.state.name == 'bid')
      
      #need to calculate descizions of other players
      logger.debug("Process bid state")
      g.state.bid_controls_enabled = true
      
    end
    
    g
  end

end
