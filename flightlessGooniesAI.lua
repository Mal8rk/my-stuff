local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local flightlessGoonie = {}

local npcIDs = {}

flightlessGoonie.VULNERABLE_HARM_TYPE = {
		HARM_TYPE_JUMP,
		HARM_TYPE_FROMBELOW,
		HARM_TYPE_NPC,
		HARM_TYPE_PROJECTILE_USED,
		HARM_TYPE_LAVA,
		--HARM_TYPE_HELD,
		HARM_TYPE_TAIL,
		HARM_TYPE_SPINJUMP,
		--HARM_TYPE_OFFSCREEN,
		HARM_TYPE_SWORD
	}
	
flightlessGoonie.HARM_TYPE_EFFECT_MAP = {
		[HARM_TYPE_JUMP]=753,
		[HARM_TYPE_FROMBELOW]=10,
		[HARM_TYPE_NPC]=753,
		[HARM_TYPE_PROJECTILE_USED]=753,
		[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		--[HARM_TYPE_HELD]=10,
		[HARM_TYPE_TAIL]=10,
		[HARM_TYPE_SPINJUMP]=10,
		--[HARM_TYPE_OFFSCREEN]=10,
		[HARM_TYPE_SWORD]=10,
	}

function flightlessGoonie.onInitAPI()
	registerEvent(flightlessGoonie, "onNPCKill")
end

function flightlessGoonie.registerNPC(id)
	npcManager.registerEvent(id, flightlessGoonie, "onTickNPC")
	npcManager.registerEvent(id, flightlessGoonie, "onDrawNPC")
	npcIDs[id]=true
end

function flightlessGoonie.onTickNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	local cfg = NPC.config[v.id]
	
	--If despawned
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		--Reset our properties, if necessary
		data.initialized = false
		return
	end

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		
		data.friendly = v.friendly
		
		data.ready = false
		
		data.delay = 1
		
		if v.fall==nil then --Not released from Flying Goonies
			data.timer = 0
			data.isbounced = true
			v.friendly = data.friendly
		else
			data.timer = 5
			data.isbounced = false
			v.friendly = true
		end
		
		data.defeatsoundID = cfg.defeatsoundID
		
		data.xspeed = cfg.xspeed or 4
		
		data.initialized = true
	end

	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		--Handling
	end
	
	
	--Execute main AI. This template just jumps when it touches the ground.
	if v.collidesBlockBottom and data.delay>0 then
		if not data.isbounced then
			data.isbounced = true
			v.speedY = -4
			SFX.play(3)
			
			if not data.friendly and v.friendly then
				v.friendly = false
			end
		else
			data.delay = data.delay-1
		end
		
	end
	
	if data.delay<=0 then
		v.speedX = v.direction*data.xspeed
		data.timer = data.timer+1
	end
end

function flightlessGoonie.onDrawNPC(v)
	local data = v.data
	local f = 0
	
	local delay = data.delay or 0
	local timer = data.timer or 0
	
	if delay<=0 then
		f = math.floor(timer/3)%3
	end
	
	v.animationFrame = npcutils.getFrameByFramestyle(v, {frame=f})
end

function flightlessGoonie.onNPCKill(eventObj,v,killReason)
	if not npcIDs[v.id] then return end
	
	local defeatsound = v.data.defeatsoundID
	
	if defeatsound == nil then return end
	--Play Proper SFX
	SFX.play(defeatsound)
end

return flightlessGoonie