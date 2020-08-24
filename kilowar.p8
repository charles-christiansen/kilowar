pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--init functions

--TODO:
----4. coup fourre!
----5. if draw during extension, bonus goes to non-calling player
----6. w-l record save/clear
----7. better sprites
----8. card legend screen

function _init()
	deck = shuffledeck()
	playerbox = {x=0,y=90,xe=128,ye=100,col=3}
	debugbox = {x=0,y=102,xe=128,ye=112,col=5}
	cpubox = {x=0,y=114,xe=128,ye=124,col=4}
	playerptrbox = {x=10,y=30,xe=80,ye=40,col=0}
	player = {name="player",col=3,hand={},score=0,total=0,cfs=0,num200s=0,limit=false,upcard=nil,prevupcard=nil,safeties={},cardy=20,box=playerbox}
	cpu = {name="cpu",col=4,hand={},score=0,total=0,cfs=0,num200s=0,limit=false,upcard=nil,prevupcard=nil,safeties={},cardy=60,box=cpubox,skill=1}
	dealt = false
	stdgoal = 700
	extgoal = 1000
	curgoal = 700
	totalgoal = 5000
	currentplayer = {name="nobody"}
	turninprogress = false
	playinprogress = false
	discardinprogress = false
	drawupinprogress = false
	playedcard = nil
	playedcardtarget = nil
	discardedcard = nil
	drawncard = nil
	cardplayspeed = 0.02
	mode = "start"
	playercardptr = 1
	deckx = 100
	decky = 78
	limitx = 94
	cardtargetx = -1
	cardtargety = -1
	
	racewinner = ""
	matchwinner = ""
	raceover = false
	matchover = false
	
	playerraceoverpoints = 0
	cpuraceoverpoints = 0

	-- debugging
	debug = ""
	cpudebug = ""
	cheat = false
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
			add(_d,{type="n",value=25,belowlimit=true,name="25",remedy="",safety="",sprite=1,x=-1,y=-1})
			add(_d,{type="n",value=50,belowlimit=true,name="50",remedy="",safety="",sprite=2,x=-1,y=-1})
			add(_d,{type="n",value=75,belowlimit=false,name="75",remedy="",safety="",sprite=3,x=-1,y=-1})
		end
		if i <= 12 then
			add(_d,{type="n",value=100,belowlimit=false,name="100",remedy="",safety="",sprite=4,x=-1,y=-1})
		end

		if i <=4 then
			add(_d,{type="n",value=200,belowlimit=false,name="200",remedy="",safety="",sprite=5,x=-1,y=-1})
		end
		-- add go cards
		add(_d,{type="g",value=0,belowlimit=false,name="go",remedy="",safety="",sprite=6,x=-1,y=-1})
		-- add stop cards
		if i <=5 then
			add(_d,{type="s",value=0,belowlimit=false,name="stop",remedy="",safety="emergency",sprite=7,x=-1,y=-1})
		end
		-- add hazards + speed limits
		if i <= 3 then
			add(_d,{type="h",value=0,belowlimit=false,name="flat",remedy="spare",safety="ppt",sprite=8,x=-1,y=-1})
			add(_d,{type="h",value=0,belowlimit=false,name="crash",remedy="repair",safety="ace",sprite=9,x=-1,y=-1})
			add(_d,{type="h",value=0,belowlimit=false,name="empty",remedy="gascan",safety="tanker",sprite=10,x=-1,y=-1})
		end
		if i <= 4 then
			add(_d,{type="l",value=0,belowlimit=false,name="limit 50",remedy="nolimit",safety="emergency",sprite=12,x=-1,y=-1})
		end
		-- add remedies + remove limits
		if i <= 6 then
			add(_d,{type="v",value=0,belowlimit=false,name="nolimit",remedy="",safety="emergency",sprite=11,x=-1,y=-1})
			add(_d,{type="r",value=0,belowlimit=false,name="gascan",remedy="",safety="",sprite=17,x=-1,y=-1})
			add(_d,{type="r",value=0,belowlimit=false,name="repair",remedy="",safety="",sprite=18,x=-1,y=-1})
			add(_d,{type="r",value=0,belowlimit=false,name="spare",remedy="",safety="",sprite=19,x=-1,y=-1})
		end
		-- add safeties
		if i == 1 then
			add(_d,{type="f",value=0,belowlimit=false,name="ppt",remedy="",safety="",sprite=13,x=-1,y=-1})
			add(_d,{type="f",value=0,belowlimit=false,name="tanker",remedy="",safety="",sprite=14,x=-1,y=-1})
			add(_d,{type="f",value=0,belowlimit=false,name="ace",remedy="",safety="",sprite=15,x=-1,y=-1})
			add(_d,{type="f",value=0,belowlimit=false,name="emergency",remedy="",safety="",sprite=16,x=-1,y=-1})
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
	if #racewinner == 0 and not drawupinprogress and not turninprogress and not playinprogress and not discardinprogress then
		racewinner = isracewon()
	end
	if matchover then
		debug = "*** "..matchwinner.." wins the match ***"
		cpudebug = "press ❎ to start a new match!"
		if btnp(5) then
			newmatch()
		end
	elseif raceover then
		if racewinner == "draw" then
			debug = "nobody finished the race"
		else
			debug = racewinner.." wins!"
		end
		cpudebug = "press ❎ to start the next race!"
		if btnp(5) then
			newrace()
		end
	elseif #racewinner > 0 then
		if curgoal == stdgoal then
			if racewinner == "player" then
				debug = "press ⬆️ to extend to 1000"
				cpudebug = "press ⬇️ to end the race now"
				if btnp(2) then
					curgoal = extgoal
					debug = "player extends to 1000!"
					cpudebug = ""
					racewinner = ""
				end
				if btnp(3) then
					player.total += playerraceoverpoints
					cpu.total += cpuraceoverpoints

					-- check for match win condition
					matchwinner = ismatchwon()

					if #matchwinner > 0 then
						matchover = true
					else
						raceover = true
					end
				end
			elseif racewinner == "cpu" then
				-- cpu will extend only 30% of the time
				extdraw = flr(rnd(100))+1
				if extdraw > 70 then
					curgoal = extgoal
					debug = "cpu extends to 1000!"
					cpudebug = ""
					racewinner = ""
				else
					player.total += playerraceoverpoints
					cpu.total += cpuraceoverpoints
					-- check for match win condition
					matchwinner = ismatchwon()

					if #matchwinner > 0 then
						matchover = true
					else
						raceover = true
					end
				end
			else
				-- draw
				player.total += playerraceoverpoints
				cpu.total += cpuraceoverpoints
				-- check for match win condition
				matchwinner = ismatchwon()

				if #matchwinner > 0 then
					matchover = true
				else
					raceover = true
				end
			end
		else
			player.total += playerraceoverpoints
			cpu.total += cpuraceoverpoints

			-- check for match win condition
			matchwinner = ismatchwon()

			if #matchwinner > 0 then
				matchover = true
			else
				raceover = true
			end
		end
	else
		-- deal the players a hand
		if not dealt then
			if cheat then
				cheatdealto(player)
			end
			for i=1,6 do
				if not cheat then
					dealto(player,i)
				end
				dealto(cpu,i)
			end
			dealt = true
		end
	
		if not turninprogress and not drawupinprogress then
			playinprogress = false
			if currentplayer.name==player.name then
				currentplayer = cpu
			else
				currentplayer = player
			end
			draw_up(currentplayer)
			drawupinprogress = true
		end
		if drawupinprogress then
			if drawncard != nil then
				drawncard.x += drawncard.dx
				if drawncard.dx < 0 and drawncard.x <= cardtargetx then
					drawncard.x = cardtargetx
					drawncard.dx = 0
				elseif drawncard.dx > 0 and drawncard.x >= cardtargetx then
					drawncard.x = cardtargetx
					drawncard.dx = 0
				end
				-- card could move up or down depending on type and player
				drawncard.y += drawncard.dy
				if drawncard.dy > 0 and drawncard.y >= cardtargety then
					drawncard.y = cardtargety
					drawncard.dy = 0
				elseif drawncard.dy < 0 and drawncard.y <= cardtargety then
					drawncard.y = cardtargety
					drawncard.dy = 0
				end
				if drawncard.dx == 0 and drawncard.dy == 0 then
					drawncard = nil
					playedcard = nil
					discardedcard = nil
					playedcardtarget = nil
					player.prevupcard = nil
					cpu.prevupcard = nil
					playinprogress = false
					discardinprogress = false
					turninprogress = true
					drawupinprogress = false
				end
			else
				drawncard = nil
				playedcard = nil
				discardedcard = nil
				playedcardtarget = nil
				player.prevupcard = nil
				cpu.prevupcard = nil
				playinprogress = false
				discardinprogress = false
				turninprogress = true
				drawupinprogress = false
			end
		elseif discardinprogress then
			discardedcard.x += discardedcard.dx
			if discardedcard.dx < 0 and discardedcard.x <= cardtargetx then
				discardedcard.x = cardtargetx
				discardedcard.dx = 0
			elseif discardedcard.dx > 0 and discardedcard.x >= cardtargetx then
				discardedcard.x = cardtargetx
				discardedcard.dx = 0
			end
			-- card could move up or down depending on type and player
			discardedcard.y += discardedcard.dy
			if discardedcard.dy > 0 and discardedcard.y >= cardtargety then
				discardedcard.y = cardtargety
				discardedcard.dy = 0
			elseif discardedcard.dy < 0 and discardedcard.y <= cardtargety then
				discardedcard.y = cardtargety
				discardedcard.dy = 0
			end
			if discardedcard.dx == 0 and discardedcard.dy == 0 then
				playedcard = nil
				discardedcard = nil
				playedcardtarget = nil
				player.prevupcard = nil
				cpu.prevupcard = nil
				playinprogress = false
				discardinprogress = false
				turninprogress = false
				drawupinprogress = false
			end
		elseif playinprogress then
			-- card could move left or right depending on type
			playedcard.x += playedcard.dx
			if playedcard.dx < 0 and playedcard.x <= cardtargetx then
				playedcard.x = cardtargetx
				playedcard.dx = 0
			elseif playedcard.dx > 0 and playedcard.x >= cardtargetx then
				playedcard.x = cardtargetx
				playedcard.dx = 0
			end
			-- card could move up or down depending on type and player
			playedcard.y += playedcard.dy
			if playedcard.dy > 0 and playedcard.y >= cardtargety then
				playedcard.y = cardtargety
				playedcard.dy = 0
			elseif playedcard.dy < 0 and playedcard.y <= cardtargety then
				playedcard.y = cardtargety
				playedcard.dy = 0
			end
			if playedcard.dx == 0 and playedcard.dy == 0 then
				playedcard = nil
				discardedcard = nil
				playedcardtarget = nil
				player.prevupcard = nil
				cpu.prevupcard = nil
				playinprogress = false
				discardinprogress = false
				turninprogress = false
				drawupinprogress = false
			end
		else
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
						playedcard = player.hand[playercardptr]
						player.prevupcard = player.upcard
						cpu.prevupcard = cpu.upcard
						playcard(player,cpu,player.hand[playercardptr])
						animatecard(playedcard,player,cpu)
						if playercardptr > #(player.hand) then
							playercardptr-=1
						end
						playinprogress = true
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
						discardinprogress = true
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
						playedcard = cpu.hand[i]
						player.prevupcard = player.upcard
						cpu.prevupcard = cpu.upcard
						playcard(cpu,player,cpu.hand[i])
						animatecard(playedcard,cpu,player)
						playinprogress = true
						return
					end
				end
		
				-- cpu is unable to play, needs to discard
				debug=""
				cpudebug="cpu discards "..cpu.hand[1].name
				discard(cpu,cpu.hand[1])
				discardinprogress = true
			end
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
	spr(20,deckx,decky)
	print("="..#deck,109,80,10)
	if debug != "" then
		print(debug,5,playerbox.y+2,10)
	else
		if player.prevupcard != nil and playedcard != nil and playedcardtarget != nil then
			spr(player.prevupcard.sprite,playerbox.x+5,playerbox.y+2)
		elseif player.prevupcard == nil and player.upcard ~= nil then
			spr(player.upcard.sprite,playerbox.x+5,playerbox.y+2)
		end
		numsafeties = #(player.safeties)
		if playedcard != nil and playedcardtarget != nil and playedcardtarget.name == "player" and playedcard.type == "f" then
			numsafeties -= 1
		end
		for i=1,numsafeties do
			spr(player.safeties[i].sprite,playerbox.x+88+(10*(i-1)),playerbox.y+2)
		end
	end
	if cpu.prevupcard != nil and playedcard != nil and playedcardtarget != nil then
		spr(cpu.prevupcard.sprite,cpubox.x+5,cpubox.y+2)
	elseif cpu.prevupcard == nil and cpu.upcard ~= nil then
		spr(cpu.upcard.sprite,cpubox.x+5,cpubox.y+2)
	end
	numsafeties = #(cpu.safeties)
	if playedcard != nil and playedcardtarget != nil and playedcardtarget.name == "cpu" and playedcard.type == "f" then
		numsafeties -= 1
		end
	for i=1,numsafeties do
		spr(cpu.safeties[i].sprite,cpubox.x+88+(10*(i-1)),cpubox.y+2)
	end

	if drawupinprogress and currentplayer.name == "player" then
		for i=1,#(player.hand)-1 do
			spr(player.hand[i].sprite,player.hand[i].x,player.hand[i].y)
		end
	else
		for i=1,#(player.hand) do
			spr(player.hand[i].sprite,player.hand[i].x,player.hand[i].y)
		end
	end
	if (player.limit and (playedcard == nil or (playedcard != nil and (playedcardtarget.name != "player" or playedcard.type != "l")))) or (playedcard != nil and playedcardtarget != nil and playedcard.type == "v" and playedcardtarget.name == "player") then
		spr(21,limitx,player.cardy)
	end
	if drawupinprogress and currentplayer.name == "cpu" then
		for i=1,#(cpu.hand)-1 do
			spr(20,cpu.hand[i].x,cpu.hand[i].y)
		end
	else
		for i=1,#(cpu.hand) do
			spr(20,cpu.hand[i].x,cpu.hand[i].y)
		end
	end
	if (cpu.limit and (playedcard == nil or (playedcard != nil and (playedcardtarget.name != "cpu" or playedcard.type != "l")))) or (playedcard != nil and playedcardtarget != nil and playedcard.type == "v" and playedcardtarget.name == "cpu") then
		spr(21,limitx,cpu.cardy)
	end
	if playedcard != nil then
		spr(playedcard.sprite,playedcard.x,playedcard.y)
	end
	if discardedcard != nil then
		spr(discardedcard.sprite,discardedcard.x,discardedcard.y)
	end
	if drawupinprogress then
		if currentplayer.name == "player" then
			spr(drawncard.sprite,drawncard.x,drawncard.y)
		else
			spr(20,drawncard.x,drawncard.y)
		end
	end
end
-->8
-- utility functions
function newmatch()
	player.total=0
	cpu.total=0
	matchover=false
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
	player.prevupcard=nil
	cpu.prevupcard=nil
	playercardptr=1
	currentplayer = {name="nobody"}
	turninprogress = false
	playinprogress = false
	discardinprogress = false
	drawupinprogress = false
	playedcard = nil
	playedcardtarget = nil
	discardedcard = nil
	drawncard = nil
	deck=shuffledeck()
	debug=""
	cpudebug=""
	racewinner=""
	raceover=false
	playerraceoverpoints=0
	cpuraceoverpoints=0
	curgoal=stdgoal
end

function draw_up(_curplayer,_cf)
	if _cf then
		-- after coup foure, we draw two
		card = deck[1]
		if card != nil then
			card.x = 64 -- card 6 times 10 plus 4
			card.y = _curplayer.cardy
			add(_curplayer.hand,card)
			del(deck,card)
		end
	end
	card = deck[1]
	if card != nil then
		card.x = 74 -- card 7 times 10 plus 4
		card.y = _curplayer.cardy
		drawncard = clonecard(card)
		drawncard.x = deckx
		drawncard.y = decky
		cardtargetx = card.x
		cardtargety = card.y
		drawncard.dx = cardplayspeed * (cardtargetx - drawncard.x)
		drawncard.dy = cardplayspeed * (cardtargety - drawncard.y)
		add(_curplayer.hand,card)
		del(deck,card)
	end
end

function discard(_player,_card)
	discardedcard = clonecard(_card)
	cardtargetx = -5
	cardtargety = -5
	discardedcard.dx = cardplayspeed * (cardtargetx - discardedcard.x)
	discardedcard.dy = cardplayspeed * (cardtargety - discardedcard.y)
	del(_player.hand,_card)
	recalculatehandpos(_player)
end

function dealto(_player,_cardnum)
	card = deck[1]
	card.x = _cardnum * 10 + 4
	card.y = _player.cardy
	add(_player.hand,card)
	del(deck,deck[1])
end

function cheatdealto(_player)
	-- search the deck for safeties!
	cn = 1
	for i=#deck,1,-1 do
		card = deck[i]
		if _player.name == "player" and #(_player.safeties) < 4 and card.type == "f" then
			card.x = cn * 10 + 4
			cn += 1
			card.y = _player.cardy
			add(_player.hand,card)
			del(deck,deck[i])
		end		
	end
	for i=1,2 do
		card = deck[1]
		card.x = cn * 10 + 4
		cn += 1
		card.y = _player.cardy
		add(_player.hand,card)
		del(deck,deck[1])
	end
end

function recalculatehandpos(_curplayer)
	for i=1,#(_curplayer.hand) do
		_curplayer.hand[i].x = i*10+4
	end
end

function animatecard(_card,_cardplayer,_otherplayer)
	if _card.type == "n" or _card.type == "g" or _card.type == "r" or (_card.type == "f" and _card.name != "emergency" and _cardplayer.upcard != nil and _cardplayer.upcard.safety == _card.name) then
		cardtargetx = _cardplayer.box.x + 5
		cardtargety = _cardplayer.box.y + 2
		playedcardtarget = _cardplayer
	elseif _card.type == "s" or _card.type == "h" then
		cardtargetx = _otherplayer.box.x + 5
		cardtargety = _otherplayer.box.y + 2
		playedcardtarget = _otherplayer
	elseif _card.type == "v" then
		cardtargetx = limitx
		cardtargety = _cardplayer.cardy
		playedcardtarget = _cardplayer
	elseif _card.type == "l" then
		cardtargetx = limitx
		cardtargety = _otherplayer.cardy
		playedcardtarget = _otherplayer
	elseif _card.type == "f" then
		cardtargetx = _cardplayer.box.x + 88 + (10 * (#(_cardplayer.safeties) - 1))
		cardtargety = _cardplayer.box.y + 2
		playedcardtarget = _cardplayer
	end
	_card.dx = cardplayspeed * (cardtargetx - _card.x)
	_card.dy = cardplayspeed * (cardtargety - _card.y)
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
	recalculatehandpos(_player)
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
	
	-- We calculate but don't add points to total here, we may call extension!
	playerraceoverpoints = 0
	cpuraceoverpoints = 0

	playerraceoverpoints += player.score
	playerraceoverpoints += #(player.safeties) * 100
	if #(player.safeties) == 4 then
		playerraceoverpoints += 400
	end
	cpuraceoverpoints += cpu.score
	cpuraceoverpoints += #(cpu.safeties) * 100
	if #(cpu.safeties) == 4 then
		cpuraceoverpoints += 400
	end
	
	if winner.name == "player" then
		-- race winner gets 400 points
		playerraceoverpoints += 400
	
		if loser.score == 0 then
			-- shutout, 500 points
			playerraceoverpoints += 500
		end

		if #deck == 0 then
			-- delayed action, 300 points
			playerraceoverpoints += 300
		end
	
		if winner.num200s == 0 then
			-- safe trip, 300 points
			playerraceoverpoints += 300
		end
		
		if curgoal == extgoal then
			-- extension, 200 points
			playerraceoverpoints += 200
		end
		-- TODO: coup fourre, 300 points each
	elseif winner.name == "cpu" then
		-- race winner gets 400 points
		cpuraceoverpoints += 400
	
		if loser.score == 0 then
			-- shutout, 500 points
			cpuraceoverpoints += 500
		end

		if #deck == 0 then
			-- delayed action, 300 points
			cpuraceoverpoints += 300
		end
	
		if winner.num200s == 0 then
			-- safe trip, 300 points
			cpuraceoverpoints += 300
		end
		
		if curgoal == extgoal then
			-- extension, 200 points
			cpuraceoverpoints += 200
		end
		-- TODO: coup fourre, 300 points each
	end
	
	return winner.name
end

function clonecard(_card)
	return {type=_card.type,value=_card.value,belowlimit=_card.belowlimit,name=_card.name,remedy=_card.remedy,safety=_card.safety,sprite=_card.sprite,x=_card.x,y=_card.y}
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
