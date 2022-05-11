pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--letris by eduszesz
--it is like tetris, but with l

function _init()
	state="init"
	on="off"
	initialize()
end

function _update()
	t+=1
	checkfade()	
	if state=="init" then
		if btnp(5) then
			state="settings"
		end
		
		if btnp(4) then
			state="game"
			initialize()
			fadeout()
		end
	end
	
	if state=="settings" then
		if btnp(4) then
			state="init"
		end
		if btnp(2) then
			on="on"
		end
		
		if btnp(3) then
			on="off"
		end
		
	end
	
	
	if state=="over" then
		if btnp(4) then
			state="init"
			fadeout()
		end
	end
		
	if state=="game" then
		local bt=4
		if on=="on" then bt=2 end
		if t%rt==0 and ft==0 then
			py+=8
		end
		
		if btn(3) and ft==0 then
			rt=4
			sfx(3)
		else
			rt=nrt	
		end
		
		if btnp(0) and px>2
			and (not check_x(-1))  then
			px-=8
			sfx(3)
		end
		
		if btnp(1) and px<(88-le())
			and (not check_x(1)) then
			px+=8
			sfx(3)
		end
		--[[
		if btnp(5) then
			co=flr(rnd(15)+1)
			cpi+=1
			if cpi>#cp then cpi=1 end
			p=cp[cpi]
		end]]
		
		if btnp(4) or btnp(bt)
			or btnp(5) then
			p=transpose()
			p=m_multi(p)
			sfx(0)
			if (px+le())>88 then
				px-=px+le()-88
			end
			if px<0 then
				px=0
			end
			if (py+he())>128 then
				py-=py+he()-128
			end	
		end
		
		if (py+he())>128 then
				py-=py+he()-128
		end
		
		check_lines()
		fix()
		set_explosions()
		check_level()
		dofloats()
		
		if not check_y()
		and ((py+he())<128) then
			ft=0
		end
		
		game_over()
		
	end	
end

function _draw()
	cls()
	
	if state=="init" then
		local co=7
		local l={{1,0},{1,0},{1,1}}
		if t%16<8 then
			co=13
		end
		rect(0,0,127,127,7)
		rect(1,1,126,126,12)
		sspr(40,32,47,7,15,10,100,20)
		print("it is like tetris,",32,40,7)
		print("but with",32,62,7)
		pal(14,9)
		draw_p(l,72,52,1)
		print("press 🅾️ to start",32,88,co)
		print("press ❎ for settings",24,104,7)
	end
	
	if state=="settings" then
		local co=7
		rect(0,0,127,127,7)
		rect(1,1,126,126,11)
		print("add ⬆️ for rotation:",22,24,7)
		if on=="on" then
			co=11
			print("➡️",54,32,7)
		else
			co=7
			print("➡️",54,40,7)
		end
		print("on",64,32,co)
		print("off",64,40,7)
		
		print("press 🅾️ to exit",32,88,7)
	end
	
	if state=="over" then
		local co=7
		if t%16<8 then
			co=13
		end
		rect(0,0,127,127,7)
		rect(1,1,126,126,12)
		sspr(0,32,31,15,13,20,100,40)
		print("lines: "..pline,48,96,8)
		print("level: "..level,48,104,10)
		print("press 🅾️ to play again",20,80,co)
	end
	
	
	if state=="game" then
		pal(14,co)
		draw_p(p,px,py,1)
		draw_p(np,96,24,2)
		rect(0,0,127,127,levelco[lcoi])
		rect(0,0,88,127,levelco[lcoi])
		print("lines:",96,64,8)
		print(pline,104,72,8)
		print("level:",96,88,10)
		print(level,104,96,10)
		draw_grid()
		map()
		draw_explosions()
		
		for f in all(float) do
			print(f.txt,f.x,f.y,f.c)
		end
		
		--debug
		--spr(3,px,py)
		--print_p(p,32,32)
		--print_p(grid,0,0)
		--print(on,100,120,8)
		--print("l="..(px+le()),100,110,8)
	end
end

function draw_p(_p,_x,_y,_sp)
	local p=_p
	local px,py,sp=_x,_y,_sp
	for i=1,#p do
		for j=1,#p[i] do
			if p[i][j]==1 then
				spr(sp,px+(j-1)*8,py+(i-1)*8)
			end
		end
	end
end

function transpose()
--transpose a matrix
	local res = {}
	for i=1, #p[1] do
		res[i]={}
		for j=1, #p do
			res[i][j] = p[j][i]
		end
	end
	return res
end

function m_multi(_p)
--multiply a matrix by a secondary diagonal matrix
--to mirror a matrix	
	local p=_p
	local res={}
	local m2={{0,1},{1,0}}
	local m3={{0,0,1},{0,1,0},{1,0,0}}
	local m={}
	if #p==2 then m=m3 end
	if #p==3 then m=m2 end
	if (#p>1 and #p<4) and (#p!=#p[1]) then
		for i = 1, #p do
        res[i] = {}
        for j = 1, #m[1] do
            res[i][j] = 0
            for k = 1, #m do
                res[i][j] = res[i][j] + p[i][k] * m[k][j]
            end
        end
    end
	else
		res=p
	end
	return res
end

function print_p(_p,_x,_y)
	local p,x,y=_p,_x,_y
	for i=1,#p do
		for j=1,#p[i] do
				print(p[i][j],x+(i-1)*8,y+(j-1)*8,7)
		end
	end
end

function le()
	--length of a piece
	--in pixels
	local le=#p[1]*8
	return le
end

function he()
	--heigth of a piece
	--in pixels
	local he=#p*8
	return he
end

function fix()
	local x,y,t=px/8,py/8,0
	if (he()+py)>120 or check_y() then
		ft+=1
		if ft==10 then
			ft=0
			for i=1,#p do
				for j=1,#p[i] do
					if p[i][j]==1 then
						sfx(2)
						local ix,iy=x+j,y+i
						grid[ix][iy]=1
					end
				end
			end
			px,py=40,0
			co=nco
			p=np
			cpi=flr(rnd(15)+1)
			np=cp[cpi]
			nco=cot[cpi]
		end
	end
end

function check_y()
	local x,y=px/8,py/8
	for i=1,#p do
		for j=1,#p[i] do
			if p[i][j]==1 then
				local dy=1
				if mget(x+(j-1),y+(i-1)+dy)==2 then
					return true
				end
			end
		end
	end
end

function check_x(_dx)
	local x,y=px/8,py/8
	local dx=_dx
	for i=1,#p do
		for j=1,#p[i] do
			if p[i][j]==1 then
				if mget(x+(j-1)+dx,y+(i-1))==2 then
					return true
				end
			end
		end
	end
end


function check_lines()
		
	for y=1,16 do
		local s=0
		for x=1,11 do
			if grid[x][y]==1 then			
				s+=1
			end
			if s==11 then
				s=0
				lines+=1
				pline+=1
				explode(0,y)
				for l=1,11 do
					for m=y,1,-1 do
						grid[l][m]=grid[l][m-1]
					end
				end
				for n=1,11 do
					grid[n][1]=0
				end	
			end
		end
	end
end

function draw_grid()
	for i=1,11 do
		for j=1,16 do
			if grid[i][j]==1 then
				mset(i-1,j-1,2)
			else
				mset(i-1,j-1,0)	
			end
		end
	end
end

function game_over()
	for x=1,11 do
		if grid[x][1]==1 then			
			state="over"
			fadeout()
		end
	end		
end

function explode(_x,_y)
	local x,y=_x*8,_y*8
	local e={x=x,y=y,t=0}
	add(explosions,e)
	sfx(1)
end

function set_explosions()
	for e in all(explosions) do
		e.t+=1
		if e.t>8 then
			del(explosions,e)
		end
	end
end

function draw_explosions()
	for e in all(explosions)do
		rectfill(e.x,e.y+(e.t/2),88,e.y-8-(e.t/2),e.t)
	end
end

function check_level()
	local dy=3
	if lines>=10 then
			level+=1
			lcoi+=1
			if lcoi>10 then
				lcoi=1
			end
			if level>8 then
				dy=1
			end
			lines=lines-10
			sfx(4)
			nrt-=dy
			if nrt<=4 then nrt=4 end
			addfloat("level "..level,32,64,7)
	end
end


--functions from
--porklike tutorial
--by lazydevs

function addfloat(_txt,_x,_y,_c)
 add(float,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-10,t=0})
end

function dofloats()
 for f in all(float) do
  f.y+=(f.ty-f.y)/10
  f.t+=1
  if f.t>70 then
   del(float,f)
  end
 end
end

function dofade()
 local p,kmax,col,k=flr(mid(0,fadeperc,1)*100)
 for j=1,15 do
  col = j
  kmax=flr((p+(j*1.46))/22)
  for k=1,kmax do
   col=dpal[col]
  end
  pal(j,col,1)
 end
end

function checkfade()
 if fadeperc>0 then
  fadeperc=max(fadeperc-0.04,0)
  dofade()
 end
end

function wait(_wait)
 repeat
  _wait-=1
  flip()
 until _wait<0
end

function fadeout(spd,_wait)
 if (spd==nil) spd=0.04
 if (_wait==nil) _wait=0
 repeat
  fadeperc=min(fadeperc+spd,1)
  dofade()
  flip()
 until fadeperc==1
 wait(_wait)
end
-- ---------------

function initialize()
	t=0
	ft=0
	rt=30
	nrt=30
	px=40
	py=0
	cpi=flr(rnd(15)+1)
	p1={{1,1},{1,1}}
	p2={{1,1,1,1}}
	p3={{1},{1},{1},{1}}
	p4={{0,1,1},{1,1,0}}
	p5={{1,1,0},{0,1,1}}
	p6={{1,0},{1,1},{0,1}}
	p7={{0,1},{1,1},{1,0}}
	p8={{1,1},{1,0},{1,0}}
	p9={{1,1},{0,1},{0,1}}
	p10={{0,0,1},{1,1,1}}
	p11={{1,0,0},{1,1,1}}
	p12={{0,1,0},{1,1,1}}
	p13={{1,0},{1,1},{1,0}}
	p14={{1,1,1},{0,1,0}}
	p15={{0,1},{1,1},{0,1}}
	cp={p1,p2,p3,p4,p5,p6,p7,p8,
		p9,p10,p11,p12,p13,p14,p15}
	cot={7,14,14,12,11,12,11,10,9,9,10,8,8,8,8}	
	levelco={7,3,12,11,10,9,8,3,4,6,13,7}
	lcoi=1
	co=cot[cpi]
	p=cp[cpi]
	ncpi=flr(rnd(15)+1)
	np=cp[ncpi]
	nco=cot[ncpi]
	lines=0
	pline=0	
	level=1
	explosions={}
	grid={}
	float={}
	for i=1,11 do
		grid[i]={}
		for j=1,16 do
			grid[i][j]=0
		end
	end	
	----------------------------
	-- required for fade
	dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}
	fadeperc=1
	-----------------------------	
end
__gfx__
000000000000000000000000c000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000eeee000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000ee11ee00661166000c00c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000e1551e006155160000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000e1551e006155160000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000ee11ee00661166000c00c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000eeee000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000c000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008880000888880001800180018888000000000000d700000d777700777777000d77770000d70000007770000000000000000000000000000000000000000000
018000000880080001800180018000000000000000d700000d70000000d700000d70070000d7000007ddd0000000000000000000000000000000000000000000
018080000880080001880180018888000000000000d700000d77770000d700000d77700000d70000007000000000000000000000000000000000000000000000
018018000888880001808080018000000000000000d700000d70000000d700000d70d70000d7000000d700000000000000000000000000000000000000000000
018018000880180001808080018000000000000000d700000d70000000d700000d70d70000d70000ddd700000000000000000000000000000000000000000000
008880000880180001808080018888000000000000d777700d77770000d700000d70d70000d70000777000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000018008000188880001888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01800800018008000180000001800800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01800800018008000188880001888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01800800018008000180000001801800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01800800018808000180000001801800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000001880000188880001801800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00290900009990000290090000000000029000900029000009900900000000000000000000000000000000000000000000000000000000000000000000000000
00290900029009000290090000000000029000900029000009900900000000000000000000000000000000000000000000000000000000000000000000000000
00290900029009000290090000000000029090900029000009990900000000000000000000000000000000000000000000000000000000000000000000000000
00299000029009000290090000000000029090900029000009909900000000000000000000000000000000000000000000000000000000000000000000000000
00029000029009000290090000000000029990900029000009902900000000000000000000000000000000000000000000000000000000000000000000000000
00029000009990000029990000000000002999000029000009902900000000000000000000000000000000000000000000000000000000000000000000000000
__label__
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c00000000000000000dd7770000000000dd77777777700007777777777777000000dd77777777700000000dd7770000000000007777777000000000000000c7
7c00000000000000000dd7770000000000dd77777777700007777777777777000000dd77777777700000000dd7770000000000007777777000000000000000c7
7c00000000000000000dd7770000000000dd77777777700007777777777777000000dd77777777700000000dd7770000000000007777777000000000000000c7
7c00000000000000000dd7770000000000dd77000000000000000dd7770000000000dd77000007700000000dd777000000000077ddddddd000000000000000c7
7c00000000000000000dd7770000000000dd77000000000000000dd7770000000000dd77000007700000000dd777000000000077ddddddd000000000000000c7
7c00000000000000000dd7770000000000dd77000000000000000dd7770000000000dd77000007700000000dd777000000000077ddddddd000000000000000c7
7c00000000000000000dd7770000000000dd77777777700000000dd7770000000000dd77777770000000000dd7770000000000007700000000000000000000c7
7c00000000000000000dd7770000000000dd77777777700000000dd7770000000000dd77777770000000000dd7770000000000007700000000000000000000c7
7c00000000000000000dd7770000000000dd77000000000000000dd7770000000000dd77000dd7700000000dd777000000000000dd77700000000000000000c7
7c00000000000000000dd7770000000000dd77000000000000000dd7770000000000dd77000dd7700000000dd777000000000000dd77700000000000000000c7
7c00000000000000000dd7770000000000dd77000000000000000dd7770000000000dd77000dd7700000000dd777000000000000dd77700000000000000000c7
7c00000000000000000dd7770000000000dd77000000000000000dd7770000000000dd77000dd7700000000dd77700000000dddddd77700000000000000000c7
7c00000000000000000dd7770000000000dd77000000000000000dd7770000000000dd77000dd7700000000dd77700000000dddddd77700000000000000000c7
7c00000000000000000dd7770000000000dd77000000000000000dd7770000000000dd77000dd7700000000dd77700000000dddddd77700000000000000000c7
7c00000000000000000dd7777777770000dd77777777700000000dd7770000000000dd77000dd7700000000dd7770000000077777700000000000000000000c7
7c00000000000000000dd7777777770000dd77777777700000000dd7770000000000dd77000dd7700000000dd7770000000077777700000000000000000000c7
7c00000000000000000dd7777777770000dd77777777700000000dd7770000000000dd77000dd7700000000dd7770000000077777700000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000007770777000007770077000007000777070707770000077707770777077707770077000000000000000000000000000c7
7c0000000000000000000000000000000700070000000700700000007000070070707000000007007000070070700700700000000000000000000000000000c7
7c0000000000000000000000000000000700070000000700777000007000070077007700000007007700070077000700777000000000000000000000000000c7
7c0000000000000000000000000000000700070000000700007000007000070070707000000007007000070070700700007007000000000000000000000000c7
7c0000000000000000000000000000007770070000007770770000007770777070707770000007007770070070707770770070000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000009999000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000099119900000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000091551900000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000091551900000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000099119900000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000009999000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000009999000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000007770707077700000707077707770707000000000099119900000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000007070707007000000707007000700707000000000091551900000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000007700707007000000707007000700777000000000091551900000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000007070707007000000777007000700707000000000099119900000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000007770077007000000777077700700707000000000009999000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000009999000099990000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000099119900991199000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000091551900915519000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000091551900915519000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000099119900991199000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000009999000099990000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c000000000000000000000000000000ddd0ddd0ddd00dd00dd000000ddddd000000ddd00dd000000dd0ddd0ddd0ddd0ddd000000000000000000000000000c7
7c000000000000000000000000000000d0d0d0d0d000d000d0000000dd000dd000000d00d0d00000d0000d00d0d0d0d00d0000000000000000000000000000c7
7c000000000000000000000000000000ddd0dd00dd00ddd0ddd00000dd0d0dd000000d00d0d00000ddd00d00ddd0dd000d0000000000000000000000000000c7
7c000000000000000000000000000000d000d0d0d00000d000d00000dd000dd000000d00d0d0000000d00d00d0d0d0d00d0000000000000000000000000000c7
7c000000000000000000000000000000d000d0d0ddd0dd00dd0000000ddddd0000000d00dd000000dd000d00d0d0d0d00d0000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000777077707770077007700000077777000000777007707770000007707770777077707770770007700770000000000000000000c7
7c0000000000000000000000707070707000700070000000770707700000700070707070000070007000070007000700707070007000000000000000000000c7
7c0000000000000000000000777077007700777077700000777077700000770070707700000077707700070007000700707070007770000000000000000000c7
7c0000000000000000000000700070707000007000700000770707700000700070707070000000707000070007000700707070700070000000000000000000c7
7c0000000000000000000000700070707770770077000000077777000000700077007070000077007770070007007770707077707700000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777

__sfx__
01010000000000005005050070500c0500e0501205000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000051003530085400955009550095500855007540055100e5000d50003500005001c3001d3001e3001f3001f3002030020300213002130020300203001d3001c3001930016300123000c3000730000200
000300000475002740007300073000710006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000030008310003000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000300006010080100b0100e010100201302015020180201a0301c0301f030210302303026040280502b0502d0503005033050350503e0203901030010280401f03019030120200c010060000000000020
