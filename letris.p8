pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--letris by eduszesz
--another tetris clone

function _init()
	t=0
	px=16
	py=16
	p={{1,1},{1,0},{1,0}}
	p1={{1,0},{1,1},{1,0}}
	p2={{0,1},{1,1,1}}
	co=flr(rnd(15)+1)
	pt={}
end

function _update()
	t+=1
	
	if btnp(5) then
		co=flr(rnd(15)+1)
	end
	
	if btnp(4) then
		p=transpose()
		p=m_multi(p)
	end
	
end

function _draw()
	cls()
	pal(14,co)
	draw_p(p)
	rect(0,0,127,127,7)
	rect(0,0,88,127,7)
	spr(3,px,py)
	
	print_p(p,32,32)
	print_p(m_multi(p),100,100)
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
	local res = {}
	for i=1, #p[1] do
		res[i]={}
		for j=1, #p do
			res[i][j] = p[j][i]
		end
	end
	pt=res
	return res
end

function m_multi(_p)
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
__gfx__
000000000000000000000000c000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000eeee000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000ee11ee00661166000c00c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000e1551e006155160000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000e1551e006155160000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000ee11ee00661166000c00c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000eeee000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000c000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
