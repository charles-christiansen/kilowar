pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--game loop
-- 3665 tokens
function _init()
	camx=0
	camy=0
	sbx=camx
	yardline=20
	down="1st"
	dist=10
	debug = down.." & "..dist
	selteam=1
	sprw=16
	sprh=16

	-- line battle vars	
	blkfrms = {0,0,0,0}
	cntfrms = {0,0,0,0}
	colchecked = {false,false,false,false}
	lbw={}
	lbl={}
	hiked=false
	
	-- playbooks
	init_playbooks()
	selplay=1
	curplay={}
	pbfc=0
	pbhike=false
	dx1,dx2,dy1,dy2=-1,-1,-1,-1
	ptgt={}
	tgt={}
	rnr={}
	pr=""
	
	-- teams
	pteam={}
	cteam={}
	oteam={}
	dteam={}
	pscore=0
	cscore=0
	
	teams={
		{name="raleigh",nick="robots",pc=0,sc=6,pb=pb1},
		{name="boise",nick="bruisers",pc=1,sc=12,pb=pb2},
		{name="san jose",nick="surfers",pc=5,sc=11,pb=pb3},
		{name="tuscon",nick="twisters",pc=2,sc=8,pb=pb4},
	}
	
	ball={x=0,y=32,dx=0,dy=0,spr=13,f=false,thrown=false}

	-- arc for thrown ball
	_curve = {}
	_frac = 0
	
	palt(0,false)
	palt(14,true)
	--music(0)
	mode="title"
	submode=""
end

function initbook(_pb)
	local p1,p2,p3,p4 = {},{},{},{}
	p1.name="in 'n' out"
	p1.rp="p"
	p1.r1={sx=32,sy=5,x=32,y=5,dests={{ox=30,oy=0},{ox=20,oy=43}},cd=1}
	p1.r2={sx=32,sy=89,x=32,y=89,dests={{ox=56,oy=0}},cd=1}
	add(_pb,p1)
	p2.name="fly"
	p2.rp="p"
	p2.r1={sx=32,sy=5,x=32,y=5,dests={{ox=60,oy=0}},cd=1}
	p2.r2={sx=32,sy=89,x=32,y=89,dests={{ox=60,oy=0}},cd=1}
	add(_pb,p2)
	p3.name="ziggy"
	p3.rp="p"
	p3.r1={sx=32,sy=5,x=32,y=5,dests={{ox=20,oy=20},{ox=35,oy=-10},{ox=20,oy=30}},cd=1}
	p3.r2={sx=32,sy=89,x=32,y=89,dests={{ox=60,oy=0}},cd=1}
	add(_pb,p3)
	p4.name="scramble"
	p4.rp="r"
	p4.r1={sx=32,sy=5,x=32,y=5,dests={{ox=60,oy=0}},cd=1}
	p4.r2={sx=32,sy=89,x=32,y=89,dests={{ox=60,oy=0}},cd=1}
	add(_pb,p4)
end

function init_playbooks()
	pb1,pb2,pb3,pb4={},{},{},{}
	initbook(pb1)
	initbook(pb2)
	initbook(pb3)
	initbook(pb4)
end

function _update60()
	if mode == "title" then
		update_title()
	elseif mode == "team" then
		--music(-1,500)
		update_team()
	elseif mode == "play" then
		update_play()
	elseif mode == "game" then
		update_game()
	end
end

function update_title()
	if btnp(5) then
		mode="team"
	end
end

function update_team()
	if btnp(1) or btnp(3) then
		selteam += 1
		if selteam > 4 then
			selteam = 1
		end
	elseif btnp(0) or btnp(2) then
		selteam -= 1
		if selteam < 1 then
			selteam = 4
		end
	end
	if btnp(5) then
		initteams()
		-- temp putting this here
		camx = pteam.qb.x - 60
		if camx < 0 then 
			camx = 0
		elseif camx > 744 then 
			camx = 744 
		end
		sbx=camx
		-- end temp putting this here
		mode = "play"
	end
end

function setuppbplay()
	curplay = pteam.pb[selplay]
	cr1 = curplay.r1
	cr2 = curplay.r2
	cr1.x = cr1.sx
	cr1.y = cr1.sy
	cr1.cd = 1
	cr2.x = cr2.sx
	cr2.y = cr2.sy
	cr2.cd = 1
	pbfc = 0
	dx1,dx2,dy1,dy2=-1,-1,-1,-1
	pbhike = false
end

function update_play()
	cr1 = curplay.r1
	cr2 = curplay.r2
	if pbfc >= 30 then
		pbhike = true
	else
		pbfc += 1
	end
	if btnp(0) then
		selplay -= 1
		if selplay < 1 then
			selplay = #pteam.pb
		end
		setuppbplay()
	elseif btnp(1) then
		selplay += 1
		if selplay > #pteam.pb then
			selplay = 1
		end
		setuppbplay()
	elseif btnp(5) then
		pbfc=0
		pbhike=false
		dx1,dx2,dy1,dy2=-1,-1,-1,-1
		cr1.cd=1
		cr2.cd=1
		mode="game"
		submode="lineup"
		return
	end
	if pbhike then
		if #(cr1.dests) >= cr1.cd then
			d=cr1.dests[cr1.cd]
			if dx1 < 0 then
				dx1 = d.ox + cr1.x
			end
			if dy1 < 0 then
				dy1 = d.oy + cr1.y
			end
			
			if d.ox > 0 then
				cr1.x += pteam.rec.rec1.speed
			else
				cr1.x -= pteam.rec.rec1.speed
			end
			if d.oy > 0 then
				cr1.y += pteam.rec.rec1.speed
			else
				cr1.y -= pteam.rec.rec1.speed
			end
			if (cr1.x > dx1 and d.ox > 0) or (cr1.x < dx1 and d.ox <= 0) then
				cr1.x = dx1
			end
			if (cr1.y > dy1 and d.oy > 0) or (cr1.y < dy1 and d.oy <= 0) then
				cr1.y = dy1
			end
			if cr1.x == dx1 and cr1.y == dy1 then
				cr1.cd += 1
				dx1,dy1=-1,-1
			end
		end
		if #(cr2.dests) >= cr2.cd then
			d=cr2.dests[cr2.cd]
			if dx2 < 0 then
				dx2 = d.ox + cr2.x
			end
			if dy2 < 0 then
				dy2 = d.oy + cr2.y
			end
			
			if d.ox > 0 then
				cr2.x += pteam.rec.rec2.speed
			else
				cr2.x -= pteam.rec.rec2.speed
			end
			if d.oy > 0 then
				cr2.y += pteam.rec.rec2.speed
			else
				cr2.y -= pteam.rec.rec2.speed
			end
			if (cr2.x > dx2 and d.ox > 0) or (cr2.x < dx2 and d.ox <= 0) then
				cr2.x = dx2
			end
			if (cr2.y > dy2 and d.oy > 0) or (cr2.y < dy2 and d.oy <= 0) then
				cr2.y = dy2
			end
			if cr2.x == dx2 and cr2.y == dy2 then
				cr2.cd += 1
				dx2,dy2=-1,-1
			end
		end
	end
end

function update_game()
	if submode=="lineup" then
		update_lineup()
	elseif submode=="hike" then
		update_hike()
	elseif submode=="throw" then
		update_throw()
	elseif submode=="run" then
		update_run()
	elseif submode=="eop" then
		update_eop()
	end
	camx = ball.x - 60
	if camx < 0 then 
		camx = 0
	elseif camx > 744 then 
		camx = 744 
	end
	sbx=camx
end

function update_lineup()
	ball.x = oteam.qb.x + oteam.qb.fox
	ball.y = oteam.qb.y + oteam.qb.foy
	if btnp(4) then
		if oteam == pteam and not hiked then
			hiked=true
			calc_target(oteam.rec.rec1)
			ptgt = curplay.r1.dests
			submode="hike"
		end
	end
end

function update_hike()
	debug="hike!"
	update_movement()
	if curplay.rp == "r" then
		rnr = oteam.qb
		submode="run"
		return
	end
	if btnp(2) then
		calc_target(oteam.rec.rec1)
		ptgt = curplay.r1.dests
	elseif btnp(3) then
		calc_target(oteam.rec.rec2)
		ptgt = curplay.r2.dests
	elseif btnp(5) then
		submode="throw"
	end
end

function update_throw()
	update_movement()
	if not ball.thrown then
		ball.dx=0.5
		ball.dy=0.5
		ball.ydir = sgn(tgt.desty - ball.y)
--		midx=flr(tgt.destx - ball.x / 4)
--		midy=abs(flr(tgt.desty - ball.y / 4))
--		add(_curve,{ball.x,ball.y})
--		add(_curve,{midx,midy})
--		add(_curve,{tgt.destx,tgt.desty})
		ball.thrown = true
	end
	if ball.x >= tgt.destx and ball.thrown then
		ball.dx = 0
		ball.x = tgt.destx
	end
	if ball.ydir > 0 and ball.y >= tgt.desty and ball.thrown then
		ball.dy = 0
		ball.y = tgt.desty
	elseif ball.ydir < 0 and ball.y <= tgt.desty and ball.thrown then
		ball.dy = 0
		ball.y = tgt.desty
	end
	
	if ball.dx == 0 and ball.dy == 0 then
		ball.thrown = false
		if ball.x == tgt.x and ball.y == tgt.y then
			submode="run"
			rnr=tgt
		else
			submode="eop"
			pr="i"
		end
	end

	if ball.thrown then
		ball.x += ball.dx
		ball.y += (ball.ydir * ball.dy)
--		current progress along curve
--		_frac=(_frac+0x.02)%1
--  
--		projectile location on curve
--		_pos=bezier_eval(_curve,_frac)
--		ball.x = ceil(_pos[1])
--		ball.y = ceil(_pos[2])
	end
end

function update_run()
	update_movement()
	if btn(0) then
		rnr.x -= rnr.speed
		ball.x-=rnr.speed
		if rnr.x <= 1 then
			rnr.x = 1
			ball.x = rnr.x + rnr.fox
		end	
		rnr.f = true
		ball.f = true
	elseif btn(1) then
		rnr.x+=rnr.speed
		ball.x+=rnr.speed
		if rnr.x > 855 then
			rnr.x = 855
			ball.x = rnr.x + rnr.fox
		end
		rnr.f = false
		ball.f = false
	elseif btn(2) then
		rnr.y -= rnr.speed
		ball.y-= rnr.speed
		if rnr.y < 32 then
			rnr.y = 32
			ball.y = rnr.y + rnr.foy
		end
	elseif btn(3) then
		rnr.y += rnr.speed
		ball.y+=rnr.speed
		if rnr.y > 110 then
			rnr.y = 110
			ball.y = rnr.y + rnr.foy
		end
	end
end

function update_eop()
	if pr == "i" then
		debug = "incomplete"
	end
end

function update_movement()
	-- linemen
	for k,ol in pairs(oteam.ol) do
		ol.x += ol.speed
	end
	for k,dl in pairs(dteam.dl) do
		dl.x -= dl.speed
	end
	if oteam.ol.ol1.x + 16 >= dteam.dl.dl1.x and not colchecked[1] then
		linebattle(oteam.ol.ol1,dteam.dl.dl1,1)
	end
	if oteam.ol.ol2.x + 16 >= dteam.dl.dl2.x and not colchecked[2] then
		linebattle(oteam.ol.ol2,dteam.dl.dl2,2)
	end
	if oteam.ol.ol3.x + 16 >= dteam.dl.dl3.x and not colchecked[3] then
		linebattle(oteam.ol.ol3,dteam.dl.dl3,3)
	end
	if oteam.ol.ol4.x + 16 >= dteam.dl.dl4.x and not colchecked[4] then
		linebattle(oteam.ol.ol4,dteam.dl.dl4,4)
	end
	for i=1,4 do
		if blkfrms[i] > 0 then
			cntfrms[i] += 1
			if cntfrms[i] >= blkfrms[i] then
				lbw[i].speed = lbw[i].ospeed
				blkfrms[i] = 0
				cntfrms[i] = 0
			else
				if lbl[i].x < lbw[i].x then
					lbl[i].x -= (lbw[i].ospeed/16)
					lbw[i].x -= (lbw[i].ospeed/16)
				else
					lbl[i].x += (lbw[i].ospeed/16)
					lbw[i].x += (lbw[i].ospeed/16)
				end
			end
		end
	end
	-- receivers
	r1 = oteam.rec.rec1
	r2 = oteam.rec.rec2
	if #(curplay.r1.dests) >= curplay.r1.cd then
		d=curplay.r1.dests[curplay.r1.cd]
		if dx1 < 0 then
			dx1 = d.ox + r1.x
		end
		if dy1 < 0 then
			dy1 = d.oy + r1.y
		end
		
		if d.ox > 0 then
			r1.x += r1.speed
		else
			r1.x -= r1.speed
		end
		if d.oy > 0 then
			r1.y += r1.speed
		else
			r1.y -= r1.speed
		end
		if (r1.x > dx1 and d.ox > 0) or (r1.x < dx1 and d.ox <= 0) then
			r1.x = dx1
		end
		if (r1.y > dy1 and d.oy > 0) or (r1.y < dy1 and d.oy <= 0) then
			r1.y = dy1
		end
		if r1.x == dx1 and r1.y == dy1 then
			curplay.r1.cd += 1
			dx1,dy1=-1,-1
		end
	end
	if #(curplay.r2.dests) >= curplay.r2.cd then
		d=curplay.r2.dests[curplay.r2.cd]
		if dx2 < 0 then
			dx2 = d.ox + r2.x
		end
		if dy2 < 0 then
			dy2 = d.oy + r2.y
		end
		
		if d.ox > 0 then
			r2.x += r2.speed
		else
			r2.x -= r2.speed
		end
		if d.oy > 0 then
			r2.y += r2.speed
		else
			r2.y -= r2.speed
		end
		if (r2.x > dx2 and d.ox > 0) or (r2.x < dx2 and d.ox <= 0) then
			r2.x = dx2
		end
		if (r2.y > dy2 and d.oy > 0) or (r2.y < dy2 and d.oy <= 0) then
			r2.y = dy2
		end
		if r2.x == dx2 and r2.y == dy2 then
			curplay.r2.cd += 1
			dx2,dy2=-1,-1
		end
	end
	-- todo: corners
	-- todo: qb
end

function _draw()
	if mode == "title" then
		draw_title()
	elseif mode == "team" then
		draw_team()
	elseif mode == "play" then
		draw_play()
	elseif mode == "game" then
		draw_game()
	end
end

function draw_title()
	cls()
	print("8-bit battle",42,10,12)
	map(46,0,0,31,16,12)
	print("press ❎  to start",32,82,12)
end

function draw_team()
	cls()
	inity=25
	print("choose your team!",32,15,7)
	for i=1,#teams do
		fn = teams[i].name.." "..teams[i].nick
		namex = 37 - (#fn - 14)
		rectfill(7,inity,120,inity+21,teams[i].pc)
		rect(7,inity,120,inity+21,teams[i].sc)
		print(fn,namex,inity+8,teams[i].sc)
		inity += 23
	end
	print("❎ ",121,37+(21*(selteam-1)),teams[selteam].sc)
end

function draw_play()
	cls()
	oc=pteam.sc
	dc=cteam.sc
	print("o",32,35,oc)
	print("o",32,43,oc)
	print("o",32,51,oc)
	print("o",32,59,oc)
	print("o",17,51,oc)
	print("x",42,5,dc)
	print("x",40,35,dc)
	print("x",40,43,dc)
	print("x",40,51,dc)
	print("x",40,59,dc)
	print("x",42,89,dc)
	print("⬅️prev",2,110,oc)
	print(curplay.name,52 - #curplay.name,110,oc)
	print("next➡️",103,110,oc)
	print("❎select❎",43,120,oc)
	print("o",curplay.r1.x,curplay.r1.y,oc)
	print("o",curplay.r2.x,curplay.r2.y,oc)
end

function draw_game()
	pal()
	palt(0,false)
	palt(14,true)
	cls()
	camera(camx,camy)
	rect(sbx,0,sbx+127,31,7)
	print(pteam.name.." "..pteam.nick,sbx+2,2,pteam.sc)
	print(cteam.name.." "..cteam.nick,sbx+2,9,cteam.sc)
	print(pscore,sbx+92,2,pteam.sc)
	print(cscore,sbx+92,9,cteam.sc)
	print(debug,sbx+2,23,7)
	map(0,0,0,31,109,12)
	spr(ball.spr,ball.x,ball.y)
	-- offense
	pal(9,oteam.pc)
	pal(10,oteam.sc)
	sspr(oteam.qb.sx,oteam.qb.sy,sprw,sprh,oteam.qb.x,oteam.qb.y,sprw,sprh,oteam.qb.f)
	sspr(oteam.rec.rec1.sx,oteam.rec.rec1.sy,sprw,sprh,oteam.rec.rec1.x,oteam.rec.rec1.y,sprw,sprh,oteam.rec.rec1.f)
	sspr(oteam.ol.ol1.sx,oteam.ol.ol1.sy,sprw,sprh,oteam.ol.ol1.x,oteam.ol.ol1.y,sprw,sprh,oteam.ol.ol1.f)
	sspr(oteam.ol.ol2.sx,oteam.ol.ol2.sy,sprw,sprh,oteam.ol.ol2.x,oteam.ol.ol2.y,sprw,sprh,oteam.ol.ol2.f)
	sspr(oteam.ol.ol3.sx,oteam.ol.ol3.sy,sprw,sprh,oteam.ol.ol3.x,oteam.ol.ol3.y,sprw,sprh,oteam.ol.ol3.f)
	sspr(oteam.ol.ol4.sx,oteam.ol.ol4.sy,sprw,sprh,oteam.ol.ol4.x,oteam.ol.ol4.y,sprw,sprh,oteam.ol.ol4.f)
	sspr(oteam.rec.rec2.sx,oteam.rec.rec2.sy,sprw,sprh,oteam.rec.rec2.x,oteam.rec.rec2.y,sprw,sprh,oteam.rec.rec2.f)
	-- defense
	pal(4,dteam.pc)
	pal(13,dteam.sc)
	sspr(dteam.cb.cb1.sx,dteam.cb.cb1.sy,sprw,sprh,dteam.cb.cb1.x,dteam.cb.cb1.y,sprw,sprh,dteam.cb.cb1.f)
	sspr(dteam.dl.dl1.sx,dteam.dl.dl1.sy,sprw,sprh,dteam.dl.dl1.x,dteam.dl.dl1.y,sprw,sprh,dteam.dl.dl1.f)
	sspr(dteam.dl.dl2.sx,dteam.dl.dl2.sy,sprw,sprh,dteam.dl.dl2.x,dteam.dl.dl2.y,sprw,sprh,dteam.dl.dl2.f)
	sspr(dteam.dl.dl3.sx,dteam.dl.dl3.sy,sprw,sprh,dteam.dl.dl3.x,dteam.dl.dl3.y,sprw,sprh,dteam.dl.dl3.f)
	sspr(dteam.dl.dl4.sx,dteam.dl.dl4.sy,sprw,sprh,dteam.dl.dl4.x,dteam.dl.dl4.y,sprw,sprh,dteam.dl.dl4.f)
	sspr(dteam.cb.cb2.sx,dteam.cb.cb2.sy,sprw,sprh,dteam.cb.cb2.x,dteam.cb.cb2.y,sprw,sprh,dteam.cb.cb2.f)
end
-->8
--utility
function linebattle(_op,_dp,_idx)
	if _op.block >= _dp.block then
		lbw[_idx]=_op
		lbl[_idx]=_dp
	else
		lbw[_idx]=_dp
		lbl[_idx]=_op
	end
	_op.speed = 0
	_dp.speed = 0
	blkfrms[_idx] = (10-flr(lbw[_idx].block - lbl[_idx].block)) * 60
	colchecked[_idx] = true
end

function initteams()
	pteam = teams[selteam]
	initplayers(pteam)
	r = selteam
	while r == selteam do
		r = flr(rnd(#teams))+1
	end
	cteam = teams[r]
	initplayers(cteam)
	oteam=pteam
	dteam=cteam
	curplay=pteam.pb[1]
end

function initplayers(_team)
	-- each team has 13 players: a QB, two receivers, 4 o-line, 4 d-line, 2 corners
	qbxpos = (yardline + (flr(yardline/10)*0.5))*7.84
	xpos = (yardline + (flr(yardline/10)*1.5))*7.84
	_team.qb={x=qbxpos,y=66,sx=0,sy=32,fox=13,foy=4,f=false,csx=0,speed=rnd(1)}
	_team.rec={rec1={x=xpos,ogx=xpos,y=32,ogy=32,sx=0,sy=32,speed=rnd(1.25),f=false},rec2={x=xpos,ogx=xpos,y=111,ogy=111,sx=0,sy=32,speed=rnd(1.25),f=false}}
	s1,s2,s3,s4=rnd(0.4),rnd(0.4),rnd(0.4),rnd(0.4)
	_team.ol={ol1={x=xpos,y=48,sx=48,sy=32,block=rnd(10),f=false,speed=s1,ospeed=s1},ol2={x=xpos,y=64,sx=48,sy=32,block=rnd(10),f=false,speed=s2,ospeed=s2},ol3={x=xpos,y=80,sx=48,sy=32,block=rnd(10),f=false,speed=s3,ospeed=s3},ol4={x=xpos,y=96,sx=48,sy=32,block=rnd(10),f=false,speed=s4,ospeed=s4}}	
	ds1,ds2,ds3,ds4=rnd(0.4),rnd(0.4),rnd(0.4),rnd(0.4)
	_team.dl={dl1={x=xpos+18,y=48,sx=64,sy=32,block=rnd(10),f=true,speed=ds1,ospeed=ds1},dl2={x=xpos+18,y=64,sx=64,sy=32,block=rnd(10),f=true,speed=ds2,ospeed=ds2},dl3={x=xpos+18,y=80,sx=64,sy=32,block=rnd(10),f=true,speed=ds3,ospeed=ds3},dl4={x=xpos+18,y=96,sx=64,sy=32,block=rnd(10),f=true,speed=ds4,ospeed=ds4}}	
	_team.cb={cb1={x=xpos+24,y=32,sx=80,sy=32,speed=rnd(1.25),f=true},cb2={x=xpos+24,y=111,sx=80,sy=32,speed=rnd(1.25),f=true}}
end

function calc_target(_t)
	tgt = _t
	tgt.destx=tgt.ogx
	tgt.desty=tgt.ogy
	for v in all(ptgt) do
		tgt.destx += v.ox
		tgt.desty += v.oy
	end
end
-->8
--bezier curve!
--------------------------------
-- bezier code
--------------------------------

-- linear interpolation of two
-- points of arbitrary dimension
-- where you get p0 at frac==0
-- and p1 at frac==1.
function lerp(p0,p1,frac)
    assert(#p0==#p1)
    local carf=1-frac
    local pfrac={}
    for i=1,#p0 do
        add(pfrac,p0[i]*carf+p1[i]*frac)
    end
    return pfrac
end

-- bezier curve evaluation,
-- given a list of points, the
-- length of which dictates the
-- power of a curve, e.g. a
-- list of two points is a line,
-- a list of three points is a 
-- quadratic curve, four is
-- cubic, etc.
function bezier_eval(curve,frac)
    if #curve>1 then
        -- the spirit of bezier curve
        -- evaluation is recursive.
        -- for specific powers, this
        -- could be boiled down to
        -- straightforward, non-
        -- recursive math, but this is
        -- a general-purpose solution.
        local subcurve={}
        for i=2,#curve do
            local p0,p1=curve[i-1],curve[i]
            add(subcurve,lerp(p0,p1,frac))
        end
        return bezier_eval(subcurve,frac)
    end
    return curve[1]
end
-->8
-- notes
-- 1 yard = 8px

-- this is the code for the bezier curve calculation
--	if ball.thrown then
--		-- current progress along curve
--		_frac=(_frac+0x.02)%1
--   
--		-- projectile location on curve
--		_pos=bezier_eval(_curve,_frac)
--		ball.x = ceil(_pos[1])
--		ball.y = ceil(_pos[2])
--	end
--	

__gfx__
00000000333333337777777733333337333373333333733377777777777777773333733333333333777777777133333371333333eeeeeeeeeeeeeeee33337777
00000000333333333333733333333337377373733333733333333333333373333333733333333333173337331733333317333333eeeeeeeeee8888ee37737337
00700700333333333333733333333337733773733333733333333333333373333333733333333333713337337133333371333333eeeeeeeee888888e73377373
0007700033333333333373333333333773377373333373333333333333337333333373333333333317333733173333331733333344eeeeeee888888e73377733
0007700033333333333333333333333773377377333373333333333333337333333373333333733371333333713333337133337344eeeeeee888888e73377737
00700700333333333333333333333337377373733333733333333333333373333333733333337333173333331733333317333373eeeeeeeeee8888ee37737373
00000000333333333333333333333337333373333333733333333333333373333333733333337333713333337133333371333373eeeeeeeeeeeeeeee33337333
00000000333333333333333333333337333373333333733333333333333373337777777777777777173333331733333377777777eeeeeeeeeeeeeeee33337333
00000000333373773333733333337333717171717171717171333333333333333333337133333371717171717777717133337133333371333371eeee7171eeee
00000000377377333773773337737777171717171717171717333333333333333333331733333317171717173333171733331733333317333317eeee1717eeee
00000000733773737337773373377733713333333333333371333333333333333333337133333371333333713333713333337133333371333371eeee3371eeee
00000000733777337337777773377777173333333333333317333333333333333333331733333317333333173333173333331733333317333317eeee3317eeee
00000000733777377337773773377337713333333333333371333333333333333333337133333371333333713333713333337133333371333371eeee3371eeee
00000000377373733773773737737777173333333333333317333333333333333333331733333317333333173333173333331733333317333317eeee3317eeee
00000000333373333333733333337333713333333333333371717171717171717171717133333371333333713333713333337171333371337171eeee3371eeee
00000000333373333333733333337333173333333333333317171717171717171717171733333317333333173333173377771717333317331717eeee3317eeee
000000003371eeee3333733333337333333373333333733333337333000000000000000000000000000000000000000000000000000000000000000000000000
000000003317eeee3373737337337373377373737373737377737373000000000000000000000000000000000000000000000000000000000000000000000000
000000003371eeee3773773773737737733777377373773773337737000000000000000000000000000000000000000000000000000000000000000000000000
000000003317eeee3373773733737737333777377773773777737737000000000000000000000000000000000000000000000000000000000000000000000000
000000003371eeee3373773737337737337377373373773733737737000000000000000000000000000000000000000000000000000000000000000000000000
000000003317eeee3373737373337373333773733373737377737373000000000000000000000000000000000000000000000000000000000000000000000000
000000003371eeee3333733377737333777373333333733333337333000000000000000000000000000000000000000000000000000000000000000000000000
000000003317eeee3333733333337333333373333333733333337333000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000
eeeee9999eeeeeeeeeeee9999eeeeeeeeeeee9999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4444eeeeeee00000000000000000000000000000000
eeee9aaaa9eeeeeeeeee9aaaa9eeeeeeeeee9aaaa9eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4dddd4eeeeee00000000000000000000000000000000
eeee9aaaa9eeeeeeeeee9aaaa9eeeeeeeeee9aaaa9eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4dddd4eeeeee00000000000000000000000000000000
eeeee9999aa9eeeeeeeee9999aa9eeeeeeeee9999aa9eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4444dd4eeee00000000000000000000000000000000
eee99aaaa99eeeeeeee99aaaa99eeeeeeee99aaaa99eeeeeeeeeeeeee9999eeeeeeeeeeee4444eeeeee44dddd44eeeee00000000000000000000000000000000
ee999aa9a999eeeeee999aa9a999eeeeee999aa9a999eeeeeeeeeeee9aaaa9eeeeeeeeee4dddd4eeee444dd4d444eeee00000000000000000000000000000000
ee9e9a99a9e9eeeeee9e9a99a9e9eeeeee9e9a99a9e9eeeeeeeeeeee9aaaa9eeeeeeeeee4dddd4eeee4e4d44d4e4eeee00000000000000000000000000000000
ee9e99a9a9e9feeee99e99a9a9e9feeeee9e99a9a9ee9eeeeeeeeeeee9999aa9eeeeeeeee4444dd4ee4e44d4d4e4feee00000000000000000000000000000000
eefe99a9a9eeeeeeefee99a9a9eeeeeeeefe99a9a9eeefeeeeeeeeeee999aeeeeeeeeeeee444deeeeefe44d4d4eeeeee00000000000000000000000000000000
eeee99a9a9eeeeeeeeee99a9a9eeeeeeeeee99a9a9eeeeeeeeeeeeeee999a9eeeeeeeeeee444d4eeeeee44d4d4eeeeee00000000000000000000000000000000
eeeeaaaaaaeeeeeeeeeeaaaaaaeeeeeeeeeeaaaaaaeeeeeeeeeeeeeee999ae9eeeeeeeeee444de4eeeeeddddddeeeeee00000000000000000000000000000000
eeee777777eeeeeeeeee777777eeeeeeeeee777777eeeeeeeeeeeeeee999ae9eeeeeeeeee444de4eeeee777777eeeeee00000000000000000000000000000000
eeee77ee77eeeeeeeeee77ee77eeeeeeeeee77ee77eeeeeeeeeeeeeee9999ee9eeeeeeeee4444ee4eeee77ee77eeeeee00000000000000000000000000000000
eeee77ee77eeeeeeeeee77ee77eeeeeeeeee77ee77eeeeeeeeeeee97e7ee7eefeeeeee47e7ee7eefeeee77ee77eeeeee00000000000000000000000000000000
eeee9aee9aeeeeeeeeeeeeee9aeeeeeeeeee9aeeeeeeeeeeeeeeeeae77ee9aeeeeeeeede77ee4deeeeee4dee4deeeeee00000000000000000000000000000000
__map__
141515151a020202020202020202070202020202020202020702020202020202020207020202020202020202070202020202020202020702020202020202020207020202020202020202070202020202020202020702020202020202020207020202020202020202141515151a00000000000000000000000000000000000000
0b010101190101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010b0101011900000000000000000000000000000000000000
0b01010119010101010101010101040101010101010101010f01010101010101010111010101010101010101120101010101010101011301010101010101010112010101010101010101110101010101010101010f010101010101010101040101010101010101010b0101011900000000000000000000000000000000000000
0b010101190101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010b0101011900000000000000000000000000000000000000
0b010101190101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010b0101011900000000000000000000000000000000000000
0b010101190101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010b0101011900000000000000000000000000000000000000
0b010101190101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010b0101011900000000000000000000000000000000000000
0b010101190101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010b0101011900000000000000000000000000000000000000
0b010101190101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010b0101011900000000000000000000000000000000000000
0b010101190101010101010101012201010101010101010123010101010101010101240101010101010101012501010101010101010126010101010101010101250101010101010101012401010101010101010123010101010101010101220101010101010101010b0101011900000000000000000000000000000000000000
0b010101190101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010501010101010101010105010101010101010101050101010101010101010b0101011900000000000000000000000000000000000000
1617171718090909090909090909080909090909090909090809090909090909090908090909090909090909080909090909090909090809090909090909090908090909090909090909080909090909090909090809090909090909090908090909090909090909161717171800000000000000000000000000000000000000
__sfx__
000a00000525005250052530020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
000600000b2500c250102500020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
01140000291322913229132291320000224132241320000229132291320000227132271322713227132000022b1322b1322b1322b132000022713227132271322713200002221322213222132221320000200002
011400001d1321d1321d1321d132180021813218132180021d1321d132180021b1321b1321b1321b132180021f1321f1321f1321f132180021b1321b1321b1321b13218002161321613216132161320000200002
011400001570000003000001576315763157631576300000000001576315763157631576300000000001576315763157631576300000000001576315763157631576300000000001576315763157631576300000
0114000035112351123511235112300023011230112300023511235112300023311233112331123311230002371123711237112371123000233112331123311233112000022e1122e1122e1122e1120000200002
__music__
02 02030405