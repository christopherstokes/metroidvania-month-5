-- title:  game title
-- author: game developer
-- desc:   short description
-- script: lua
colliders = {
	-- tiles that only can be collided when falling onto them from above
	top_colliders = {
		[172]=true, [173]=true, [174]=true, [175]=true
	},
	-- completely solid tiles that cannot be moved through
	solid_colliders= {
		[160]=true, [161]=true, [162]=true, 
		[163]=true, [164]=true, [165]=true, 
		[176]=true, [177]=true, [178]=true, 
		[179]=true, [192]=true, [193]=true, 
		[194]=true, [195]=true, [180]=true, 
		[181]=true
	}
}

-- tools
function mid(a, b, c) 
    if ((a < b and b < c) or (c < b and b < a)) then
       return b
    elseif ((b < a and a < c) or (c < a and a < b)) then
       return a 
    else
       return c
	end 
end

function limit_speed(num,maximum)
	return mid(-maximum,num,maximum)
end

function lerp(a,b,t) return (1-t)*a + t*b end

function collide_map(obj,aim,flag)
	local x,y,w,h = obj.x+obj.hb.xoff,obj.y+obj.hb.yoff,obj.hb.w,obj.hb.h
	
	local x1,y1,x2,y2,hb_w,hb_h=0,0,0,0,0,0
	
	if aim=="left" then
		x1 = x-4
		y1 = y
		x2 = x-3
		y2 = y+h-2
	elseif aim=="right" then
		x1 = x+w+3
		y1 = y
		x2 = x+w+4
		y2 = y+h-2
	elseif aim=="up" then
		x1 = x
		y1 = y-1
		x2 = x+w
		y2 = y
	elseif aim=="down" then
		x1 = x
		y1 = y+h
		x2 = x+w
		y2 = y+h+1
	end

	-- test --
	-- x_r, y_r, w_r, h_r = x1, y1, x2-x1, y2-y1
	----------


	--pixels to tiles
	x1 = x1/8
	y1 = y1/8
	x2 = x2/8
	y2 = y2/8

	collider = colliders[flag]
	
	if collider[mget(x1,y1)]
	or collider[mget(x1,y2)]
	or collider[mget(x2,y1)]
	or collider[mget(x2,y2)] then
		return true
	else
		return false
	end
end

function Animation(frames, timing)
	local a = {}
	a.frames = frames
	a.timing = timing
	return a
end

entities = {}
-- Entity
function Entity(x, y, w, h, anim, hb)
	local e = {}
	e.x = x
	e.y = y
	e.w = w
	e.h = h
	e.anim = anim
	e.hb = hb
	table.insert(entities, e)
	return e
end
-----------------

-- player
player = {
	sp=1,
	x=75,
	y=0,
	w=8,
	h=8,
	flp=0,
	dx=0,
	dy=0,
	max_dx=3,
	max_dy=4,
	acc=0.5,
	boost=5,
	anim=0,
	dbl_jump=2,
	dbl_jump_max=2,
	running=false,
	jumping=false,
	falling=false,
	sliding_x=false,
	sliding_y=false,
	landed=true,
	hb={xoff=2, yoff=0, w=4, h=8}
}

function player_upd()
	--physics
	player.dy = player.dy+gravity
	player.dx = player.dx*friction
	
	--controls
	if btn(2) then
		player.dx = player.dx-player.acc
		player.flp = 1
		player.running = true
	end
	if btn(3) then
		player.dx = player.dx + player.acc
		player.flp = 0
		player.running = true
	end
	
	--slide_x
	if player.running
	and not btn(2)
	and not btn(3)
	and player.landed then
		player.running=false
		player.sliding_x=true
	end

	--jump
	if btnp(4)
	and (player.landed or (player.dbl_jump > 0 and player.jumping)) then
		if player.landed then 
			player.dy = player.dy-player.boost
		else
			player.dy = player.dy-(player.boost*.75)
		end
		player.landed = false
		player.dbl_jump = player.dbl_jump - 1
	end

	-- drop through top_collider
	if btnp(1) and player.landed 
	and collide_map(player,"down","top_colliders") then
		player.y = player.y+7
		player.landed=false
		player.falling=true
	end
	
	--check collision up/down
	if player.dy>0 then
		player.falling=true
		player.landed=false
		player.jumping=false
		
		player.dy=limit_speed(player.dy,player.max_dx)
		
		if collide_map(player,"down","top_colliders") or collide_map(player,"down","solid_colliders") then
			player.landed=true
			player.falling=false
			player.dy=0
			player.y = player.y - (((player.y+player.h+1) % 8) - 1)
			-- test --
			-- collide_d = "yes"
			-- else collide_d = "no"
			----------
		end
	elseif player.dy<0 then
		player.jumping=true
		if collide_map(player,"up","solid_colliders") then
			player.dy=0
			-- test --
			-- collide_u = "yes"
			-- else collide_u = "no"
			----------
		end		
	end
	
	--check collision l/r
	if player.dx<0 then
		player.dx=limit_speed(player.dx,player.max_dx)
		if collide_map(player,"left","solid_colliders") then
			player.dx=0
			-- test --
			-- collide_l = "yes"
			-- else collide_l = "no"
			----------

			-- if not player.landed then
			-- 	player.sliding_y = true
			-- 	player.running = false
			-- 	player.jumping = false
			-- 	player.falling = false
			-- else player.sliding_y = false	end
		end
	elseif player.dx>0 then
		player.dx=limit_speed(player.dx,player.max_dx)
		if collide_map(player,"right","solid_colliders") then
			player.dx=0
			-- test --
			-- collide_r = "yes"
			-- else collide_r = "no"
			----------

			-- if not player.landed then
			-- 	player.sliding_y = true
			-- 	player.running = false
			-- 	player.jumping = false
			-- 	player.falling = false
			-- else player.sliding_y = false end
		end
	end
	
	--stop sliding_x
	if player.sliding_x then
		if math.abs(player.dx) < .2
		or player.running then
			player.dx=0
			player.sliding_x=false
		end
	end

	if player.landed then
		player.dbl_jump = player.dbl_jump_max
	end
	
	player.x = math.floor(player.x + player.dx)
	player.y = math.floor(player.y + player.dy)
end

function player_anim()
	if player.jumping then
		player.sp=7
	elseif player.falling then
		player.sp=8
	elseif player.sliding_x then
		player.sp=9
	elseif player.sliding_y then
		player.sp=10
	elseif player.running then
		if time()-player.anim>100 then
			player.anim=time()
			player.sp = player.sp+1
			if player.sp>6 then
				player.sp=3
			end
		end
	else
		if time()-player.anim>300 then
			player.anim=time()
			player.sp = player.sp+1
			if player.sp>2 then
				player.sp=1
			end
		end
	end
end

game_state = {}

function game_state:init()
	gravity=0.3
	friction=0.85

	-- test --
	-- x_r, y_r, w_r, h_r = 0,0,0,0
	-- collide_l, collide_r, collide_u, collide_d = "no", "no", "no", "no"
	----------

	--simple camera
	cam={x=120, y=68}
end

function game_state:update()
	t=t+1
	player_anim()
	player_upd()

	if player.dx < 0 then
		cam.x=math.floor(lerp(cam.x, player.x-184, 0.05))
	elseif player.dx > 0 then
		cam.x=math.floor(lerp(cam.x, player.x-48, 0.05))
	else 
		cam.x=math.floor(lerp(cam.x, player.x-120, 0.05))
	end

	if player.dy < 0 then
		cam.y=math.floor(lerp(cam.y, player.y-96, 0.05))
	elseif player.dy > 0 then
		cam.y=math.floor(lerp(cam.y, player.y-32, 0.05))
	else
		cam.y=math.floor(lerp(cam.y, player.y-64, 0.05))
	end


	-- cam.x=math.floor(lerp(cam.x, player.x-120, 0.07))
	-- cam.y=math.floor(lerp(cam.y, player.y-64, 0.07))

	cam.x = math.max(0, cam.x)
	cam.y = math.max(0, cam.y)

	cam.x = math.min(cam.x, 1920-240)
	cam.y = math.min(cam.y, 1088-136)
end

function game_state:draw()
	cls(0)
	map(0, 0, 240, 136, -cam.x, -cam.y, 0)

	local ccx=cam.x/8+(cam.x%8==0 and 1 or 0)
	local ccy=cam.y/8+(cam.y%8==0 and 1 or 0)
	-- map(ccx-15,ccy-8,32,17,(cam.x%8)-8,(cam.y%8)-8)

	-- test --
	print("CCX: "..ccx.." CCY: "..ccy, 12, 6)
	-- print("Cam X: "..cam.x.."  Cam Y: "..cam.y, 12, 6)
	-- print("PL X: "..player.x.."  PL Y: "..player.y, 12, 12)
	-- print("DiffX: "..cam.x-player.x.."  DiffY: "..cam.y-player.y, 12, 18)
	----------
	
	spr(player.sp, (player.x-cam.x), (player.y-cam.y), 0, 1, player.flp)
	
	-- test --
	-- print("x: "..player.x..", y: "..player.y, player.x-cam.x-24, player.y-cam.y-8)
	-- rect(x_r-cam.x, y_r-cam.y, w_r, h_r, 15)
	-- print("L: "..collide_l, player.x, player.y-6)
	-- print("R: "..collide_r, player.x, player.y-12)
	-- print("U: "..collide_u, player.x, player.y-18)
	-- print("D: "..collide_d, player.x, player.y-24)
	----------
end

current_state = game_state

current_state.init()

t=0

function TIC()
	current_state.update()
	current_state.draw()	

	t=t+1
end

-- <TILES>
-- 001:0033333000bbbbb00bef1e100beeeee0000bb00000bbbb000e0b30e000b00300
-- 002:0033333000bbbbb00bef1e100beeece000bbbb000e0bb0e0000b300000b00300
-- 003:000333330bbbbbbbb00eef1e000eeeec0ebbb000000bb0000bb0300000003000
-- 004:0b033333b0bbbbbb000eef1e000eeeec0ebbb000000bb00000b3000000b30000
-- 005:00033333b00bbbbb0bbeef1e000eeeec0ebbb000000bb0000770b0000000b000
-- 006:00033333b0bbbbbb0b0eef1e000eeeec0ebbb000000bb000003b0000003b0000
-- 007:0003333300bbbbbb0b0eef1eb00eeeec00bbb0000e0bb000003b000003b00000
-- 008:b00333330bbbbbbb000eef1e000eeeec0000bbb00000bb0000000b30000000b3
-- 009:00000000033333000bbbbb00bef1e100beeece0000bbbbe00e0bb3000000bb33
-- 010:00000000033333000bbbbb0b01e1feb00eceee0000bbbbe000ebb3000000bb33
-- 160:00aaaaaa0aaaa7a7aaa77771a7aa1111aaa71711aaa11131aaaaa173aa77aa17
-- 161:aa7aaaaa7aaaa7a717a77a7717a1777117717711111117113133133711711377
-- 162:aaaaaaaaaaaaaaa7a77a77a1a17771a1717a1a71117711111331137173111111
-- 163:aaaaaa007a7aaaa0177aaaaa11a7aaaa7117aaaa133aaaaa1733777a1173117a
-- 164:131117aa11a1aaaa11117aaa11117a7a1311a177111111113311131113111111
-- 165:aa711131aaaa1a11aaa71111a7a71111771a1131111111111131113311111131
-- 172:000111cc01111acc1aa1ccccaccccaca1acccca1033333330000000000000000
-- 173:a11a1accc1aaacccccccccccccaaaaccaca11cc1333333330033330000333300
-- 174:111acca111aacccccccc111acccca11aa1ccccaa333333330000000000000000
-- 175:1aa11000ca111110cccccac1c1aaccccc111aacc333333300000000000000000
-- 176:aaaa7177aa7a1137aaaa7733aa7aa111aaa111117aaa7117aa777317aa711111
-- 177:1111111113111171113113111171111111113133111711117111117111117113
-- 178:1177711117733311111117711111131111111117113113311377111111711111
-- 179:7117aaaa111117aa137777aa117a7aaa111177aa731a17aa1717aaaa1131117a
-- 180:1311111133111311111111111311a17711117a7a11117aaa11a1aaaa131117aa
-- 181:111111311131113311111111771a1131a7a71111aaa71111aaaa1a11aa711131
-- 189:007777000a7777a000aa77000aa77aa000777a000a77aaa00077a700007a7700
-- 190:00000000000000007a7777a777777a7777777777777a777700a00a000000a000
-- 191:00777a0000a77a0000777a000077aa000077a7000077a70000a7770000777700
-- 192:aa711331aaa71111aaaa3333a7a71171aaaa1111aaaa7aa10aaaa7a700aaaaaa
-- 193:11711117173113111111771117a1a7171a17771a1a77a77a7aaaaaaaaaaaaaaa
-- 194:7731177173313331117111111117177117771a7177a77a717a7aaaa7aaaaa7aa
-- 195:1131117a13117aaa1331aa7a77117aaa117aaaaa77a7aaaa7aaaaaa0aaaaaa00
-- 205:00aa77000077a700007a7777007a7777000a777700007777000a00a00000a000
-- 206:00000000000000007a7777a7aa77a7777777a777777a7777007000000a000a00
-- 207:0077aa000077a7007777a70077777700aa7770a07aa700000000a000000000a0
-- </TILES>

-- <MAP>
-- 000:2a1a2a1a2a3a0000000000000000000000000000000000000a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a2a2a2a2a2a2a2a2a2a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:1b1b1b1b1b3b0000000000000000000000000000000000000b1b1b1b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:1b1b1b1b1b3b0000000000000000000000000000000000000b2b2b1b2b2b1c1c2c1c1c2c1c2c1c1c1c1c1c2c1c1c1c2c1c2c1c1c1c2c1c1c1c1c1c1c2c2c1c2c1c1c2c2c1c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:2b2b2b2b1b3b0000000000000000000000000000000000000b1b1b1b2b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:2b1b1b1b1b3b0000000000000000000000000000000000000b2b1b1b1b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:2b1b2b2b2b3b0000000000000000000000000000000000000b2b1b1b2b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:2b1b1b1b2b3b0000000000000000000000000000000000000b1b1b1b1b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:2b2b2b1b1b3b0000000000000000000000000000000000000b2b1b1b1b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:2b2b2b1b2b3b00caeaeadaeaeafa000000000000000000000b1b1b1b1b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:2b2b2b2b2b3b00000000db000000000000000000000000000b2b1b1b2b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:2b2b2b1b2b3b00000000fb000000000000000000000000000b1b1b1b1b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:1b2b2b1b1b3b00000000fb000000000000000000000000000b1b1b2b2b3b00000000000000000000000000000000000000000000000000000000000a1a1a1a1a1a1a1a1a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:2b2b2b1b2b3b00000000fb0000000000000000cadafa00000b1b1b1b1b3b00000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:2b2b1b2b2b3b00cadafafb000000000000000000db0000000b1b2b1b1b3b00000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:2b1b2b2b2b3bebecdbebfc0000000000caeadaeafa0000000b2b1b1b1b3b00000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:2b1b2b1b2b3b0000fb000000000000000000db00fb00000a5a1b1b1b1b3b00000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:2b2b2b1b1b3b0000fb000000000000000000fb00fb00000b1b1b1b1b1b3b00000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 017:1b2b1b2b2b3b0000caeaeadaeaeafa000000fb00fb00000b1b1b1b2b1b3b00000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 018:1b2b2b2b2b3b0000fb0000db000000000000fb00fb00000b1b2b1b1b1b3b00000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 019:2b2b2b2b2b3becebfc0000fb000000000000fb00fb00000b1b2b1b2b1b3b0000000000000000000000000000000000000d000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 020:2b1b2b2b2b3b0000000000fb00000000000a2a1a1a2a1a5a1b1b1b1b1b3b0000000000000000000000001d000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 021:2b1b1b1b1b3b00caeadaeafa00000000000b1b1b1b1b1b1b2b1b1b1b1b3b0000000000000000000000001d00000000000d000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 022:2b2b2b2b2b3b000000db00fb00000000000b1b2b1b1b1b1b1b1b2b2b1b3b0000000000000000000000001d00000000000d000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 023:2b1b1b2b2b3b000000fb00fb00000000000b1b1b1b1b2b1b1b1b1b2b1b3b0000000000000000000000000000000000000d000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 024:2b1b2b2b2b3b000000fb00fb00000000000b1b1b1b1b1b2b1b1b1b2b1b3b0000000000000000000000001d00000000000d000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 025:2b2b1b1b1b3becebecfbebfc00cadafa000b1b1b1b1b1b1b1b1b1b1b1b3b0000000000000000000000001d000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 026:1b1b1b2b2b3b000000fb00000000db00000b1b1b2b1b2b4b2c2c2c1c2c3c0000000000000000000000001d000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 027:2b2b2b2b2b3b000000fb00000000fb00000b1b1b1b1b1b3b0000000000000000000000000000000000001d000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 028:4b1c1c1c1c3c00cadafa00000000fb00000b1b2b1b1b1b3b0000000000000000000000000000000000000000000000001d000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 029:3b000000db000000dbfb00000000dceceb0b1b1b1b1b1b3b0000000000000000000000000000000000001d000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 030:3b000000fb000000fbfb000000000000000b1b1b2b1b1b3b0000000000000000000000000000000000001d000000000d00000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 031:3b000000dcebecebfcfb0000cadafa00000b1b1b2b1b1b3b0000000a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a5a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 032:3b0000000000000000fb000000db0000000b1b1b1b2b1b3b0000000b1b1b1b1b1b1b2b1b1b1b1b1b1b1b2b1b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 033:3b00caeaeadaeaeafafb000000dcebeceb0b1b1b1b1b1b3b0000000b1b1b1b2b1b1b1b1b1b1b1b2b1b1b1b2b4b2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c5b4b1c1c1c1c1c1c1c1c1c1c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 034:3b00000000db000000fb000000000000000c2c1c1c2c2c3c0000000c5b1b1b1b1b1b1b1b1b2b1b1b1b1b1b1b3b0000000000000000000000000000000000000000000000000000000000000000000000000000000b3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 035:3b00000000fb000000fb0000000000000000000000000000000000000b1b2b1b1b2b1b1b1b1b2b1b2b1b2b1b3b0000000000000000000000000000000000000000000000000000000000000000000000000000000c3c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 036:3b00000000fb000000caeadaeafa00000000000000000000cadafa000c1c1c1c2c2c5b2b1b1b1b1b1b1b2b1b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 037:3b00000000fb000000fb00db00000000000000000000000000db0000fb00000000000b1b1b1b1b1b1b1b1b1b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 038:3b00cadafafb000000fb00fb00000000000000000000000000dcecebfc00000000000c1c2c1c1c2c5b1b1b2b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 039:3b0000db00fb000000fb00fb000000000000000000000000000000000000000000000000000000000b1b2b1b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 040:3b0000fb00fb000000fb00fb000000000000000000000000000000000000000000000000000000000b2b1b1b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 041:3b0000fb00fb000000fb00fb000000000000000000000000000000000000000000000000000000000b1b2b1b3b0000000000000000000000000000000000000000000000000000000000000000000000000000000a3a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 042:3b0000fb00fb00cadafa00fb000000000000000000000000000000000000000000000000000000000b1b2b1b4a2a2a2a2a3a0000000a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a3a00000000000000000b3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 043:3b0000fb00fb0000dbfb00fb00000000000000000000000000000000000a1a1a3a000000000000000b1b1b1b1b2b2b2b1b3b0000000b1b1b2b2b1b1b1b2b2b2b2b1b1b2b2b1b1b1b1b1b2b3b00cadafa000000000b4a1a1a1a1a1a1a1a1a1a1a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 044:3b0000fb00fb0000fbfb00fb00000000000000000000000000000000000b2b2b3b000000000000000b1b1b1b4b2c2c2c2c3c0000000c2c1c2c2c2c1c2c1c2c1c1c2c2c1c1c2c2c1c2c1c1c3c0000db00000000000b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 045:3b0000fb00fb0000fbfb00fb00000000000000000000000000000000000b1b2b4a2a2a2a3a0000000b1b2b1b3b00000000000000000000000000000000000000000000000000000000fb00000000fb00000000000b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 046:3b0000fb00fb0000fbfb00fbcadafa00000000000000000000000000000c5b2b1b2b1b2b3b0000000b1b2b1b3b0000000000cadafa0000000000000000000000000000000000000000dcecebecebfc00000000000b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 047:3b0000fb00fb0000fbfb00fb00db000000000000000000caeadaeafa00000b1b1b1b1b1b3b0000000b1b1b1b3b000000000000db00000000000000000000000000000000000000000000000000000000000000000b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 048:3b0000fb00fb0000fbfb00fb00fb0000000000000000000000db000000000b1b1b2b4b2c3c0000000c2c2c2c3c000000000000fb00000000000000000000000000000000000000000000000000000000cadafa000b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 049:3b0000fb00fb0000fbfb00fb00fb0000000000000000000000fb000000000b2b1b1b3b00000000000000000000000000000000fb0000000000000000000000000000000000000000000000000000000000db00000b2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 050:4a2a1a2a2a2a2a2a1a1a2a2a2a1a2a1a2a2a2a1a2a2a2a2a1a1a2a2a2a2a5a2b1b2b3b00000000000000000000000000000000fb00000000000000000000000000000000000000caeadaeafa0000000000fb00000b2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 051:2b1b2b2b2b2b2b1b1b1b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b1b1b2b2b2b1b3b00000000000000000000000000000000fb000000000000000000000000000000000000000000db00000000000000fb00000b2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 052:2b1b2b1b1b2b2b2b2b2b1b2b2b2b1b1b2b2b2b2b1b1b2b1b1b1b1b1b2b1b1b1b2b1b3b00000000000000000000000000000000fb000000000000000000000000000000000000000000fb00000000000000fb00000b2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 053:2b2b2b2b2b2b2b1b1b1b1b2b2b2b1b2b1b2b1b1b2b1b1b2b2b1b2b2b1b1b2b2b1b1b4a2a2a1a2a2a2a2a1a1a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a1a1a1a1a1a1a1a1a5a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 054:2b2b2b1b2b2b2b2b2b2b2b2b2b1b2b2b2b1b2b2b2b2b2b2b1b1b2b1b1b2b2b2b2b1b2b2b1b1b2b2b2b2b1b2b1b1b1b1b2b2b2b1b2b1b2b1b1b1b2b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b2b2b2b2b2b2b2b2b2b2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:140c1c44243430346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6
-- </PALETTE>

-- <PALETTE1>
-- 000:140c1c44243430346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6
-- </PALETTE1>

