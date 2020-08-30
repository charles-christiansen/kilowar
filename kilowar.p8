pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--init functions

--TODO:
----5. w-l record save/clear
----6. better sprites
----7. card legend screen

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
	calledext = "nobody"
	turninprogress = false
	playinprogress = false
	discardinprogress = false
	drawupinprogress = false
	playedcard = nil
	playedcardtarget = nil
	discardedcard = nil
	cancf = false
	iscf = false
	cancfcard = nil
	drawncard = nil
	multidraw = false
	safetyplay = 0
	hurtplay = 0
	helpplay = 0
	cardplayspeed = 0.025
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
	
	-- normal difficulty
	difficulty = 2
	diffchoices = {"easy","normal","hard"}
	
	playerraceoverpoints = 0
	cpuraceoverpoints = 0

	-- debugging
	debug = ""
	cpudebug = ""
	
	winname = ""
	winscore = 0
	winsft = 0
	wincfs = 0
	winall4 = 0
	winpts = 0
	winshut = 0
	windelay = 0
	winsafe = 0
	winext = 0
	wincol = 7
	
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
			add(_d,{type="n",value=25,belowlimit=true,name="25",remedy="",safety="",sprite=1,x=-1,y=-1,fx=1,iscf=false})
			add(_d,{type="n",value=50,belowlimit=true,name="50",remedy="",safety="",sprite=2,x=-1,y=-1,fx=1,iscf=false})
			add(_d,{type="n",value=75,belowlimit=false,name="75",remedy="",safety="",sprite=3,x=-1,y=-1,fx=1,iscf=false})
		end
		if i <= 12 then
			add(_d,{type="n",value=100,belowlimit=false,name="100",remedy="",safety="",sprite=4,x=-1,y=-1,fx=1,iscf=false})
		end

		if i <=4 then
			add(_d,{type="n",value=200,belowlimit=false,name="200",remedy="",safety="",sprite=5,x=-1,y=-1,fx=1,iscf=false})
		end
		-- add go cards
		add(_d,{type="g",value=0,belowlimit=false,name="go",remedy="",safety="",sprite=6,x=-1,y=-1,fx=7,iscf=false})
		-- add stop cards
		if i <=5 then
			add(_d,{type="s",value=0,belowlimit=false,name="stop",remedy="",safety="emergency",sprite=7,x=-1,y=-1,fx=6,iscf=false})
		end
		-- add hazards + speed limits
		if i <= 3 then
			add(_d,{type="h",value=0,belowlimit=false,name="flat",remedy="spare",safety="ppt",sprite=8,x=-1,y=-1,fx=4,iscf=false})
			add(_d,{type="h",value=0,belowlimit=false,name="crash",remedy="repair",safety="ace",sprite=9,x=-1,y=-1,fx=3,iscf=false})
			add(_d,{type="h",value=0,belowlimit=false,name="empty",remedy="gascan",safety="tanker",sprite=10,x=-1,y=-1,fx=5,iscf=false})
		end
		if i <= 4 then
			add(_d,{type="l",value=0,belowlimit=false,name="limit 50",remedy="nolimit",safety="emergency",sprite=12,x=-1,y=-1,fx=1,iscf=false})
		end
		-- add remedies + remove limits
		if i <= 6 then
			add(_d,{type="v",value=0,belowlimit=false,name="nolimit",remedy="",safety="emergency",sprite=11,x=-1,y=-1,fx=1,iscf=false})
			add(_d,{type="r",value=0,belowlimit=false,name="gascan",remedy="",safety="",sprite=17,x=-1,y=-1,fx=1,iscf=false})
			add(_d,{type="r",value=0,belowlimit=false,name="repair",remedy="",safety="",sprite=18,x=-1,y=-1,fx=1,iscf=false})
			add(_d,{type="r",value=0,belowlimit=false,name="spare",remedy="",safety="",sprite=19,x=-1,y=-1,fx=1,iscf=false})
		end
		-- add safeties
		if i == 1 then
			add(_d,{type="f",value=0,belowlimit=false,name="ppt",remedy="",safety="",sprite=13,x=-1,y=-1,fx=1,iscf=false})
			add(_d,{type="f",value=0,belowlimit=false,name="tanker",remedy="",safety="",sprite=14,x=-1,y=-1,fx=1,iscf=false})
			add(_d,{type="f",value=0,belowlimit=false,name="ace",remedy="",safety="",sprite=15,x=-1,y=-1,fx=1,iscf=false})
			add(_d,{type="f",value=0,belowlimit=false,name="emergency",remedy="",safety="",sprite=16,x=-1,y=-1,fx=8,iscf=false})
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
	elseif mode == "raceover" then
		update_raceover()
	elseif mode == "matchover" then
		update_matchover()
	else
		update_game()
	end
end

function update_start()
	if btnp(2) then
		difficulty -= 1
		if difficulty < 1 then
			difficulty = 3
		end
	end
	if btnp(3) then
		difficulty += 1
		if difficulty > 3 then
			difficulty = 1
		end
	end
	if btnp(5) then
		mode = "game"
	end
end

function update_raceover()
	if btnp(5) then
		newrace()
		mode = "game"
	end
end

function update_matchover()
	if btnp(5) then
		newmatch()
		mode = "game"
	end
	if btnp(4) then
		newmatch()
		mode = "start"
	end
end

function update_game()
	-- check for race win condition
	if #racewinner == 0 and not drawupinprogress and not turninprogress and not playinprogress and not discardinprogress then
		racewinner = isracewon()
	end
	if matchover then
		mode = "matchover"
	elseif raceover then
		mode = "raceover"
	elseif #racewinner > 0 then
		if curgoal == stdgoal then
			if racewinner == "player" then
				debug = "press ⬆️ to extend to 1000"
				cpudebug = "press ⬇️ to end the race now"
				if btnp(2) then
					curgoal = extgoal
					debug = "player extends to 1000!"
					calledext = "player"
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
				if difficulty == 1 then
					-- easy cpu will never extend
					player.total += playerraceoverpoints
					cpu.total += cpuraceoverpoints
					-- check for match win condition
					matchwinner = ismatchwon()

					if #matchwinner > 0 then
						matchover = true
					else
						raceover = true
					end
				elseif difficulty == 2 then
					-- normal cpu will extend only 50% of the time
					extfloor = 50
					extdraw = flr(rnd(100))+1
					if extdraw > extfloor then
						curgoal = extgoal
						debug = "cpu extends to 1000!"
						calledext = "cpu"
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
					-- hard cpu will always extend if 400 or more kilos ahead
					-- unless stopping results in a shutout
					-- hard cpu will always extend if player shows a hazard that 
					-- cpu has safety for
					cond1 = cpu.score - player.score >= 400 and player.score > 0
					cond2 = player.upcard != nil and ((player.upcard.type == "s" and hassafety(cpu,"emergency")) or (player.upcard.type == "h" and hassafety(cpu,player.upcard.safety)))
					if cond1 or cond2 then
						curgoal = extgoal
						debug = "cpu extends to 1000!"
						calledext = "cpu"
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
		
		if cancf then
			if currentplayer.name==player.name then
				-- cpu can coup fourre
				if difficulty == 1 then
					-- easy cpu will call it 60% of the time
					cffloor = 40
				elseif difficulty == 2 then
					-- normal cpu will call it 75% of the time
					cffloor = 25
				else
					-- hard cpu will call it 95% of the time
					cffloor = 5
				end
				
				if flr(rnd(100))+1 > cffloor then
					cpudebug = "~~~~~coup fourre!~~~~~"
					playcoupfourre(cpu,player)
					playinprogress = false
					turninprogress = false
					cancf = false
					iscf = true
				end
			else
				-- player can coup fourre
				cpudebug = "⬆️ to coup fourre!"
				if btnp(2) then
					playcoupfourre(player,cpu)
					playinprogress = false
					turninprogress = false
					cancf = false
					iscf = true
				end
			end
		elseif cpudebug != "~~~~~coup fourre!~~~~~" then
			cpudebug = ""
		end
	
		if not turninprogress and not drawupinprogress then
			playinprogress = false
			if not multidraw then
				if currentplayer.name==player.name then
					currentplayer = cpu
				else
					currentplayer = player
				end
			end
			draw_up(currentplayer)
			if iscf then
				multidraw = true
			else
				multidraw = false
			end
			drawupinprogress = true
			cancf = false
			iscf = false
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
					if not multidraw then
						turninprogress = true
					end
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
			if not cancf then
				cpudebug = ""
			end
		else
			if currentplayer.name==player.name then
				if btnp(1) then
					playercardptr += 1
					if playercardptr > #(player.hand) then
						playercardptr = 1
					end
					debug=""
					--sfx(0)
				elseif btnp(0) then
					playercardptr -= 1
					if playercardptr == 0 then
						playercardptr = #(player.hand)
					end
					debug=""
					--sfx(0)
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
						--sfx(playedcard.fx)
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
						--sfx(2)
						discardinprogress = true
					end
				end
			else
				if difficulty == 1 then
					---- 1 = easy (plays to go/recover when possible)
					for i=1,#(cpu.hand) do
						if checkvalidplay(cpu,player,cpu.hand[i]) then
							if cpu.hand[i].type == "f" and ((player.score < 600 and curgoal == stdgoal) or (player.score < 900 and curgoal == extgoal) or #deck == 0) then
								safetyplay = i
							elseif cpu.hand[i].type == "h" or cpu.hand[i].type == "s" or cpu.hand[i].type == "l" then
								hurtplay = i
							else
								debug=""
								playedcard = cpu.hand[i]
								player.prevupcard = player.upcard
								cpu.prevupcard = cpu.upcard
								playcard(cpu,player,cpu.hand[i])
								animatecard(playedcard,cpu,player)
								--sfx(playedcard.fx)
								safetyplay = 0
								hurtplay = 0
								helpplay = 0
								playinprogress = true
								return
							end
						end
					end

					if hurtplay > 0 then
						-- give easy cpu a 50% chance of playing a harm card
						if flr(rnd(100))+1 > 50 then
							debug=""
							playedcard = cpu.hand[hurtplay]
							player.prevupcard = player.upcard
							cpu.prevupcard = cpu.upcard
							playcard(cpu,player,cpu.hand[hurtplay])
							animatecard(playedcard,cpu,player)
							--sfx(playedcard.fx)
							safetyplay = 0
							hurtplay = 0
							helpplay = 0
							playinprogress = true
							return
						end
					end
					
					-- we'll favor discarding over playing a safety
					-- for the first half of the deck unless the upcard
					-- is the matching hazard
					-- otherwise save them for coup fourre!
					if safetyplay > 0 and ((cpu.upcard != nil and cpu.upcard.safety == cpu.hand[safetyplay].name) or #deck < 53) then
						debug=""
						playedcard = cpu.hand[safetyplay]
						player.prevupcard = player.upcard
						cpu.prevupcard = cpu.upcard
						playcard(cpu,player,cpu.hand[safetyplay])
						animatecard(playedcard,cpu,player)
						--sfx(playedcard.fx)
						safetyplay = 0
						playinprogress = true
					else
						-- cpu is unable to play, needs to discard
						debug=""
						if #cpu.hand > 0 then
							for i=1,#(cpu.hand) do
								if cpu.hand[i].type != "f" or #cpu.hand < 5 then
									discard(cpu,cpu.hand[i])
									break
								end
							end
							--sfx(2)
							discardinprogress = true
						end
					end
				elseif difficulty == 2 then
					---- 2 = normal (plays first playable card)
					for i=1,#(cpu.hand) do
						if checkvalidplay(cpu,player,cpu.hand[i]) then
							if cpu.hand[i].type == "f" and ((player.score < 600 and curgoal == stdgoal) or (player.score < 900 and curgoal == extgoal) or #deck == 0) then
								safetyplay = i
							else
								debug=""
								playedcard = cpu.hand[i]
								player.prevupcard = player.upcard
								cpu.prevupcard = cpu.upcard
								playcard(cpu,player,cpu.hand[i])
								animatecard(playedcard,cpu,player)
								--sfx(playedcard.fx)
								safetyplay = 0
								playinprogress = true
								return
							end
						end
					end
				
					-- we'll favor discarding over playing a safety
					-- for the first half of the deck unless the upcard
					-- is the matching hazard
					-- otherwise save them for coup fourre!
					-- !!!TODO: add difficulty level
					if safetyplay > 0 and ((cpu.upcard != nil and cpu.upcard.safety == cpu.hand[safetyplay].name) or #deck < 53) then
						debug=""
						playedcard = cpu.hand[safetyplay]
						player.prevupcard = player.upcard
						cpu.prevupcard = cpu.upcard
						playcard(cpu,player,cpu.hand[safetyplay])
						animatecard(playedcard,cpu,player)
						--sfx(playedcard.fx)
						safetyplay = 0
						playinprogress = true
					else
						-- cpu is unable to play, needs to discard
						debug=""
						if #cpu.hand > 0 then
							for i=1,#(cpu.hand) do
								if cpu.hand[i].type != "f" or #cpu.hand < 5 then
									discard(cpu,cpu.hand[i])
									break
								end
							end
							--sfx(2)
							discardinprogress = true
						end
					end
				else
					---- 3 = hard (plays to stop player when possible)
					for i=1,#(cpu.hand) do
						if checkvalidplay(cpu,player,cpu.hand[i]) then
							if cpu.hand[i].type == "f" and ((player.score < 600 and curgoal == stdgoal) or (player.score < 900 and curgoal == extgoal) or #deck == 0) then
								safetyplay = i
							elseif cpu.hand[i].type == "g" or cpu.hand[i].type == "v" or cpu.hand[i].type == "r" then
								helpplay = i
							elseif cpu.hand[i].type == "n" and cpu.hand[i].value + cpu.score != curgoal then
								helpplay = i
							else
								debug=""
								playedcard = cpu.hand[i]
								player.prevupcard = player.upcard
								cpu.prevupcard = cpu.upcard
								playcard(cpu,player,cpu.hand[i])
								animatecard(playedcard,cpu,player)
								--sfx(playedcard.fx)
								safetyplay = 0
								hurtplay = 0
								helpplay = 0
								playinprogress = true
								return
							end
						end
					end

					if helpplay > 0 then
						debug=""
						playedcard = cpu.hand[helpplay]
						player.prevupcard = player.upcard
						cpu.prevupcard = cpu.upcard
						playcard(cpu,player,cpu.hand[helpplay])
						animatecard(playedcard,cpu,player)
						--sfx(playedcard.fx)
						safetyplay = 0
						hurtplay = 0
						helpplay = 0
						playinprogress = true
						return
					end
					
					-- we'll favor discarding over playing a safety
					-- for the first 75% of the deck unless the upcard
					-- is the matching hazard
					-- otherwise save them for coup fourre!
					if safetyplay > 0 and ((cpu.upcard != nil and cpu.upcard.safety == cpu.hand[safetyplay].name) or #deck < 27) then
						debug=""
						playedcard = cpu.hand[safetyplay]
						player.prevupcard = player.upcard
						cpu.prevupcard = cpu.upcard
						playcard(cpu,player,cpu.hand[safetyplay])
						animatecard(playedcard,cpu,player)
						--sfx(playedcard.fx)
						safetyplay = 0
						playinprogress = true
					else
						-- cpu is unable to play, needs to discard
						debug=""
						todiscard=0
						if #cpu.hand > 0 then
							for i=1,#(cpu.hand) do
								if #cpu.hand < 5 then
									todiscard = i
									break
								elseif cpu.hand[i].type != "f" and cpu.hand[i].type != "h" and cpu.hand[i].type != "l" and cpu.hand[i].type != "s" then
									todiscard = i
									break
								end
							end
							--sfx(2)
							if todiscard > 0 then
								discard(cpu,cpu.hand[todiscard])
							else
								discard(cpu,cpu.hand[1])
							end
							discardinprogress = true
						end
					end
				end
			end
		end
	end
end
-->8
--draw functions
function _draw()
	if mode == "start" then
		draw_start()
	elseif mode == "raceover" then
		draw_raceover()
	elseif mode == "matchover" then
		draw_matchover()
	else
		draw_game()
	end
end

function draw_matchover()
	cls()
	spr(22,0,0)
	for i=1,15 do
		spr(22,i*8,0)
		spr(22,0,i*8)
		spr(22,120,i*8)
		spr(22,i*8,120)
	end
	print("***** "..matchwinner.." wins! *****",10,10,7)
	print("final scores",30,30,7)
	if matchwinner == "player" then
		print("player: "..player.total,10,40,player.col)
		print("cpu: "..cpu.total,10,48,cpu.col)
	else
		print("cpu: "..cpu.total,10,40,cpu.col)
		print("player: "..player.total,10,48,player.col)
	end
	print("press ❎ to start a",10,63,4)
	print("new match!",10,71,4)
	print("press 🅾️ to",10,81,4)
	print("restart kilowar!",10,89,4)
end

function draw_raceover()
	cls()
	if winname != "draw" then
		print(winname.." wins!",5,5,wincol)
		print("kilos: "..winscore,5,13,wincol)
		print("win bonus: "..winpts,5,21,wincol)
		print("safeties: "..winsft,5,29,wincol)
		print("coup fourre: "..wincfs,5,37,wincol)
		print("all 4 safeties: "..winall4,5,45,wincol)
		print("shutout: "..winshut,5,53,wincol)
		print("delayed win: "..windelay,5,61,wincol)
		print("safe trip: "..winsafe,5,69,wincol)
		print("extension: "..winext,5,77,wincol)
	else
		print("nobody won the race",5,5,wincol)
		print("player kilos: "..player.score,5,13,player.col)
		print("cpu kilos: "..cpu.score,5,21,cpu.col)
		print("player safeties: "..#(player.safeties)*100,5,29,player.col)
		print("cpu safeties: "..#(cpu.safeties)*100,5,37,cpu.col)
		print("player coup fourre: "..player.cfs*300,5,45,player.col)
		print("cpu coup fourre: "..cpu.cfs*300,5,53,cpu.col)
		if #player.safeties == 4 then
			print("player all safeties: 400",5,61,player.col)
		else
			print("player all safeties: 0",5,61,player.col)
		end
		if #cpu.safeties == 4 then
			print("cpu all safeties: 400",5,69,cpu.col)
		else
			print("cpu all safeties: 0",5,69,cpu.col)
		end
		if calledext == "cpu" then
			print("player extension stop: 200",5,77,player.col)
		else
			print("player extension stop: 0",5,77,player.col)
		end
		if calledext == "player" then
			print("cpu extension stop: 200",5,85,cpu.col)
		else
			print("cpu extension stop: 0",5,85,cpu.col)
		end
	end
	print("=====player race total: "..playerraceoverpoints.."=====",5,93,player.col)
	print("=====cpu race total: "..cpuraceoverpoints.."=====",5,103,cpu.col)
	print("press ❎ for next race!",5,113,4)
end

function draw_start()
	cls()
	spr(64,36,10,7,3)
--	print("by chuck",40,50,3)
	print("cpu difficulty: "..diffchoices[difficulty].." ⬆️ ⬇️ ",10,60,7)
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
		print("❎",14+(10*(playercardptr-1)),30,player.col)
	else
		print("❎",14+(10*(playercardptr-1)),30,0)
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
			if player.safeties[i].iscf then
				pal(12,7)
				pal(15,9)
			end
			spr(player.safeties[i].sprite,playerbox.x+88+(10*(i-1)),playerbox.y+2)
			pal()
			palt(14,true)
			palt(0,false)
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
		if cpu.safeties[i].iscf then
			pal(12,7)
			pal(15,9)
		end		
		spr(cpu.safeties[i].sprite,cpubox.x+88+(10*(i-1)),cpubox.y+2)
		pal()
		palt(14,true)
		palt(0,false)
	end
	pal()
	palt(14,true)
	palt(0,false)

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
	multidraw = false
	safetyplay = 0
	hurtplay = 0
	helpplay = 0
	deck=shuffledeck()
	debug=""
	cpudebug=""
	racewinner=""
	raceover=false
	playerraceoverpoints=0
	cpuraceoverpoints=0
	curgoal=stdgoal
	calledext="nobody"
	cancf = false
	iscf = false
	cancfcard = nil
	winname = ""
	winscore = 0
	winsft = 0
	wincfs = 0
	winall4 = 0
	winpts = 0
	winshut = 0
	windelay = 0
	winsafe = 0
	winext = 0
	wincol = 7
end

function draw_up(_curplayer)
	card = deck[1]
	if card != nil then
		card.x = (#_curplayer.hand + 1) * 10 + 4
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
		cancf = checkforcf(_opponent.hand,_card)
		_opponent.upcard = clonecard(_card)
	elseif _card.type == "l" then
		cancf = checkforcf(_opponent.hand,_card)
		_opponent.limit = true
	elseif _card.type == "n" then
		_player.upcard = clonecard(_card)
		-- add value to player's score
		_player.score += _player.upcard.value
		if _card.value == 200 then
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
		-- same player goes again!
		multidraw = true
	elseif _card.type == "v" then
		_player.limit = false
	elseif _card.type == "g" or _card.type == "r" then
		_player.upcard = clonecard(_card)
	end
	del(_player.hand,_card)
	recalculatehandpos(_player)
end

function playcoupfourre(_player,_opponent)
	-- possible race condition where
	-- the played card gets to its
	-- destination as coup fourre
	-- is being played, so check for nil
	-- before doing anything
	if playedcard != nil then
		card = nil
		for i=1,#_player.hand do
			if _player.hand[i].name == playedcard.safety then
				card = _player.hand[i]
			end
		end
		playedcard = nil
		_player.upcard = _player.prevupcard
		_player.prevupcard = nil
		card.iscf = true
		add(_player.safeties,clonecard(card))
		del(_player.hand,card)
		recalculatehandpos(_player)
		_player.cfs += 1
		if card.name == "emergency" then
			_player.limit = false
		end
	end
end

function checkforcf(_hand,_card)
	for i=1,#_hand do
		if _hand[i].name == _card.safety then
			cancfcard = _hand[i]
			return true
		end
	end

	return false
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
	winname = ""
	winscore = 0
	winsft = 0
	wincfs = 0
	winall4 = 0
	winpts = 0
	winshut = 0
	windelay = 0
	winsafe = 0
	winext = 0

	playerraceoverpoints += player.score
	playerraceoverpoints += #(player.safeties) * 100
	playerraceoverpoints += player.cfs * 300
	if #(player.safeties) == 4 then
		playerraceoverpoints += 400
	end
	cpuraceoverpoints += cpu.score
	cpuraceoverpoints += #(cpu.safeties) * 100
	cpuraceoverpoints += cpu.cfs * 300
	if #(cpu.safeties) == 4 then
		cpuraceoverpoints += 400
	end
	if winner.name == "player" then
		winname = "player"
		wincol = player.col
		winscore = player.score
		winsft = #(player.safeties) * 100
		wincfs = player.cfs * 300
		if #(player.safeties) == 4 then
			winall4 = 400
		end

		-- race winner gets 400 points
		playerraceoverpoints += 400
		winpts = 400
	
		if loser.score == 0 then
			-- shutout, 500 points
			playerraceoverpoints += 500
			winshut = 500
		end

		if #deck == 0 then
			-- delayed action, 300 points
			playerraceoverpoints += 300
			windelay = 300
		end
	
		if winner.num200s == 0 then
			-- safe trip, 300 points
			playerraceoverpoints += 300
			winsafe = 300
		end
		
		if curgoal == extgoal then
			-- extension, 200 points
			playerraceoverpoints += 200
			winext = 200
		end
	elseif winner.name == "cpu" then
		winname = "cpu"
		wincol = cpu.col
		winscore = cpu.score
		winsft = #(cpu.safeties) * 100
		wincfs = cpu.cfs * 300
		if #(cpu.safeties) == 4 then
			winall4 = 400
		end

		-- race winner gets 400 points
		cpuraceoverpoints += 400
		winpts = 400
	
		if loser.score == 0 then
			-- shutout, 500 points
			cpuraceoverpoints += 500
			winshut = 500
		end

		if #deck == 0 then
			-- delayed action, 300 points
			cpuraceoverpoints += 300
			windelay = 300
		end
	
		if winner.num200s == 0 then
			-- safe trip, 300 points
			cpuraceoverpoints += 300
			winsafe = 300
		end
		
		if curgoal == extgoal then
			-- extension, 200 points
			cpuraceoverpoints += 200
			winext = 200
		end
	elseif winner.name == "draw" then
		-- if we end in a draw during an extension,
		-- the non-calling player steals the bonus
		wincol = 7
		winname = "draw"
		if calledext == "player" then
			cpuraceoverpoints += 200
		elseif calledext == "cpu" then
			playerraceoverpoints += 200
		end
	end
	
	return winner.name
end

function clonecard(_card)
	return {type=_card.type,value=_card.value,belowlimit=_card.belowlimit,name=_card.name,remedy=_card.remedy,safety=_card.safety,sprite=_card.sprite,x=_card.x,y=_card.y,fx=_card.fx,iscf=_card.iscf}
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
ccccccccbbbbbbbbbbbbbbbbbbbbbbbb111111118888888807070707000000000000000000000000000000000000000000000000000000000000000000000000
cffffffcb777777bb777777bb777777b129292918778777870707070000000000000000000000000000000000000000000000000000000000000000000000000
cffffffcb777707bb776767bb770077b192929218788787807070707000000000000000000000000000000000000000000000000000000000000000000000000
cf8811fcb777077bb776667bb706607b129292918778787870707070000000000000000000000000000000000000000000000000000000000000000000000000
cf8811fcb788877bb777677bb706607b192929218878787807070707000000000000000000000000000000000000000000000000000000000000000000000000
c000000cb788877bb777677bb770077b129292918778777870707070000000000000000000000000000000000000000000000000000000000000000000000000
cffffffcb788877bb777677bb777777b192929218888888807070707000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccbbbbbbbbbbbbbbbbbbbbbbbb111111118888888870707070000000000000000000000000000000000000000000000000000000000000000000000000
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
0001000007550095500b5502000000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0005000007750087500c75010750147501b750257502c750007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0005000029250242501e25017250142501a2502425000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000026650206501a6501363005630056200562004610046100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000c55009550065500365002650006500065000650006300063000620006200061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002000002c0502c0102c0102c0002c0502c0102c0102c0002c0502c0102c0102c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002c5502a5502855026550235501f5501b550175501f5000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0010000016550185501b5501e550205502255024550265501f5000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
001800002425024250182501825024250242501825018250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
