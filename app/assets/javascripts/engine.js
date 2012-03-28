jQuery(document).ready(function() {

var Visitor = Class.$extend({
	__init__ : function(name) {
		this.name = name;
	},
	
	useOnce : function() {
		return false;
	},
	
	visit : function(game,game_engine,game_object) {
		debug("Strange");
	}
	
});

var QuestionsRedirector = Visitor.$extend({
	__init__ : function() {
		this.$super("Questions redirector");
	},
	
	visit : function(game,game_engine,game_object) {
		if (game_object.state.name == 'questions1') {
			window.location.href = '/questions/firstRound'
			return;
		}
		
		if (game_object.state.name == 'questions2') {
			window.location.href = '/questions/moneyChange'
			return;
		}
	}
});

var UpdateAIPlayersDescisions = Visitor.$extend({
	__init__ : function() {
		this.$super("Desisions updater");
	},
	
	visit : function(game,game_engine,game_object) {
		if (game_object.state.name != 'bid') {
			return
		}
		
		debug("Update players desisions")
		for (var p in game_object.players) {
			var player = game_object.players[p];
			
			if ((player.truth && player.logic[game_object.state.round_count]==1) || (!player.truth && player.logic[game_object.state.round_count]==0)) {
 				jQuery("."+player.name+" .player_decision").text("Буду делать ставку");
			} else {
				jQuery("."+player.name+" .player_decision").text("Не буду делать ставку");
			}
		}
	}
});

var UpdateBankAndPlayersMoney = Visitor.$extend({
	__init__ : function() {
		this.$super("Bank updater");
	},
	
	visit : function(game,game_engine,game_object) {
		
		jQuery("#bank_bid").text(game_object.state.bid)
		
		if (game_object.state.name != 'bid_conversation') {
			return
		}
		
		debug("Update table and players moneys")
		for (var p in game_object.players) {
			var player = game_object.players[p];

			jQuery("."+player.name+" .player_money").text(player.money)
		}
		
		jQuery(".user .user_money").text(game_object.current_player.money)
	}
});

var RoundCounter = Visitor.$extend({
	__init__ : function() {
		this.$super("Round counter");
	},
	
	visit : function(game,game_engine,game_object) {
		debug("Update round count to:"+game_object.state.round_count)
		jQuery("#round_counter span").text(game_object.state.round_count)
	}
});

var EnableDesControls = Visitor.$extend({
	__init__ : function() {
		this.$super("Enabling user des controls on next update");
		this.listeners_inited = false;
	},
	
	visit : function(game,game_engine,game_object) {
		jQuery(".player_decision").text("");
		debug("Enabling des controls:"+game_object.state.desision_controls_enabled)
		if (game_object.state.desision_controls_enabled) {
			jQuery("#des_controls").show();
		} else {
			jQuery("#des_controls").hide();
		}
		
		if (!this.listeners_inited) {
		
			jQuery("#des_make_bid").live("click", function() {
				game_engine.action("make_bid")
			});
		
			jQuery("#des_not_make_bid").live("click", function() {
				game_engine.action("not_make_bid")
			});
			this.listeners_inited = true
		}
	}
});

var EnableBidControls = Visitor.$extend({
	__init__ : function() {
		this.$super("Enabling user bid controls on next update");
		this.listeners_inited = false;
	},
	
	visit : function(game,game_engine,game_object) {
		debug("Enabling bid controls:"+game_object.state.bid_controls_enabled)
		if (game_object.state.bid_controls_enabled) {
			jQuery("#bid_controls").show();
		} else {
			jQuery("#bid_controls").hide();
		}
		
		if (!this.listeners_inited) {
		
			jQuery("#make_bid").live("click", function() {
				game_engine.action("bid")
			});
		
			jQuery("#not_make_bid").live("click", function() {
				game_engine.action("not_bid")
			});
			this.listeners_inited = true
		}
	}
});

var EnableTimer = Visitor.$extend({
	__init__ : function() {
		this.$super("Enabling timer control remove on next update");
	},
	
	visit : function(game,game_engine,game_object) {
		if (!game_object.state.timer_enabled) {
			return
		}
		debug("Enable timer")
	}
})

var EnableWaiting = Visitor.$extend({
	__init__ : function() {
		this.$super("Enabling waiting on next update");
	},
	
	visit : function(game,game_engine,game_object) {
		if (game_object.state.waiting_enabled) {
			debug("Enable waiting")
			game_engine.showWaitingPlayers()
			this.timer = setTimeout(function(){game_engine.resolveGame()}, 3000)
		} else {
			debug("Disable waiting")
			game_engine.hideWaitingPlayers()
			clearTimeout(this.timer)
		}

	}
})

var GameEngine = Class.$extend({
	__init__ : function(container_element) {
		this.container_element = container_element;
		this.visitors = {}
	},
	
	startGame : function() {	
		//1.Show loading and base screen
		var self = this;
		setTimeout(function() { self.showLoading() }, 100);
		setTimeout(function() { self.showGame() }, Math.random() * 1000 + 500);
	},
	
	showLoading : function() {
		if (this.loadingCount) {
			switch(this.loadingCount) {
				case 1: jQuery(".start_waiting .loading_message").text("Loading engine...");
						break;
				case 2: jQuery(".start_waiting .loading_message").text("Loading assets...");
						break;
				case 3: jQuery(".start_waiting .loading_message").text("Waiting for players...");
						break;
			}
		} else {
			jQuery(".start_waiting .loading_message").text("Loading server game...");
			this.loadingCount = 0;
		}
		
		this.loadingCount++;
		var self = this;
		setTimeout(function() { self.showLoading() }, 100);
	},
	
	showWaitingPlayers : function() {
		jQuery(".ai span.loading").show()
	},
	
	hideWaitingPlayers : function() {
		jQuery(".ai span.loading").hide()
	},
	
	hideLoading : function() {
		jQuery(".start_waiting").hide();
	},
	
	showGame : function() {
		debug("Starting game");
		this.hideLoading();
		jQuery("#game_board").show();
		
		this.resolveGame();
	},
	
 	addVisitor : function(visitor) {
		this.visitors[visitor.name] = visitor;
	},
	
	resolveGame : function() {
		var self = this;
		jQuery.getJSON("/game/status/"+window.game.getId(), function(json) {
			for (var visitor in self.visitors) {
				//we need to iterate throught resolvers and update what needed.	
				debug("Calling "+self.visitors[visitor].name + " visitor");
				self.visitors[visitor].visit(window.game, self, json);
				
				if (self.visitors[visitor].useOnce()) {
					delete self.visitors[visitor];
				}
			}
			
		});
	},
	
	action : function(action_name) {
		var self = this;
		jQuery.getJSON("/game/"+window.game.getId()+"/"+action_name, function(json) {
			for (var visitor in self.visitors) {
				//we need to iterate throught resolvers and update what needed.	
				debug("Calling "+self.visitors[visitor].name + " visitor");
				self.visitors[visitor].visit(window.game, self, json);
				
				if (self.visitors[visitor].useOnce()) {
					delete self.visitors[visitor];
				}
			}
			
		});
	}
});

var Game = Class.$extend({
	__init__ : function() {
		this.game_id = jQuery(".game").attr("id");
		this.game_engine = GameEngine("#game_board");
		this.game_engine.addVisitor(EnableBidControls());
		this.game_engine.addVisitor(EnableTimer());
		this.game_engine.addVisitor(EnableWaiting());
		this.game_engine.addVisitor(EnableDesControls());
		this.game_engine.addVisitor(RoundCounter());
		this.game_engine.addVisitor(UpdateBankAndPlayersMoney());
		this.game_engine.addVisitor(UpdateAIPlayersDescisions());
		this.game_engine.addVisitor(QuestionsRedirector());
	},
	
	start : function() {
		this.game_engine.startGame();
	},
	
	getEngine : function() {
		return this.game_engine;
	},
	
	getId : function() {
		return this.game_id;
	}
})

window.game = Game();
window.game.start();

});