-- title:  game title
-- author: game developer
-- desc:   short description
-- script: lua
colliders = {
	-- tiles that only can be collided when falling onto them from above
	top_colliders = {
		[192]=true, [193]=true, [160]=true, [161]=true, [162]=true, [163]=true, [176]=true, [177]=true
	},
	-- completely solid tiles that cannot be moved through
	solid_colliders= {
		[160]=true, [161]=true, [162]=true, [163]=true, [176]=true, [177]=true
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
		x1,y1,x2,y2=x-1,y,x,y+h-1
		hb_w, hb_h = 1, h
	elseif aim=="right" then
		x1,y1,x2,y2=x+w,y,x+w+1,y+h-1
		hb_w, hb_h = 1, h
	elseif aim=="up" then
		x1,y1,x2,y2=x+1,y-1,x+w-1,y
		hb_w, hb_h = w, 1
	elseif aim=="down" then
		x1,y1,x2,y2=x,y+h,x+w,y+h
		hb_w, hb_h = w, 1
	end

	-- test --
	-- x_r, y_r, w_r, h_r = x1, y1, hb_w, hb_h
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


-- player
player = {
	sp=1,
	x=120,
	y=68,
	w=8,
	h=8,
	flp=0,
	dx=0,
	dy=0,
	max_dx=3,
	max_dy=3,
	acc=0.5,
	boost=4,
	anim=0,
	running=false,
	jumping=false,
	falling=false,
	sliding=false,
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
	
	--slide
	if player.running
	and not btn(2)
	and not btn(3)
	and player.landed then
		player.running=false
		player.sliding=true
	end
	
	--jump
	if btnp(4)
	and player.landed then
		player.dy = player.dy-player.boost
		player.landed=false
	end
	
	--check collision up/down
	if player.dy>0 then
		player.falling=true
		player.landed=false
		player.jumping=false
		
		player.dy=limit_speed(player.dy,player.max_dx)
		
		if collide_map(player,"down","top_colliders") then
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
		end
	elseif player.dx>0 then
		player.dx=limit_speed(player.dx,player.max_dx)
		if collide_map(player,"right","solid_colliders") then
			player.dx=0
			-- test --
			-- collide_r = "yes"
			-- else collide_r = "no"
			----------
		end
	end
	
	--stop sliding
	if player.sliding then
		if math.abs(player.dx) < .2
		or player.running then
			player.dx=0
			player.sliding=false
		end
	end
	
	player.x = player.x + player.dx
	player.y = player.y + player.dy
end

function player_anim()
	if player.jumping then
		player.sp=7
	elseif player.falling then
		player.sp=8
	elseif player.sliding then
		player.sp=9
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

	cam.x=player.x-120
	cam.y=player.y-68
	
end

function game_state:draw()
	cls(1)
	map(0, 0, 240, 136, -cam.x, -cam.y)

	-- test --
	-- print("Cam X: "..cam.x.."  Cam Y: "..cam.y, 12, 6)
	-- print("PL X: "..player.x.."  PL Y: "..player.y, 12, 12)
	-- print("DiffX: "..cam.x-player.x.."  DiffY: "..cam.y-player.y, 12, 18)
	----------
	

	spr(player.sp, player.x-cam.x, player.y-cam.y, 0, 1, player.flp)

	-- test --
	-- rect(x_r, y_r, w_r, h_r, 15)
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
-- 001:003333300066666006ef1e1006eeeee000066000006666000e0670e000600700
-- 002:003333300066666006ef1e1006eeece0006666000e0660e00006700000600700
-- 003:0003333306666666600eef1e000eeeec0e666000000660000660300000003000
-- 004:0603333360666666000eef1e000eeeec0e666000000660000063000000630000
-- 005:0003333360066666066eef1e000eeeec0e666000000660000770600000006000
-- 006:0003333360666666060eef1e000eeeec0e666000000660000036000000360000
-- 007:0003333300666666060eef1e600eeeec006660000e0660000036000003600000
-- 008:6003333306666666000eef1e000eeeec00006660000066000000063000000063
-- 009:0000000003333300066666006ef1e1006eeece00006666e00e06630000006633
-- 160:9979999979999797479779774794777447747744334447443333433747744377
-- 161:9999999999999997977977949477749474794974447744434334437473344744
-- 162:0099999909999797999777749799444499974444999444339774447397444747
-- 163:9999990079799990477999994497999974479999733999993733777933734479
-- 176:4444444443434474473443444474774444443333444733377347377477447443
-- 177:4477744447733344443347744744437743743337433443344377434444744444
-- 192:3333333377773777737777733333333377737737737777373333333300377300
-- 193:3333333377773777773777373333333377777377737777773333333300000000
-- 208:0037730000337300003773000037730000373300003773000033730000377300
-- 209:0037730000373300003773000037730000333300003773000033730000377300
-- </TILES>

-- <MAP>
-- 002:0000000000000000000000000000000000000000000000000000001c1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:00000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:00000000000000000000002a1a3a00000000000000000000001c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:000000000000002a1a0a1a1b1b1a0a3a0000000000001d001c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:0000000000002a1b1b1b1b1b1b1b0000000000001c1c0c1c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:000000000000000000000000000000000000000000001c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:00000000000000000000000000001c0c1c0c1c00001c1d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:0000000000000000000000000000001d000d001d0c001d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:0000000000000000000000000000000d001c1c0c1c1c1c1c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:0000000000000000000000000000000d0c0d001d00001d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:00000000000000000000000000001c0c1c0c1c1d00001d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:000000000000000000000000001c001d000d001d00001d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:0000000000000000002a1a3a0000000d001d001d00001d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:0a1a0a0a0a0a1a0a0a1b1b1b0a1a0a1a0a0a0a1a0a0a0a0a1a0a0a0a1a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:0b0b0b0b1b1b0b0b0b1b0b0b0b0b0b1b0b0b1b1b0b0b0b0b1b0b0b1b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 024:0000000000000000000000001b1b1b1b1b1b1b1b001b001b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 025:000000000000000000001b1b1b0000000000000000000000001b1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 026:000000000000000000001b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 027:000000000000000000001b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 028:00000000000000000000001b1b1b1b0000001b001b1b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 029:000000000000000000000000000000000000000000001b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 030:000000000000000000000000000000000000000000001b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 031:0000000000000000000000000000000000000000001b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 032:00000000000000000000000000000000001b1b1b1b1b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 033:000000000000000000001b1b001b1b1b1b1b00000000001b00001b001b1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 034:000000000000000000001b1b1b1b1b1b001b001b001b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 038:0000000000000000000000000000000000000000000000001b00001b00001b1b1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 039:0000000000000000001b1b1b001b001b0000001b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 040:0000000000001b1b1b1b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 041:00000000001b1b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 042:00000000001b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 043:0000000000001b1b1b00001b1b001b1b1b001b001b1b1b1b1b1b1b1b1b1b1b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 044:000000000000000000001b00000000000000000000000000000000000000001b1b1b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

