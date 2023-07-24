local npcManager = require("npcManager")
local rng = require("rng")
local npcutils = require("npcs/npcutils")
local colliders = require("colliders")

local guys = {}
local npcIDs = {}

--*****************************************************************************************************************************
--Walking and looking code, as well as cliff detection code taken and modified from Rudeguys's Bumpties. Full credit goes to him.
--Rotation code when rolling by MrDoubleA
--*****************************************************************************************************************************

local death = Misc.resolveSoundFile("enemyDie")
local exit1 = Misc.resolveSoundFile("shyguyAppearInPipe")
local exit2 = Misc.resolveSoundFile("shyguyJumpOutOfPipe")


--Set timers and flags for different states
local walk = {
	STATE = 1,
	walkMin = 80,
	walkMax = 140,
	walkSpeed = 0.5,
}

local look = {
	STATE = 0,
	lookMin = 47,
	lookMax = 95,
}

local hurt = {
	STATE = 2,
}

local notMoving = {
	STATE = 3,
}

--Register events
function guys.register(id)
	npcManager.registerEvent(id, guys, "onTickEndNPC")
	npcIDs[id] = true
end

function guys.onInitAPI()
    registerEvent(guys, "onNPCHarm")
end

function guys.onNPCHarm(eventObj,v,reason,culprit)
	local data = v.data
	local config = NPC.config[v.id]
	if not npcIDs[v.id] then return end
	if reason == HARM_TYPE_JUMP then	
		SFX.play(death)
	elseif reason == HARM_TYPE_NPC or reason == HARM_TYPE_TAIL and data.state.current then	
		if culprit then
			if type(culprit) == "NPC" and culprit.id == 195 or culprit.id == 50 then
				return
			else
				if type(culprit) == "Player" or (type(culprit) == "NPC" and NPC.HITTABLE_MAP[culprit.id] or culprit.id == 45 and v:mem(0x138, FIELD_WORD) == 0) then -- Turn the shy guy into a rolling version
					eventObj.cancelled = true
					if not config.isMega then
						v:transform(751)
					else
						v:transform(810)
					end
					v.dontMove = false
					v.speedX = 3.5 * culprit.direction
					v.ai2 = config.colour
					if v.direction == DIR_LEFT then
						v.ai1 = config.leftRollFrame
					else
						v.ai1 = config.rightRollFrame
					end
					if type(culprit) == "NPC" and NPC.HITTABLE_MAP[culprit.id] or culprit.id == 45 and v:mem(0x138, FIELD_WORD) == 0  then
						culprit:kill()
					elseif type(culprit) == "Player" and reason == HARM_TYPE_TAIL then
						SFX.play(2)
						Animation.spawn(75, v.x, v.y)
					end
				end
			end
		else
		return
		end
	else
	return
	end
end

local function init(v, data)
	data.state = {
		current = look.STATE,
		direction = v.direction,
	}
	data.walk = {
		timer = 0,
	}
	data.look = {
		timer = 0,
	}
	data.hurt = {
		direction = 0,
	}
	data.notMoving = {
		timer = 0,
	}
	data.init = true
end

function isNearPit(v)
	--This function either returns false, or returns the direction the npc should go to. numbers can still be used as booleans.
	local testblocks = Block.SOLID.. Block.SEMISOLID.. Block.PLAYER

	local centerbox = Colliders.Box(v.x + 8, v.y, 8, 48)
	local l = centerbox
	if v.direction == DIR_RIGHT then
		l.x = l.x + 10
	end
	
	for _,centerbox in ipairs(
	  Colliders.getColliding{
		a = testblocks,
		b = l,
		btype = Colliders.BLOCK
	  }) do
		return false
	end
	
	
	return true
end

local function initLook(v, data)
	data.state.current = look.STATE
	local l = rng.randomInt(look.lookMin, look.lookMax)
	data.look.timer = l
	v.speedX = 0
end

--Functions to determine what the shy guy should do, initLook makes it look around and initWalk makes it begin walking.

local function initWalk(v, data)
	data.state.current = walk.STATE
	local w = rng.randomInt(walk.walkMin, walk.walkMax)
	data.walk.timer = w
	v.speedX = walk.walkSpeed * v.direction
end

--Function to bump the shy guy if it hits a player.
local function initPlayerHarm(v, data)
	data.state.current = hurt.STATE
	data.hurt.direction = player.x < v.x and 1 or -1
	v.speedX = data.hurt.direction * 2
	v.speedY = -3
end


--Frame stuff
local function getAnimationFrame(v)
    local data = v.data
	local config = NPC.config[v.id]
    local frame = 0
	
	if data.state.current == look.STATE or data.state.current == notMoving.STATE then
		v.ai3 = 0
		if config.lanternGhost then
			frame = math.floor(lunatime.tick() / 3) % 2
		else
			frame = 1
		end
	elseif data.state.current == walk.STATE then
		v.ai3 = v.ai3 + 1
		if not config.lanternGhost then
			frame = math.floor(v.ai3 / 3) % (config.frames - 1) + 1
		else
			frame = math.floor(v.ai3 / 3) % (config.frames - 2) + 1
		end
	elseif data.state.current == hurt.STATE then
		frame = math.floor(v.ai3)
		if v.ai3 == 0 then v.ai3 = v.ai3 + 1 end
	end
    v.animationFrame = npcutils.getFrameByFramestyle(v,{frame = frame})
end

function guys.onTickEndNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local config = NPC.config[v.id]
	local data = v.data
	
	if not data.init then
		init(v, data)
		initLook(v, data)
		data.timer = data.timer or 0
	end
	
	getAnimationFrame(v)
	
	--If despawned
	if v.despawnTimer <= 0 then
		--Reset our properties, if necessary
		data.initialized = false
		data.timer = 0
		data.rotation = nil
		return
	end

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		data.initialized = true
		initLook(v, data)
	end
	
	if v.dontMove then
		data.state.current = notMoving.STATE
	end
	
	--Pipe spawning stuff
	if v:mem(0x138, FIELD_WORD) == 4 then
		if v.ai5 == 1 then
			npcutils.faceNearestPlayer(v)
			SFX.play(exit1)
		elseif v.ai5 == 39 then
			SFX.play(exit2)
		end
		if v:mem(0x144, FIELD_WORD) == 1 then
			v.ai5 = v.ai5 + 1
			if v.ai5 <= 7 then
				v.y = v.y - 2.5
			elseif v.ai5 > 7 and v.ai5 <= 39 then
				v.y = v.y + 1
			else
				v.y = v.y - 5
			end
		elseif v:mem(0x144, FIELD_WORD) == 3 then
			v.ai5 = v.ai5 + 1
			if v.ai5 <= 7 then
				v.y = v.y + 2.5
			elseif v.ai5 > 7 and v.ai5 <= 39 then
				v.y = v.y - 1
			else
				v.y = v.y + 5
			end
		end
	end
	--Make it jump out of the pipe when spawned by a generator
	if v.ai5 >= 1 and v:mem(0x138, FIELD_WORD) == 0 then
		v.speedY = -4
		if not config.isMega then
			v.speedX = 1.5 * v.direction
		else
			v.speedX = 2 * v.direction
		end
		v.ai5 = 0
		v.ai4 = v.ai4 + 1
	else
		if v.collidesBlockBottom then --Make it resume normal behaviour when it touches the ground after spawning.
			if v.ai4 > 0 then
				initLook(v, data)
				v.ai4 = 0
			end
		end
	end
	if data.state.current == look.STATE then
		if v.collidesBlockBottom then
			data.timer = data.timer + 1
			if data.timer % 24 == 0 then
				v.direction = -v.direction
			end
			data.look.timer = data.look.timer - 1
			if data.look.timer <= 0 then
				if isNearPit(v) then
					initLook(v, data)
				else
					data.state.current = walk.STATE
					data.timer = 0
					initWalk(v, data)
				end
			end
		end
	elseif data.state.current == walk.STATE then
			data.walk.timer = data.walk.timer - 1
			--Don't go to the looking state if it's near a pit! Instead, it should keep walking to the opposite direction.
			if (data.walk.timer <= 0 and data.state.current == walk.STATE) or v.collidesBlockLeft or v.collidesBlockRight or isNearPit(v) then
				initLook(v, data)
			end
	elseif data.state.current == hurt.STATE then
		for _,p in ipairs(NPC.getIntersecting(v.x - 1, v.y - 1, v.x + v.width + 1, v.y + v.height + 1)) do
			if NPC.HITTABLE_MAP[p.id] and p:mem(0x12A, FIELD_WORD) > 0 and p:mem(0x138, FIELD_WORD) == 0 and (not p.isHidden) and (not p.friendly) and p:mem(0x12C, FIELD_WORD) == 0 and p.idx ~= v.idx then
				p:harm(HARM_TYPE_NPC)
			end
		end
		if v.collidesBlockLeft or v.collidesBlockRight or v.collidesBlockBottom then
			initLook(v, data)
		end
	elseif data.state.current == notMoving.STATE then
		data.notMoving.timer = data.notMoving.timer + 1
		if data.notMoving.timer >= RNG.random(50,70) then
			data.notMoving.timer = 0
			if v.collidesBlockBottom then
				v.speedY = -2.5
			end
		end
	end
	
	if Colliders.collide(player, v) and player.forcedState == 2 and not v.friendly and player:mem(0x140,FIELD_WORD) == 0 --[[changing powerup state]] and player.deathTimer == 0 --[[already dead]] and not Defines.cheat_donthurtme then
		initPlayerHarm(v, data)
		v.dontMove = false
	end
	
	
	--If grabbed then turn it into a rolling shy guy, more intended for MrDoubleA's playable.
	if v:mem(0x12C, FIELD_WORD) > 0 or (v:mem(0x138, FIELD_WORD) > 0 and (v:mem(0x138, FIELD_WORD) ~= 4 and v:mem(0x138, FIELD_WORD) ~= 5)) then
		initLook(v, data)
		if not config.isMega then
			v:transform(751)
		else
			v:transform(810)
		end
		v.ai2 = config.colour
		if v.direction == DIR_LEFT then
			v.ai1 = config.leftRollFrame
		else
			v.ai1 = config.rightRollFrame
		end
	end
	
end

return guys