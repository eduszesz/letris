pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--letris by eduszesz
--another tetris clone

function _init()
	t=0
	rt=30
	px=16
	py=16
	cpi=1
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
	co=flr(rnd(15)+1)
	p=cp[1]
end

function _update()
	t+=1
	
	if t%rt==0 then
		py+=8
	end
	
	if btn(3) then
		rt=4
	else
		rt=30	
	end
	
	if btnp(0) and px>2 then
		px-=8
	end
	
	if btnp(1) and px<(88-le()) then
		px+=8
	end
	
	if btnp(5) then
		co=flr(rnd(15)+1)
		cpi+=1
		if cpi>#cp then cpi=1 end
		p=cp[cpi]
	end
	
	if btnp(4) then
		p=transpose()
		p=m_multi(p)
		if (px+le())>88 then
			px-=px+le()-88
		end
	end
	
end

function _draw()
	cls()
	pal(14,co)
	draw_p(p)
	rect(0,0,127,127,7)
	rect(0,0,88,127,7)
	spr(3,px,py)
	fix()
	map()
	
	--debug
	--print_p(p,32,32)
	--print_p(m_multi(p),100,100)
	--print(px.." "..py,100,120,8)
	--print("l="..(px+le()),100,110,8)
end

function draw_p(_p)
	local p=_p
	for i=1,#p do
		for j=1,#p[i] do
			if p[i][j]==1 then
				spr(1,px+(j-1)*8,py+(i-1)*8)
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
				print(p[i][j],x+(i-1)*8,y+(j-1)*8)
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
	if (he()+py)>120 then
		for i=1,#p do
			for j=1,#p[i] do
				if p[i][j]==1 then
					mset(x+(j-1),y+(i-1),2)
				end
			end
		end
		px,py=40,8
		p=cp[flr(rnd(15)+1)]
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
