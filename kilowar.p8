pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--init functions

--TODO:
---- 3. music for start screen
---- 4. remove cheat
---- 4. ship it!

function _init()
	deck = shuffledeck()
	playerbox = {x=0,y=86,xe=128,ye=96,col=3}
	cpubox = {x=0,y=115,xe=128,ye=125,col=4}
	playerptrbox = {x=10,y=30,xe=80,ye=40,col=0}
	player = {name="player",col=3,hand={},score=0,total=0,cfs=0,num200s=0,limit=false,upcard=nil,prevupcard=nil,safeties={},cardy=20,box=playerbox,carx=1,cary=90,cardx=0}
	cpu = {name="cpu",col=4,hand={},score=0,total=0,cfs=0,num200s=0,limit=false,upcard=nil,prevupcard=nil,safeties={},cardy=60,box=cpubox,carx=1,cary=99,cardx=0}
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
	carspeed = 0.5
	cardestx = -1
	mode = "start"
	romode = ""
	playercardptr = 1
	deckx = 98
	decky = 78
	limitx = 94
	cardtargetx = -1
	cardtargety = -1
	
	racewinner = ""
	matchwinner = ""
	raceover = false
	matchover = false
	
	-- normal difficulty is default
	difficulty = 2
	diffchoices = {"easy","normal","hard"}
	cffloors = {40,25,5}
	
	playerraceoverpoints = 0
	cpuraceoverpoints = 0
	raceovertc = 7
	raceoverblinktimer = 1
	bordertimer = 0
	borderspr = 22
	flagx = 96

	-- debugging
	debug = ""
	
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
	
	losename = ""
	losescore = 0
	losesft = 0
	losecfs = 0
	loseall4 = 0
	losepts = 0
	loseshut = 0
	losedelay = 0
	losesafe = 0
	loseext = 0
	losecol = 7

	cheat = false
	palt(14,true)
	palt(0,false)
	
	-- coup fourre banner
	sash_w=0
	sash_dw=0
	sash_tx=0
	sash_tdx=0
	sash_c=8
	sash_tc=7
	sash_frames=0
	sash_v=false
	sash_delay_w=0
	sash_delay_t=0
	
	-- graphical juice!
	pcx = -200
	ccx = -200
	pdx = 0.1
	cdx = 0.1
	cfblinktimer=1
	cfblinktimercols={7,7,7,7,10,10,10,10,11,11,11,11}
	cfon=true
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
			add(_d,{type="n",value=25,belowlimit=true,name="25",remedy="",safety="",sprite=1,x=-1,y=-1,fx=11,iscf=false})
			add(_d,{type="n",value=50,belowlimit=true,name="50",remedy="",safety="",sprite=2,x=-1,y=-1,fx=12,iscf=false})
			add(_d,{type="n",value=75,belowlimit=false,name="75",remedy="",safety="",sprite=3,x=-1,y=-1,fx=13,iscf=false})
		end
		if i <= 12 then
			add(_d,{type="n",value=100,belowlimit=false,name="100",remedy="",safety="",sprite=4,x=-1,y=-1,fx=14,iscf=false})
		end

		if i <=4 then
			add(_d,{type="n",value=200,belowlimit=false,name="200",remedy="",safety="",sprite=5,x=-1,y=-1,fx=15,iscf=false})
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
			add(_d,{type="l",value=0,belowlimit=false,name="limit 50",remedy="nolimit",safety="emergency",sprite=12,x=-1,y=-1,fx=16,iscf=false})
		end
		-- add remedies + remove limits
		if i <= 6 then
			add(_d,{type="v",value=0,belowlimit=false,name="nolimit",remedy="",safety="emergency",sprite=11,x=-1,y=-1,fx=17,iscf=false})
			add(_d,{type="r",value=0,belowlimit=false,name="gascan",remedy="",safety="",sprite=17,x=-1,y=-1,fx=1,iscf=false})
			add(_d,{type="r",value=0,belowlimit=false,name="repair",remedy="",safety="",sprite=18,x=-1,y=-1,fx=1,iscf=false})
			add(_d,{type="r",value=0,belowlimit=false,name="spare",remedy="",safety="",sprite=19,x=-1,y=-1,fx=1,iscf=false})
		end
		-- add safeties
		if i == 1 then
			add(_d,{type="f",value=0,belowlimit=false,name="ppt",remedy="",safety="",sprite=13,x=-1,y=-1,fx=18,iscf=false})
			add(_d,{type="f",value=0,belowlimit=false,name="tanker",remedy="",safety="",sprite=14,x=-1,y=-1,fx=18,iscf=false})
			add(_d,{type="f",value=0,belowlimit=false,name="ace",remedy="",safety="",sprite=15,x=-1,y=-1,fx=18,iscf=false})
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
	elseif mode == "rules" then
		update_rules()
	else
		update_sash()
		update_game()
	end
end

function update_rules()
	if btnp(4) then
		mode = "start"
	end
end

function update_start()
	raceovertc = cfblinktimercols[raceoverblinktimer]
	raceoverblinktimer += 1
	if raceoverblinktimer % 12 == 0 then
		raceoverblinktimer = 1
	end
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
	if btnp(4) then
		mode = "rules"
	end
	if btnp(5) then
		mode = "game"
	end
end

function update_raceover()
	raceovertc = cfblinktimercols[raceoverblinktimer]
	borderspr = 22 + flr(bordertimer / 30)
	if bordertimer % 20 == 0 then
		if flagx == 96 then
			flagx = 112
		else
			flagx = 96
		end
	end
	raceoverblinktimer += 1
	if raceoverblinktimer % 12 == 0 then
		raceoverblinktimer = 1
	end
	bordertimer += 1
	if bordertimer > 59 then
		bordertimer = 0
	end
	if btnp(0) then
		romode = "winner"
	end
	if btnp(1) then
		romode = "loser"
	end
	if btnp(5) then
		newrace()
		mode = "game"
	end
end

function update_matchover()
	raceovertc = cfblinktimercols[raceoverblinktimer]
	borderspr = 22 + flr(bordertimer / 30)
	if bordertimer % 20 == 0 then
		if flagx == 96 then
			flagx = 112
		else
			flagx = 96
		end
	end
	raceoverblinktimer += 1
	if raceoverblinktimer % 12 == 0 then
		raceoverblinktimer = 1
	end
	bordertimer += 1
	if bordertimer > 59 then
		bordertimer = 0
	end
	if btnp(5) then
		newmatch()
		music(-1,500)
		mode = "game"
	end
	if btnp(4) then
		newmatch()
		music(-1,500)
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
		if matchwinner == "cpu" then
			sfx(25)
		else
			music(0)
		end
	elseif raceover then
		mode = "raceover"
		if racewinner == "cpu" then
			sfx(25)
		elseif racewinner == "player" then
			music(5)
		end
	elseif #racewinner > 0 then
		if curgoal == stdgoal then
			if racewinner == "player" then
				debug = "⬆️ = extend ⬇️ = end"
				if btnp(2) then
					curgoal = extgoal
					player.carx = player.score * 0.112
					cpu.carx = cpu.score * 0.112
					debug = "player extends to 1000!"
					calledext = "player"
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
					extdraw = flr(rnd(100))+1
					if extdraw > 50 then
						curgoal = extgoal
						player.carx = player.score * 0.112
						cpu.carx = cpu.score * 0.112
						debug = "cpu extends to 1000!"
						calledext = "cpu"
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
						player.carx = player.score * 0.112
						cpu.carx = cpu.score * 0.112
						calledext = "cpu"
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
				if flr(rnd(100))+1 > cffloors[difficulty] then
					playcoupfourre(cpu,player)
					playinprogress = false
					turninprogress = false
					cancf = false
					iscf = true
					sfx(-1)
					sfx(10)
					showsash("coupe fourre!",cpu.col,7)
				end
			else
				-- player can coup fourre
				if btnp(2) then
					playcoupfourre(player,cpu)
					playinprogress = false
					turninprogress = false
					cancf = false
					iscf = true
					sfx(-1)
					sfx(10)
					showsash("coupe fourre!",player.col,7)
				end
			end
		end
	
		if not turninprogress and not drawupinprogress then
			playinprogress = false
			cancf = false
			if not multidraw then
				if currentplayer.name==player.name then
					currentplayer = cpu
				else
					currentplayer = player
				end
			end
			draw_up(currentplayer)
			if currentplayer.name==player.name and player.hand[playercardptr].y == player.cardy then
				player.hand[playercardptr].x -= 1
				player.hand[playercardptr].y -= 2
			end
			if iscf then
				multidraw = true
			else
				multidraw = false
			end
			iscf = false
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
					if not multidraw then
						turninprogress = true
					end
					drawupinprogress = false
				end
			else
--				drawncard = nil
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
			-- animate the current players car if needed
			if currentplayer.cardx > 0 and currentplayer.carx < cardestx then
				currentplayer.carx += currentplayer.cardx
				if currentplayer.carx >= cardestx then
					currentplayer.carx = cardestx
					currentplayer.cardx = 0
					cardestx = -1
				end
			end
			if playedcard.dx == 0 and playedcard.dy == 0 and currentplayer.cardx == 0 then
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
					player.hand[playercardptr].x += 1
					player.hand[playercardptr].y += 2
					playercardptr += 1
					if playercardptr > #(player.hand) then
						playercardptr = 1
					end
					player.hand[playercardptr].x -= 1
					player.hand[playercardptr].y -= 2
					debug=""
					sfx(0)
				elseif btnp(0) then
					player.hand[playercardptr].x += 1
					player.hand[playercardptr].y += 2
					playercardptr -= 1
					if playercardptr == 0 then
						playercardptr = #(player.hand)
					end
					player.hand[playercardptr].x -= 1
					player.hand[playercardptr].y -= 2
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
						sfx(playedcard.fx)
						playinprogress = true
					else
						if debug == "" then
							debug = "invalid play: " .. player.hand[playercardptr].name
						end
					end
				elseif btnp(4) then
					if player.hand[playercardptr].type == "f" then
						debug = "don't discard that!"
					else
						discard(player,player.hand[playercardptr])
						if playercardptr > #(player.hand) then
							playercardptr-=1
						end
						sfx(2)
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
								playedcard = cpu.hand[i]
								player.prevupcard = player.upcard
								cpu.prevupcard = cpu.upcard
								playcard(cpu,player,cpu.hand[i])
								animatecard(playedcard,cpu,player)
								sfx(playedcard.fx)
								safetyplay = 0
								hurtplay = 0
								helpplay = 0
								playinprogress = true
								debug=""
								return
							end
						end
					end

					if hurtplay > 0 then
						-- give easy cpu a 50% chance of playing a harm card
						if flr(rnd(100))+1 > 50 then
							playedcard = cpu.hand[hurtplay]
							player.prevupcard = player.upcard
							cpu.prevupcard = cpu.upcard
							playcard(cpu,player,cpu.hand[hurtplay])
							animatecard(playedcard,cpu,player)
							sfx(playedcard.fx)
							safetyplay = 0
							hurtplay = 0
							helpplay = 0
							playinprogress = true
							debug=""
							return
						end
					end
					
					-- we'll favor discarding over playing a safety
					-- for the first half of the deck unless the upcard
					-- is the matching hazard
					-- otherwise save them for coup fourre!
					if safetyplay > 0 and ((cpu.upcard != nil and cpu.upcard.safety == cpu.hand[safetyplay].name) or #deck < 53) then
						playedcard = cpu.hand[safetyplay]
						player.prevupcard = player.upcard
						cpu.prevupcard = cpu.upcard
						playcard(cpu,player,cpu.hand[safetyplay])
						animatecard(playedcard,cpu,player)
						sfx(playedcard.fx)
						safetyplay = 0
						playinprogress = true
					else
						-- cpu is unable to play, needs to discard
						if #cpu.hand > 0 then
							for i=1,#(cpu.hand) do
								if cpu.hand[i].type != "f" or #cpu.hand < 5 then
									discard(cpu,cpu.hand[i])
									break
								end
							end
							sfx(2)
							discardinprogress = true
						end
					end
					debug=""
				elseif difficulty == 2 then
					---- 2 = normal (plays first playable card)
					for i=1,#(cpu.hand) do
						if checkvalidplay(cpu,player,cpu.hand[i]) then
							if cpu.hand[i].type == "f" and ((player.score < 600 and curgoal == stdgoal) or (player.score < 900 and curgoal == extgoal) or #deck == 0) then
								safetyplay = i
							else
								playedcard = cpu.hand[i]
								player.prevupcard = player.upcard
								cpu.prevupcard = cpu.upcard
								playcard(cpu,player,cpu.hand[i])
								animatecard(playedcard,cpu,player)
								sfx(playedcard.fx)
								safetyplay = 0
								playinprogress = true
								debug=""
								return
							end
						end
					end
				
					-- we'll favor discarding over playing a safety
					-- for the first half of the deck unless the upcard
					-- is the matching hazard
					-- otherwise save them for coup fourre!
					if safetyplay > 0 and ((cpu.upcard != nil and cpu.upcard.safety == cpu.hand[safetyplay].name) or #deck < 53) then
						playedcard = cpu.hand[safetyplay]
						player.prevupcard = player.upcard
						cpu.prevupcard = cpu.upcard
						playcard(cpu,player,cpu.hand[safetyplay])
						animatecard(playedcard,cpu,player)
						sfx(playedcard.fx)
						safetyplay = 0
						playinprogress = true
					else
						-- cpu is unable to play, needs to discard
						if #cpu.hand > 0 then
							for i=1,#(cpu.hand) do
								if cpu.hand[i].type != "f" or #cpu.hand < 5 then
									discard(cpu,cpu.hand[i])
									break
								end
							end
							sfx(2)
							discardinprogress = true
						end
					end
					debug=""
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
								playedcard = cpu.hand[i]
								player.prevupcard = player.upcard
								cpu.prevupcard = cpu.upcard
								playcard(cpu,player,cpu.hand[i])
								animatecard(playedcard,cpu,player)
								sfx(playedcard.fx)
								safetyplay = 0
								hurtplay = 0
								helpplay = 0
								playinprogress = true
								debug=""
								return
							end
						end
					end

					if helpplay > 0 then
						playedcard = cpu.hand[helpplay]
						player.prevupcard = player.upcard
						cpu.prevupcard = cpu.upcard
						playcard(cpu,player,cpu.hand[helpplay])
						animatecard(playedcard,cpu,player)
						sfx(playedcard.fx)
						safetyplay = 0
						hurtplay = 0
						helpplay = 0
						playinprogress = true
						debug=""
						return
					end
					
					-- we'll favor discarding over playing a safety
					-- for the first 75% of the deck unless the upcard
					-- is the matching hazard
					-- otherwise save them for coup fourre!
					if safetyplay > 0 and ((cpu.upcard != nil and cpu.upcard.safety == cpu.hand[safetyplay].name) or #deck < 27) then
						playedcard = cpu.hand[safetyplay]
						player.prevupcard = player.upcard
						cpu.prevupcard = cpu.upcard
						playcard(cpu,player,cpu.hand[safetyplay])
						animatecard(playedcard,cpu,player)
						sfx(playedcard.fx)
						safetyplay = 0
						playinprogress = true
					else
						-- cpu is unable to play, needs to discard
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
							sfx(2)
							if todiscard > 0 then
								discard(cpu,cpu.hand[todiscard])
							else
								discard(cpu,cpu.hand[1])
							end
							discardinprogress = true
						end
					end
					debug=""
				end
			end
		end
	end
end

function update_sash()
	if sash_v then
		sash_frames+=1
		--animate width
		if sash_delay_w>0 then
			sash_delay_w-=1 
		else
			sash_w+=(sash_dw-sash_w)/5
			if abs(sash_dw-sash_w)<0.3 then
				sash_w=sash_dw
			end
		end
		--animate text
		if sash_delay_t>0 then
			sash_delay_t-=1
		else 
			sash_tx+=(sash_tdx-sash_tx)/10
			if abs(sash_tx-sash_tdx)<0.3 then
				sash_tx=sash_tdx
			end
		end
		--make sash go away
		if sash_frames==75 then
			sash_dw=0
			sash_tdx=160
			sash_delay_w=15
			sash_delay_t=0
		end
		if sash_frames>115 then
			sash_v=false
		end
		sash_tc = cfblinktimercols[cfblinktimer]
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
	 elseif mode == "rules" then
 		draw_rules()
	else
		draw_game()
	end
end

function draw_rules()
	cls()
	print("race:700/1000 extend. match:5000",1,1,10)
	-- nums
	spr(1,12,8)
	spr(2,28,8)
	spr(3,43,8)
	spr(4,58,8)
	spr(5,73,8)
	spr(6,89,8)	
	spr(7,103,8)
	print("25",12,18,7)
	print("50",28,18,7)
	print("75",43,18,7)
	print("100",56,18,7)
	print("200",71,18,7)
	print("go",88,18,7)	
	print("stop",100,18,7)
	print("**max two 200s per race**",13,26,10)
	-- remedies
	spr(17,1,36)
	print("fix",12,36,7)
	spr(10,26,36)
	spr(18,46,36)
	print("fix",57,36,7)
	spr(9,71,36)
	spr(19,91,36)
	print("fix",102,36,7)
	spr(8,116,36)
	--safeties
	spr(14,0,44)
	print("prev",11,44,7)
	spr(10,28,44)
	spr(15,45,44)
	print("prev",56,44,7)
	spr(9,73,44)
	spr(13,90,44)
	print("prev",101,44,7)
	spr(8,118,44)
	-- coup fourre
	print("⬆️ when attacked = coup fourre!",0,54,10)
	pal(12,7)
	pal(15,9)
	spr(14,36,62)	
	spr(15,56,62)	
	spr(13,76,62)	
	pal()
	-- limits
	spr(12,21,75)
	print("sets",32,75,7)
	spr(21,49,75)
	spr(11,64,75)
	print("clears",75,75,7)
	spr(21,100,75)
	-- emergency
	spr(16,47,88)
	pal(12,7)
	pal(15,9)
	spr(16,67,88)
	pal()
	palt(14,true)
	palt(0,false)
	print("fixes/prevs stop + speed limit",3,98,10)
	print("❎=play card",3,106,player.col)
	print("🅾️=discard",83,106,cpu.col)
	print("🅾️: return to start screen",10,122,7)
end

function draw_matchover()
	cls()
	spr(borderspr,0,0)
	for i=1,15 do
		spr(borderspr,i*8,0)
		spr(borderspr,0,i*8)
		spr(borderspr,120,i*8)
		spr(borderspr,i*8,120)
	end
	print("***** "..matchwinner.." wins! *****",23 - #matchwinner,14,raceovertc)
	print("final scores",41,30,7)
	sspr(flagx,64,16,16,95,40)
	sspr(flagx,64,16,16,15,40)
	if matchwinner == "player" then
		print("player: "..player.total,41,40,player.col)
		print("cpu: "..cpu.total,41,48,cpu.col)
	else
		print("cpu: "..cpu.total,41,40,cpu.col)
		print("player: "..player.total,41,48,player.col)
	end
	print("press ❎ to start",30,63,raceovertc)
	print("a new match!",40,71,raceovertc)
	print("press 🅾️ to",43,91,7)
	print("restart kilowar!",33,99,7)
end

function draw_raceover()
	cls()
	spr(borderspr,0,0)
	for i=1,15 do
		spr(borderspr,i*8,0)
		spr(borderspr,0,i*8)
		spr(borderspr,120,i*8)
		spr(borderspr,i*8,120)
	end
	if winname != "draw" then
		if romode == "" then
			romode = "winner"
		end
		print(winname.." wins!",12,9,raceovertc)
		print(losename.." loses.",62,9,losecol)
		if romode == "winner" then
			sspr(flagx,64,16,16,95,17)
			print("kilos: "..winscore,12,17,wincol)
			print("win bonus: "..winpts,12,25,wincol)
			print("safeties: "..winsft,12,33,wincol)
			print("coup fourre: "..wincfs,12,41,wincol)
			print("all 4 safeties: "..winall4,12,49,wincol)
			print("shutout: "..winshut,12,57,wincol)
			print("delayed win: "..windelay,12,65,wincol)
			print("safe trip: "..winsafe,12,73,wincol)
			print("extension: "..winext,12,81,wincol)
			if winname == "player" then
				print("race total: "..playerraceoverpoints,12,89,wincol)
				print("match total: "..player.total,12,97,wincol)
			else
				print("race total: "..cpuraceoverpoints,12,89,wincol)
				print("match total: "..cpu.total,12,97,wincol)
			end
		else
			print("kilos: "..losescore,12,17,losecol)
			print("safeties: "..losesft,12,25,losecol)
			print("coup fourre: "..losecfs,12,33,losecol)
			print("all 4 safeties: "..loseall4,12,41,losecol)
			if winname == "player" then
				print("race total: "..cpuraceoverpoints,12,49,losecol)
				print("match total: "..cpu.total,12,57,losecol)
			else
				print("race total: "..playerraceoverpoints,12,49,losecol)
				print("match total: "..player.total,12,57,losecol)
			end
		end
		print("⬅️: winner ➡️: loser",12,105)
	else
		print("nobody won",12,9,6)
		print("player: "..playerraceoverpoints.." cpu: "..cpuraceoverpoints,12,17,6)
		print("player kilos: "..player.score,12,25,player.col)
		print("cpu kilos: "..cpu.score,12,33,cpu.col)
		print("player safeties: "..#(player.safeties)*100,12,41,player.col)
		print("cpu safeties: "..#(cpu.safeties)*100,12,49,cpu.col)
		print("player coup fourre: "..player.cfs*300,12,57,player.col)
		print("cpu coup fourre: "..cpu.cfs*300,12,65,cpu.col)
		print("player all safeties: "..tostr(400 * flr(#player.safeties / 4)),12,73,player.col)
		print("cpu all safeties: "..tostr(400 * flr(#cpu.safeties / 4)),12,81,cpu.col)
		if calledext == "cpu" then
			print("player extension stop: 200",12,89,player.col)
		else
			print("player extension stop: 0",12,89,player.col)
		end
		if calledext == "player" then
			print("cpu extension stop: 200",12,97,cpu.col)
		else
			print("cpu extension stop: 0",12,97,cpu.col)
		end
	end
--	print("=====player race total: "..playerraceoverpoints.."=====",5,95,player.col)
--	print("=====cpu race total: "..cpuraceoverpoints.."=====",5,105,cpu.col)
	print("press ❎ for next race!",12,113,raceovertc)
end

function draw_start()
	cls()
	if pcx == -200 then
		pcx = flr(rnd(10)) - 64
	end
	if ccx == -200 then
		ccx = flr(rnd(10)) - 64
	end
	spr(64,36,10,7,3)
	print("by",60,27,7)
	print("2bit",36,35,3)
	print("chuck",72,35,4)
	sspr(128,64,32,32,0,50,128,32)
	spr(72,pcx,30,4,4)
	spr(76,ccx,50,4,4)
	spr(133,pcx-15,40,4,4)
	spr(133,ccx-15,60,4,4)
	pcx += pdx
	ccx += cdx
	pdx += rnd(0.11)
	cdx += rnd(0.11)
--	if pcx > 75 and pcx < 80 then
--		sfx(9)
--	end
--	if ccx > 75 and ccx < 80 then
--		sfx(9)
--	end
	if pcx >= 150 then
		pcx = -200
		pdx = 0.1
	end
	if ccx >= 150 then
		ccx = -200
		cdx = 0.1
	end
	print("cpu difficulty: "..diffchoices[difficulty].." ⬆️ ⬇️ ",10,85,7)
	print("press ❎ to start",32,105,raceovertc)
	print("press 🅾️ for rules",32,115,7)
end

function draw_game()
	cls()
	print("player: "..player.score.." (match total: "..player.total..")",5,5,player.col)
	if cancf and currentplayer.name == "cpu" and cfon then
		print("⬆️ cf ⬆️",40,decky,cfblinktimercols[cfblinktimer])
	end
	cfblinktimer += 1
	if cfblinktimer % 12 == 0 then
		cfon = not cfon
		cfblinktimer = 1
	end
	print("cpu:    "..cpu.score.." (match total: "..cpu.total..")",5,45,cpu.col)
	rectfill(playerbox.x,playerbox.y,playerbox.xe,playerbox.ye,playerbox.col)
	rectfill(playerptrbox.x,playerptrbox.y,playerptrbox.xe,playerptrbox.ye,playerptrbox.col)
	rectfill(cpubox.x,cpubox.y,cpubox.xe,cpubox.ye,cpubox.col)
	sspr(80,64,16,16,0,98,128,16)
	spr(24,120,98)
	spr(24,120,106)
	sspr(80,80,16,16,player.carx, player.cary)
	sspr(96,80,16,16,cpu.carx, cpu.cary)

	if currentplayer.name == player.name then
		print("❎",14+(10*(playercardptr-1)),30,player.col)
	else
		print("❎",14+(10*(playercardptr-1)),30,0)
	end
	spr(20,deckx,decky)
	print("="..#deck,109,80,10)
	if playedcard != nil then
		vlu = playedcard.value
	else
		vlu = 0
	end

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
	draw_sash()
end

function draw_sash()
	if sash_v then
		rectfill(0,64-sash_w,128,64+sash_w,sash_c)
		print(sash_text,sash_tx,62,sash_tc)
	end
end

-->8
-- utility functions
function showsash(_t,_c,_tc)
	sash_w=0
	sash_dw=4
	sash_c=_c
	sash_text=_t
	sash_frames=0
	sash_v=true
	sash_tx=-#sash_text*4
	sash_tdx=64-(#sash_text*2)
	sash_delay_w=0
	sash_delay_t=5
	sash_tc=_tc
end

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
	player.carx=1
	cpu.carx=1
	player.cardx=0
	cpu.cardx=0
	cardestx=-1
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
	racewinner=""
	raceover=false
	romode=""
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
	sash_w=0
	sash_dw=0
	sash_tx=0
	sash_tdx=0
	sash_c=8
	sash_tc=7
	sash_frames=0
	sash_v=false
	sash_delay_w=0
	sash_delay_t=0
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
		if _card.type == "n" then
			animatecar(_cardplayer,_card.value)
		end
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

function animatecar(_player,_value)
	if curgoal == stdgoal then
		movefactor = 0.16
	else
		movefactor = 0.112
	end
	
	cardestx = _player.carx + (_value * movefactor)
	if cardestx + 1 > 112 then
		cardestx = 128
	end
	_player.cardx = carspeed
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
 			debug = "max two 200s per race!"
 			return false
 		end
 		if _card.value + _player.score > curgoal then
 			-- you have to hit the race goal exactly
 			debug = "must reach goal exactly!"
 			return false
 		end
 		if hassafety(_player,"emergency") and (_player.upcard == nil or _player.upcard.type != "h") then
 			return true
 		end
 		if _player.upcard ~= nil then
 			if _player.upcard.type == "g" or _player.upcard.type == "n" then
 				if not _player.limit or (_player.limit and _card.value <= 50) then
 					return true
 				else
 					debug = "can't exceed speed limit!"
 				end
 			elseif hassafety(_player,"emergency") and (_player.upcard.type == "r" or _player.upcard.type == "f") then
 				return true
 			elseif _player.upcard.type == "h" or _player.upcard.type == "s" or ((_player.upcard.type == "r" or _player.upcard.type == "f") and not hassafety(_player,"emergency")) then
 				debug = "you're still stopped!"
 			end
 		else
 			debug = "you need a green light!"
 		end
	elseif _card.type == "g" then
 		-- g = go
 		if not hassafety(_player, "emergency") and (_player.upcard == nil or _player.upcard.type == "s" or _player.upcard.type == "r" or _player.upcard.type == "f") then
 			return true
 		elseif _player.upcard.type == "h" then
 			debug = "fix your hazard first!"
 		elseif hassafety(_player,"emergency") or (_player.upcard != nil and (_player.upcard.type == "g" or _player.upcard.type == "n")) then
 			debug = "you're not stopped!"
 		end
	elseif _card.type == "s" then
	 	-- s = stop
	 	if hassafety(_opponent,_card.safety) then
	 		debug = "opponent is immune!"
	 	elseif _opponent.upcard ~= nil and (_opponent.upcard.type=="g" or _opponent.upcard.type=="n") then
	 		 return true
	 	else 
	 		debug = "opponent is already stopped!"
	 	end
	elseif _card.type == "h" then
 		-- h = hazard
 		if hassafety(_opponent,_card.safety) then
	 		debug = "opponent is immune!"
	 	elseif _opponent.upcard ~= nil and (_opponent.upcard.type=="g" or _opponent.upcard.type=="n" or ((_opponent.upcard.type=="f" or _opponent.upcard.type=="r") and hassafety(_opponent,"emergency"))) then
	 		return true
	 	elseif _opponent.upcard == nil and hassafety(_opponent,"emergency") then
	 		return true
	 	else
	 		debug = "opponent is already stopped!"
	 	end
	elseif _card.type == "r" then
 		-- r = remedy
 		if _player.upcard ~= nil and _player.upcard.type == "h" and _player.upcard.remedy == _card.name then
 			return true
 		else
 			debug = "this fix not needed!"
 		end
	elseif _card.type == "l" then
 		-- l = speed limit
 		if hassafety(_opponent,_card.safety) then
	 		debug = "opponent is immune!"
	 	elseif _opponent.limit then
	 		debug = "already speed limited!"
	 	else
	 		return true
	 	end
	elseif _card.type == "v" then
 		-- v = remove limit
 		if not hassafety(_player,"emergency") and _player.limit then
 			return true
 		else
 			debug = "not under speed limit!"
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

	losename = ""
	losescore = 0
	losesft = 0
	losecfs = 0
	loseall4 = 0
	losepts = 0
	loseshut = 0
	losedelay = 0
	losesafe = 0
	loseext = 0
	losecol = 7

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
		losename = "cpu"
		wincol = player.col
		losecol = cpu.col
		winscore = player.score
		losescore = cpu.score
		winsft = #(player.safeties) * 100
		losesft = #(cpu.safeties) * 100
		wincfs = player.cfs * 300
		losecfs = cpu.cfs * 300
		if #(player.safeties) == 4 then
			winall4 = 400
		end
		if #(cpu.safeties) == 4 then
			loseall4 = 400
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
		losename = "player"
		wincol = cpu.col
		losecol = player.col
		winscore = cpu.score
		losescore = player.score
		winsft = #(cpu.safeties) * 100
		losesft = #(player.safeties) * 100
		wincfs = cpu.cfs * 300
		losecfs = player.cfs * 300
		if #(cpu.safeties) == 4 then
			winall4 = 400
		end
		if #(player.safeties) == 4 then
			loseall4 = 400
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
ccccccccbbbbbbbbbbbbbbbbbbbbbbbb11111111888888880077007777007700eeee070700000000000000000000000000000000000000000000000000000000
cffffffcb777777bb777777bb777777b12929291877877780077007777007700eeee707000000000000000000000000000000000000000000000000000000000
cffffffcb777707bb776767bb770077b19292921878878787700770000770077eeee070700000000000000000000000000000000000000000000000000000000
cf8811fcb777077bb776667bb706607b12929291877878787700770000770077eeee707000000000000000000000000000000000000000000000000000000000
cf8811fcb788877bb777677bb706607b19292921887878780077007777007700eeee070700000000000000000000000000000000000000000000000000000000
c000000cb788877bb777677bb770077b12929291877877780077007777007700eeee707000000000000000000000000000000000000000000000000000000000
cffffffcb788877bb777677bb777777b19292921888888887700770000770077eeee070700000000000000000000000000000000000000000000000000000000
ccccccccbbbbbbbbbbbbbbbbbbbbbbbb11111111888888887700770000770077eeee707000000000000000000000000000000000000000000000000000000000
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
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e3333ee3333eeeeeeeeeeeeeeeeeeeee444eeeeeee444eeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e3663ee3bb3eeeeeeeeeeeeeeeeeeeee484ee444ee494eeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e36b3ee3bb3eeeeeeeeeeeeeeeeeeeee484ee484ee494eeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e3bb3e3bbb3eeeeeeeeeeeeeeeeeeeee494e49994e494eeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e3bb33bbb3eeeeeeeeeeeeeeeeeeeeee494e49494e494eeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e3bbbbbb3eeeeeeeeeeeeeeeeeeeeeee4994944494994eeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e3bbbbb3eeee33333e333eeeee333eeee49499999494ee444ee444ee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e3bbbbbb3eee36bb3e363eeee36bb3eee49999999994e48894e4844e00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e3bbbbbbb3ee33b33e3b3eee36333b3ee49994449994e48494e4894e00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e3bb333bbb3ee3b3ee3b3eee3b3b3b3eee499444994ee44944e494ee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e3bb3ee3bb3e33b33e3b333e3b333b3eee4994e4994ee49994e44eee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e3bb3eee3b3e3bbb3e3bbb3ee3bbb3eeeee494e494eee49994e494ee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e3333eee333e33333e33333eee333eeeeee44eee44eee49994e4994e00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeee0000000000000eeeeeeeeeeeeeeeeeee0000000000000eeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeee00333333330ccc0eeeeeeeeeeeeeeeee00444444440ccc0eeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eee003333333330cccc0eeeeeeeeeeeeeee004444444440cccc0eeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eee033333333330ccccc000000000eeeeee044444444440ccccc000000000eee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000ee0033333333330ccccc0333330770eeee0044444444440ccccc0444440770ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000e0033333333333000ccc0333333070eee0044444444444000ccc0444444070ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000e033333333333333000003333333000ee044444444444444000004444444000e
0000000000000000000000000000000000000000000000000000000000000000e0333333333333333333333333333300e0444444444444444444444444444400
0000000000000000000000000000000000000000000000000000000000000000e0333300033333333333300033333330e0444400044444444444400044444440
0000000000000000000000000000000000000000000000000000000000000000e0333006003333333333006003333330e0444006004444444444006004444440
0000000000000000000000000000000000000000000000000000000000000000e0333066603333333333066603333330e0444066604444444444066604444440
0000000000000000000000000000000000000000000000000000000000000000ee00000600e00000000e00600000000eee00000600e00000000e00600000000e
0000000000000000000000000000000000000000000000000000000000000000eeeeee000eeeeeeeeeeee000eeeeeeeeeeeeee000eeeeeeeeeeee000eeeeeeee
0000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000005555555555555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000005555555555555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000005555555555555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000005555555555555555ee0eeeeeeeeeeeeeee0eeeeee6565eee
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000005555555555555555ee0107070eeeeeeeee01070705656eee
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000005555555555555555ee01707006565eeeee01707006565eee
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000005555555555555555ee01070705656eeeee01070705656eee
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000a5aa5aa5aa5aa5aaee01707006565eeeee01707006565eee
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000005555555555555555ee01070705656eeeee01070705656eee
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000005555555555555555ee01707006565eeeee01707006565eee
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000005555555555555555ee01070705656eeeee01070705656eee
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000005555555555555555ee01707006565eeeee0170700eeeeeee
5555555555555555555555555555555500000000eeeeeeeeeee00eeeeeeeeeeeeeeeeeee000000005555555555555555ee01eeeee5656eeeee01eeeeeeeeeeee
5555555555555555555555555555555500000000eeeeeeeeee0660eeeeeeeeeeeeeeeeee000000005555555555555555ee01eeeeeeeeeeeeee01eeeeeeeeeeee
5555555555555555555555555555555500000000eeeeeeeee06666000eeeeeeeeeeeeeee000000005555555555555555ee01eeeeeeeeeeeeee01eeeeeeeeeeee
aaaa55aaaa55aaaa55aaaa55aaaa55aa00000000eeeeeee00666676660eeeeeeeeeeeeee000000005555555555555555ee0eeeeeeeeeeeeeee0eeeeeeeeeeeee
5555555555555555555555555555555500000000eeeeeee067766776760eeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
5555555555555555555555555555555500000000eeeeeeee067600676660eeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
5555555555555555555555555555555500000000eeeeeeeee000ee0666660eeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
5555555555555555555555555555555500000000eeeeeeeeeeeeeee06000eeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
5555555555555555555555555555555500000000eeeeeeeeeeeeeeee0e89eeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeee89e9eeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
5555555555555555555555555555555500000000eeeeeeeeeeeeeeee89e8eeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeee9eeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000ee0000000eeeeeeeee0000000eeeeeee0000000000000000
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000e033330cc0eeeeeee044440cc0eeeeee0000000000000000
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000003333330cc0000ee04444440cc0000ee0000000000000000
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000033333330033370e044444440044470e0000000000000000
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000033033333330330e044044444440440e0000000000000000
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000ee060e000e060eeeee060e000e060eee0000000000000000
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eee0eeeeeee0eeeeeee0eeeeeee0eeee0000000000000000
5555555555555555555555555555555500000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
__sfx__
0001000007550095500b5502000000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0005000007750087500c75010750147501b750257502c750007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0008000017750167501475012750117500f7500d7500c750007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0010000026650206501a6501363005630056200562004610046100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000c55009550065500365002650006500065000650006300063000620006200061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002000002c0502c0102c0102c0002c0502c0102c0102c0002c0002c0002c0002c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002c5502a5502855026550235501f5501b550175501f5000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0010000016550185501b5501e550205502255024550265501f5000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
001800002422024220182201822024220242201822018220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000b7500a7500a7500975007750067500675003750047500475004750037500375003750037500375003750027500275001750007500175000750007500075000750007500070000700007000070000700
000800001255012500145500050016550005001955000500165000050016550005001955019550195501955019550195501955000500005000050000500005000050000500005000050000500005000050000500
001000000015000150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000015000150011500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000015000150011500115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000015000150011500115002150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000015000150011500115002150031500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000642006420054200542005420054200442003420024200142000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
000600000142002420034200442005420054200542005420064200642000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
000800002e7203172034720317202e7202a7202f72032720347200070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
011200003060000000186000000018636000001860000000306000000018600000001863600000186000000030600000001860000000186360000018600000003060000000186000000018636000001860000000
0112000000633006002c6000060000600006002c6000060000633006032c6000060000600006032c6000060000633006032c6000060000600006032c6000060000633006032c6000060000600006032c60000600
01120000207401c7401e7402074020740217402374020740207401c7401e7402074020740217402374020740207401c7401e7402074020740217402374020740207401c7401e7401e7401c7411c7411c7411c700
01120000237401f740217402374023740247402674023740237401f740217402374023740247402674023740237401f740217402374023740247402674023740237401f74021740217401f7411f7411f7411f700
011400000000029752297522975229752297520070228752287520070229752297520070228752287520070224752247522475200702217520070226752267522677221772217722177221772000000000000000
011400000010000100001000010000100001000010000100001000010000100001000010000100001000010022100221002410024100161000010018100181002211222112221222212224132241322414224142
011800001825218252000000020017252172520000000200162521625200000002001525115251152511525115251152511525115255002000020000200002000020000000000000000000000000000000000000
__music__
00 40411543
01 13141543
00 13141543
00 13141643
02 13141643
04 17184344

