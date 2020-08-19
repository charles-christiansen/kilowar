pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--init functions

--TODO:
----4. coup fourre!
----5. w-l record save/clear
----6. card playing improvements
------ slow down cpu play
------ discard pile
----7. better sprites
----8. card legend screen

function _init()
	deck = shuffledeck()
	playerbox = {x=0,y=90,xe=128,ye=100,col=3}
	debugbox = {x=0,y=102,xe=128,ye=112,col=5}
	cpubox = {x=0,y=114,xe=128,ye=124,col=4}
	playerptrbox = {x=10,y=30,xe=80,ye=40,col=0}
	player = {name="player",col=3,hand={},score=0,total=0,cfs=0,num200s=0,limit=false,upcard=nil,safeties={}}
	cpu = {name="cpu",col=4,hand={},score=0,total=0,cfs=0,num200s=0,limit=false,upcard=nil,safeties={},skill=1}
	dealt = false
	stdgoal = 700
	extgoal = 1000
	curgoal = 700
	totalgoal = 5000
	currentplayer = {name="nobody"}
	turninprogress = false
	mode = "start"
	playercardptr = 1
	
	racewinner = ""
	matchwinner = ""

	-- debugging
	debug = ""
	cpudebug = ""
	palt(14,true)
	palt(0,false)
end

function shuffledeck()
	local _d = {}
 -- card types:
 	-- n = number
 	-- g = go
 	-- s = stop
 	-- h = hazard
 	-- r = remedy
 	-- l = speed limit
 	-- v = remove limit
 	-- f = safety
	for i=1,14 do
		-- add number cards
		if i <= 10 then
			add(_d,{type="n",value=25,belowlimit=true,name="25",remedy="",safety="",sprite=1})
			add(_d,{type="n",value=50,belowlimit=true,name="50",remedy="",safety="",sprite=2})
			add(_d,{type="n",value=75,belowlimit=false,name="75",remedy="",safety="",sprite=3})
		end
		if i <= 12 then
			add(_d,{type="n",value=100,belowlimit=false,name="100",remedy="",safety="",sprite=4})
		end

		if i <=4 then
			add(_d,{type="n",value=200,belowlimit=false,name="200",remedy="",safety="",sprite=5})
		end
		-- add go cards
		add(_d,{type="g",value=0,belowlimit=false,name="go",remedy="",safety="",sprite=6})
		-- add stop cards
		if i <=5 then
			add(_d,{type="s",value=0,belowlimit=false,name="stop",remedy="",safety="emergency",sprite=7})
		end
		-- add hazards + speed limits
		if i <= 3 then
			add(_d,{type="h",value=0,belowlimit=false,name="flat",remedy="spare",safety="ppt",sprite=8})
			add(_d,{type="h",value=0,belowlimit=false,name="crash",remedy="repair",safety="ace",sprite=9})
			add(_d,{type="h",value=0,belowlimit=false,name="empty",remedy="gascan",safety="tanker",sprite=10})
		end
		if i <= 4 then
			add(_d,{type="l",value=0,belowlimit=false,name="limit 50",remedy="nolimit",safety="emergency",sprite=12})
		end
		-- add remedies + remove limits
		if i <= 6 then
			add(_d,{type="v",value=0,belowlimit=false,name="nolimit",remedy="",safety="emergency",sprite=11})
			add(_d,{type="r",value=0,belowlimit=false,name="gascan",remedy="",safety="",sprite=17})
			add(_d,{type="r",value=0,belowlimit=false,name="repair",remedy="",safety="",sprite=18})
			add(_d,{type="r",value=0,belowlimit=false,name="spare",remedy="",safety="",sprite=19})
		end
		-- add safeties
		if i == 1 then
			add(_d,{type="f",value=0,belowlimit=false,name="ppt",remedy="",safety="",sprite=13})
			add(_d,{type="f",value=0,belowlimit=false,name="tanker",remedy="",safety="",sprite=14})
			add(_d,{type="f",value=0,belowlimit=false,name="ace",remedy="",safety="",sprite=15})
			add(_d,{type="f",value=0,belowlimit=false,name="emergency",remedy="",safety="",sprite=16})
		end
	end
	
	-- shuffle deck
	_shuffd = {}
	for i=#_d,1,-1 do
		local pos = flr(rnd(#_d))+1
		add(_shuffd,_d[pos])
		del(_d,_d[pos])
	end
	return _shuffd
end
-->8
--update functions
function _update60()
	if mode == "start" then
		update_start()
	else
		update_game()
	end
end

function update_start()
	if btnp(5) then
		mode = "game"
	end
end

function update_game()
	-- check for race win condition
	-- TODO: figure out how not to call newrace() twice
	if #racewinner == 0 then
		racewinner = isracewon()
	end

	-- check for match win condition
	matchwinner = ismatchwon()
	if #matchwinner > 0 then
		debug = "*** "..matchwinner.." wins the match ***"
		cpudebug = "press ❎ to start a new match!"
		if btnp(5) then
			newmatch()
		end
	elseif #racewinner > 0 then
		if racewinner == "draw" then
			debug = "nobody finished the race."
		else
			debug = racewinner.." wins!"
		end
		cpudebug = "press ❎ to start the next race!"
		if btnp(5) then
			newrace()
		end
	else
		-- deal the players a hand
		if not dealt then
			for i=1,6 do
				dealto(player)
				dealto(cpu)
			end
			dealt = true
		end
	
		if not turninprogress then
			turninprogress = true
			if currentplayer.name==player.name then
				currentplayer = cpu
			else
				currentplayer = player
			end
			draw_up(currentplayer)
		end
		if currentplayer.name==player.name then
			if btnp(1) then
				playercardptr += 1
				if playercardptr > #(player.hand) then
					playercardptr = 1
				end
				debug=""
				sfx(0)
			elseif btnp(0) then
				playercardptr -= 1
				if playercardptr == 0 then
					playercardptr = #(player.hand)
				end
				debug=""
				sfx(0)
			elseif btnp(5) then
				if checkvalidplay(player,cpu,player.hand[playercardptr]) then
					debug=""
					playcard(player,cpu,player.hand[playercardptr])
					if playercardptr > #(player.hand) then
						playercardptr-=1
					end
					turninprogress = false
				else
					debug = "invalid play: " .. player.hand[playercardptr].name
				end
			elseif btnp(4) then
				if player.hand[playercardptr].type == "f" then
					debug = "don't discard that!"
				else
					discard(player,player.hand[playercardptr])
					if playercardptr > #(player.hand) then
						playercardptr-=1
					end
					turninprogress = false
				end
			end
		else
			-- cpu skill level logic TODO:
			---- 1 = normal (plays first playable card)
			---- 0 = easy (plays to go/recover when possible)
			---- 2 = hard (plays to stop player when possible)
			for i=1,#(cpu.hand) do
				if checkvalidplay(cpu,player,cpu.hand[i]) then
					debug=""
					cpudebug="cpu plays "..cpu.hand[i].name
					playcard(cpu,player,cpu.hand[i])
					turninprogress = false
					return
				end
			end
		
			-- cpu is unable to play, needs to discard
			debug=""
			cpudebug="cpu discards "..cpu.hand[1].name
			discard(cpu,cpu.hand[1])
			turninprogress = false
		end
	end
end
-->8
--draw functions
function _draw()
	if mode == "start" then
		draw_start()
	else
		draw_game()
	end
end

function draw_start()
	cls()
	spr(64,36,10,7,3)
	print("by chuck",40,50,3)
	print("press ❎ to start",32,80,4)
end

function draw_game()
	cls()
	print("player: "..player.score.." ("..player.total.." total)",5,5,player.col)
	print("cpu:    "..cpu.score.." ("..cpu.total.." total)",5,45,cpu.col)
	for i=1,#(player.hand) do
		spr(player.hand[i].sprite,i*10+4,20)
	end
	if player.limit then
		spr(21,94,20)
	end
	for i=1,#(cpu.hand) do
		spr(20,i*10+4,60)
	end
	if cpu.limit then
		spr(21,94,60)
	end
	rectfill(playerbox.x,playerbox.y,playerbox.xe,playerbox.ye,playerbox.col)
	rectfill(playerptrbox.x,playerptrbox.y,playerptrbox.xe,playerptrbox.ye,playerptrbox.col)
	rectfill(cpubox.x,cpubox.y,cpubox.xe,cpubox.ye,cpubox.col)
	rectfill(debugbox.x,debugbox.y,debugbox.xe,debugbox.ye,debugbox.col)
	if currentplayer.name == player.name then
		print("*",14+(10*(playercardptr-1)),30,player.col)
	else
		print("*",14+(10*(playercardptr-1)),30,0)
	end
	if cpudebug != "" then
		print(cpudebug,5,debugbox.y+2,10)
	end
	spr(20,100,78)
	print("="..#deck,109,80,10)
	if debug != "" then
		print(debug,5,playerbox.y+2,10)
	else
		if player.upcard ~= nil then
			spr(player.upcard.sprite,playerbox.x+5,playerbox.y+2)
		end
		for i=1,#(player.safeties) do
			spr(player.safeties[i].sprite,playerbox.x+88+(10*(i-1)),playerbox.y+2)
		end
	end
	if cpu.upcard ~= nil then
		spr(cpu.upcard.sprite,cpubox.x+5,cpubox.y+2)
	end
	for i=1,#(cpu.safeties) do
		spr(cpu.safeties[i].sprite,cpubox.x+88+(10*(i-1)),cpubox.y+2)
	end
end
-->8
-- utility functions
function newmatch()
	player.total=0
	cpu.total=0
	newrace()
end

function newrace()
	dealt=false
	player.hand={}
	cpu.hand={}
	player.safeties={}
	cpu.safeties={}
	player.score=0
	cpu.score=0
	player.num200s=0
	cpu.num200s=0
	player.cfs=0
	cpu.cfs=0
	player.limit=false
	cpu.limit=false
	player.upcard=nil
	cpu.upcard=nil
	playercardptr=1
	currentplayer = {name="nobody"}
	turninprogress = false
	deck=shuffledeck()
	debug=""
	cpudebug = ""
	racewinner = ""
end

function draw_up(_curplayer,_cf)
	add(_curplayer.hand,deck[1])
	del(deck,deck[1])	
	if _cf then
		-- after coup foure, we draw two
		add(_curplayer.hand,deck[1])
		del(deck,deck[1])	
	end
--	return _curplayer
end

function discard(_player,_card)
	del(_player.hand,_card)
end

function dealto(_player)
	card = deck[1]
	add(_player.hand,card)
	del(deck,deck[1])
end

function hassafety(_player,_safety)
	if #(_player.safeties) == 0 then
		return false
	else
		for i=1,#(_player.safeties) do
			if _player.safeties[i].name == _safety then
				return true
			end
		end
	end
	return false
end

function checkvalidplay(_player,_opponent,_card)
	-- determine if play is valid
	-- based on card type
	if _card.type == "n" then
 		-- n = number
 		if _player.num200s >= 2 and _card.value == 200 then
 			-- can play max of two 200s
 			return false
 		end
 		if _card.value + _player.score > curgoal then
 			-- you have to hit the race goal exactly
 			return false
 		end
 		if hassafety(_player,"emergency") and (_player.upcard == nil or _player.upcard.type != "h") then
 			return true
 		end
 		if _player.upcard ~= nil then
 			if _player.upcard.type == "g" or _player.upcard.type == "n" then
 				if not _player.limit or (_player.limit and _card.value <= 50) then
 					return true
 				end
 			elseif hassafety(_player,"emergency") and (_player.upcard.type == "r" or _player.upcard.type == "f") then
 				return true
 			end
 		else 
 			return false
 		end
	elseif _card.type == "g" then
 		-- g = go
 		if not hassafety(_player, "emergency") and (_player.upcard == nil or _player.upcard.type == "s" or _player.upcard.type == "r" or _player.upcard.type == "f") then
 			return true
 		else
 			return false
 		end
	elseif _card.type == "s" then
	 	-- s = stop
	 	if hassafety(_opponent,_card.safety) then
	 		return false
	 	elseif _opponent.upcard ~= nil and (_opponent.upcard.type=="g" or _opponent.upcard.type=="n") then
	 		 return true
	 	else 
	 		return false
	 	end
	elseif _card.type == "h" then
 		-- h = hazard
 		if hassafety(_opponent,_card.safety) then
	 		return false
	 	elseif _opponent.upcard ~= nil and (_opponent.upcard.type=="g" or _opponent.upcard.type=="n" or ((_opponent.upcard.type=="f" or _opponent.upcard.type=="r") and hassafety(_opponent,"emergency"))) then
	 		return true
	 	elseif _opponent.upcard == nil and hassafety(_opponent,"emergency") then
	 		return true
	 	else
	 		return false
	 	end
	elseif _card.type == "r" then
 		-- r = remedy
 		if _player.upcard ~= nil and _player.upcard.type == "h" and _player.upcard.remedy == _card.name then
 			return true
 		else
 			return false
 		end
	elseif _card.type == "l" then
 		-- l = speed limit
 		if _opponent.limit or hassafety(_opponent,_card.safety) then
	 		return false
	 	else
	 		return true
	 	end
	elseif _card.type == "v" then
 		-- v = remove limit
 		if not hassafety(_player,"emergency") and _player.limit then
 			return true
 		else
 			return false
 		end
	elseif _card.type == "f" then
 		-- f = safety
 		return true
	end
	
	return false
end

function playcard(_player,_opponent,_card)
	-- do we play this card on ourselves or opponent?
	if _card.type == "h" or _card.type == "s" then
		_opponent.upcard = clonecard(_card)
	elseif _card.type == "l" then
		_opponent.limit = true
	elseif _card.type == "n" then
		_player.upcard = clonecard(_card)
		-- add value to player's score
		_player.score += _player.upcard.value
		if _player.upcard.value == 200 then
			_player.num200s+=1
		end
	elseif _card.type == "f" then
		if _card.name == "emergency" then
			_player.limit = false
			if _player.upcard != nil and _player.upcard.type == "s" then
				_player.upcard = nil
			end
		elseif _card.name != "emergency" and _player.upcard != nil and _card.name == _player.upcard.safety then
			_player.upcard = clonecard(_card)
		end
		-- add card to player safeties
		add(_player.safeties,clonecard(_card))
	elseif _card.type == "v" then
		_player.limit = false
	elseif _card.type == "g" or _card.type == "r" then
		_player.upcard = clonecard(_card)
	end
	del(_player.hand,_card)
end

function ismatchwon()
	if player.total < totalgoal and cpu.total < totalgoal then
		return ""
	elseif player.total >= totalgoal and cpu.total < totalgoal then
		return player.name
	elseif cpu.total >= totalgoal and player.total < totalgoal then
		return cpu.name
	elseif player.total > cpu.total then
		return player.name
	elseif cpu.total > player.total then
		return cpu.name
	else
		return ""
	end
end

function isracewon()
	if player.score == curgoal then
		-- player wins
		winner = player
		loser = cpu
	elseif cpu.score == curgoal then
		-- cpu wins
		winner = cpu
		loser = player
	elseif #deck == 0 and player.score < curgoal and cpu.score < curgoal and #(player.hand) == 0 and #(cpu.hand) == 0 then
		-- we end in a draw
		winner = {name="draw"}
	else
		return ""
	end
	player.total += player.score
	player.total += #(player.safeties) * 100
	if #(player.safeties) == 4 then
		player.total += 400
	end
	cpu.total += cpu.score
	cpu.total += #(cpu.safeties) * 100
	if #(cpu.safeties) == 4 then
		cpu.total += 400
	end
	
	if winner.name ~= "draw" then
		-- race winner gets 400 points
		winner.total += 400
	
		if loser.score == 0 then
			-- shutout, 500 points
			winner.total += 500
		end

		if #deck == 0 then
			-- delayed action, 300 points
			winner.total += 300
		end
	
		if winner.num200s == 0 then
			-- safe trip, 300 points
			winner.total += 300
		end
	
		-- TODO: extension, 200 points
		-- TODO: coup fourre, 300 points each
	end
	
	--player.score = 0
	--cpu.score = 0
	return winner.name
end

function clonecard(_card)
	return {type=_card.type,value=_card.value,belowlimit=_card.belowlimit,name=_card.name,remedy=_card.remedy,safety=_card.safety,sprite=_card.sprite}
end
__gfx__
000000006666666666666666666666666666666666666666bbbbbbbb88888888888888888888888888888888bbbbbbbb88888888cccccccccccccccccccccccc
000000006777777667777776677777766777777667777776b777777b88555588855555588555552885999958b777777b85555588cffffffccffffffccffffffc
007007006777777667777776677777766777777667777736b77bb77b85855858855005588555554885955558b77bbb7b85555858cffa0ffccffffffcc070707c
000770006777777667777776677777766777737667777336b7bbbb7b855885588506605885aa752885999558b777bb7b85858558cf066afcc666687cc007070c
000770006777777667777776677737766777337667773336b7bbbb7b855885588506605885aaaa4885955558b77b7b7b85885558cfa660fcc666688cc070707c
007007006777777667737776677337766773337667733336b77bb77b85855858850000588505502885999958b7b7777b85888558cff0affcc0ff0f0cc0fffffc
000000006737777667337776673337766733337667333336b777777b88555588855555588555554885555558bb77777b85555558cffffffccffffffcc0fffffc
000000006666666666666666666666666666666666666666bbbbbbbb88888888888888888888888888888888bbbbbbbb88888888cccccccccccccccccccccccc
ccccccccbbbbbbbbbbbbbbbbbbbbbbbb111111118888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
cffffffcb777777bb777777bb777777b129292918778777800000000000000000000000000000000000000000000000000000000000000000000000000000000
cffffffcb777707bb776767bb770077b192929218788787800000000000000000000000000000000000000000000000000000000000000000000000000000000
cf8811fcb777077bb776667bb706607b129292918778787800000000000000000000000000000000000000000000000000000000000000000000000000000000
cf8811fcb788877bb777677bb706607b192929218878787800000000000000000000000000000000000000000000000000000000000000000000000000000000
c000000cb788877bb777677bb770077b129292918778777800000000000000000000000000000000000000000000000000000000000000000000000000000000
cffffffcb788877bb777677bb777777b192929218888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccbbbbbbbbbbbbbbbbbbbbbbbb111111118888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e3333ee3333eeeeeeeeeeeeeeeeeeeee444eeeeeee444eeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e3663ee3bb3eeeeeeeeeeeeeeeeeeeee484ee444ee494eeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e36b3ee3bb3eeeeeeeeeeeeeeeeeeeee484ee484ee494eeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e3bb3e3bbb3eeeeeeeeeeeeeeeeeeeee494e49994e494eeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e3bb33bbb3eeeeeeeeeeeeeeeeeeeeee494e49494e494eeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e3bbbbbb3eeeeeeeeeeeeeeeeeeeeeee4994944494994eeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e3bbbbb3eeee33333e333eeeee333eeee49499999494ee444ee444ee000000000000000000000000000000000000000000000000000000000000000000000000
e3bbbbbb3eee36bb3e363eeee36bb3eee49999999994e48894e4844e000000000000000000000000000000000000000000000000000000000000000000000000
e3bbbbbbb3ee33b33e3b3eee36333b3ee49994449994e48494e4894e000000000000000000000000000000000000000000000000000000000000000000000000
e3bb333bbb3ee3b3ee3b3eee3b3b3b3eee499444994ee44944e494ee000000000000000000000000000000000000000000000000000000000000000000000000
e3bb3ee3bb3e33b33e3b333e3b333b3eee4994e4994ee49994e44eee000000000000000000000000000000000000000000000000000000000000000000000000
e3bb3eee3b3e3bbb3e3bbb3ee3bbb3eeeee494e494eee49994e494ee000000000000000000000000000000000000000000000000000000000000000000000000
e3333eee333e33333e33333eee333eeeeee44eee44eee49994e4994e000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000007570095700b5700050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
