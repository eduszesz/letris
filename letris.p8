pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--letris by eduszesz
-- it is like tetris, but with l

function _init()
	t=0
	rt=30
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
	cot={3,4,5,6,7,8,9,10,11,12,13,14,15,15,15}	
	--co=flr(rnd(15)+1)
	co=cot[cpi]
	p=cp[cpi]
	np=cp[flr(rnd(15)+1)]
	lines=9
	pline=9	
	level=1
	explosions={}
	grid = {}
	for i=1,11 do
		grid[i]={}
		for j=1,16 do
			grid[i][j]=0
		end
	end
end

function _update()
	t+=1
	
	if t%rt==0 then
		py+=8
	end
	
	if btn(3) then
		rt=3
	else
		rt=30	
	end
	
	if btnp(0) and px>2
		and (not check_x(-1))  then
		px-=8
	end
	
	if btnp(1) and px<(88-le())
		and (not check_x(1)) then
		px+=8
	end
	
	if btnp(5) then
		co=flr(rnd(15)+1)
		cpi+=1
		if cpi>#cp then cpi=1 end
		p=cp[cpi]
	end
	
	if btnp(4) or btnp(2) then
		p=transpose()
		p=m_multi(p)
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

	check_lines()
	fix()
	set_explosions()
	check_level()
	
end

function _draw()
	cls()
	pal(14,co)
	draw_p(p,px,py,1)
	draw_p(np,96,24,2)
	rect(0,0,127,127,7)
	rect(0,0,88,127,7)
	spr(3,px,py)
	print("lines:",96,64,8)
	print(pline,104,72,8)
	print("level:",96,80,10)
	print(level,104,88,10)
	draw_grid()
	map()
	draw_explosions()
	
	--debug
	--print_p(p,32,32)
	--print_p(grid,0,0)
	--print(px.." "..py,100,120,8)
	--print("l="..(px+le()),100,110,8)
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
	local x,y=px/8,py/8
	if (he()+py)>121 or check_y() then
		for i=1,#p do
			for j=1,#p[i] do
				if p[i][j]==1 then
					local ix,iy=x+j,y+i
					grid[ix][iy]=1
				end
			end
		end
		px,py=40,0
		p=np
		cpi=flr(rnd(15)+1)
		np=cp[cpi]
		co=cot[cpi]
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
					for m=16,1,-1 do
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

function explode(_x,_y)
	local x,y=_x*8,_y*8
	local e={x=x,y=y,t=0}
	add(explosions,e)
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
		rectfill(e.x,e.y+4+e.t,88,e.y-8-e.t,e.t)
	end
end

function check_level()
	if lines>=10 then
			level+=1
			lines=0
	end
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
