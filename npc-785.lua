--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local gooniesAI = require("gooniesAI")

--Create the library table
local heftyGoonie = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC. You can remove superfluous definitions.
local heftyGoonieSettings = {
	id = npcID,
	gfxheight = 114,
	gfxwidth = 88,
	width = 48,
	height = 48,
	gfxoffsetx = 4,
	gfxoffsety = 18,
	frames = 9,
	framestyle = 1,
	framespeed = 8,
	speed = 1,
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = true,

	nohurt=false,
	nogravity = false,
	noblockcollision = false,
	nofireball = true,
	noiceball = true,
	noyoshi= true,
	nowaterphysics = false,

	jumphurt = false, 
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,

	--NPC Specific Properties
	xspeed = 1.5,
	--winglessid = 758 --Wingless Goonie ID, default being npcID+1. Uncomment this and set manually otherwise.
}

--Applies NPC settings
npcManager.setNpcSettings(heftyGoonieSettings)

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.
npcManager.registerHarmTypes(npcID,
	{
		--HARM_TYPE_JUMP,
		--HARM_TYPE_FROMBELOW,
		HARM_TYPE_NPC,
		--HARM_TYPE_PROJECTILE_USED,
		HARM_TYPE_LAVA,
		--HARM_TYPE_HELD,
		--HARM_TYPE_TAIL,
		--HARM_TYPE_SPINJUMP,
		--HARM_TYPE_OFFSCREEN,
		HARM_TYPE_SWORD
	}, 
	{
		--[HARM_TYPE_JUMP]=10,
		--[HARM_TYPE_FROMBELOW]=10,
		[HARM_TYPE_NPC]=753,
		--[HARM_TYPE_PROJECTILE_USED]=10,
		[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		--[HARM_TYPE_HELD]=10,
		--[HARM_TYPE_TAIL]=10,
		--[HARM_TYPE_SPINJUMP]=10,
		--[HARM_TYPE_OFFSCREEN]=10,
		[HARM_TYPE_SWORD]=753,
	}
);

--Custom local definitions below
local STATE_GROUND = 0
local STATE_JUMP = 1

--Register events
function heftyGoonie.onInitAPI()
	npcManager.registerEvent(npcID, heftyGoonie, "onTickNPC")
	--npcManager.registerEvent(npcID, heftyGoonie, "onTickEndNPC")
	npcManager.registerEvent(npcID, heftyGoonie, "onDrawNPC")
	--registerEvent(heftyGoonie, "onNPCKill")
	gooniesAI.registerHarmEvent(npcID,NPC.config[npcID].winglessid or npcID+1)
end

function heftyGoonie.onTickNPC(v)
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
		data.delay = 0
		
		data.state = STATE_JUMP
		
		data.frame = 0
		
		data.timer = 0 --animation timer
		
		data.xspeed = cfg.xspeed or 1.5
		
		npcutils.faceNearestPlayer(v)
		
		v.speedX = v.direction*data.xspeed
		
		v.ai1 = 0
		
		
		
		data.initialized = true
	end

	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		--Handling
		if not data.isholding then
			data.isholding = true
		end
		return
	else
		if data.isholding then
			data.isholding = false
		end
	end
	
	--Execute main AI.
	data.timer = data.timer+1
	
	if data.state==STATE_JUMP and v.collidesBlockBottom then
		data.state = STATE_GROUND
		v.speedX = 0
		data.delay = 10
		data.timer = 0
	elseif data.state == STATE_GROUND then
		if data.delay > 0 then
			data.delay = data.delay-1
		else
			data.state = STATE_JUMP
			v.speedX = v.direction*data.xspeed
			v.speedY = -9
			
		end
		
	end
end

function heftyGoonie.onDrawNPC(v)

	if v:mem(0x12A, FIELD_WORD) <= 0 then return end

	local data = v.data
	
	if data.isholding or data.frame == nil then 
		v.animationFrame = npcutils.getFrameByFramestyle(v, {frame=0})
	return end
	
	local timer = data.timer or 0
	
	if v.speedY > 0 then
			if timer%2==0 then
				if data.frame~=3 then
					data.frame = (data.frame+1)%9
				end
			end
	else
			data.frame = math.floor(timer/2)%9
	end
	
	v.animationFrame = npcutils.getFrameByFramestyle(v, {frame=data.frame})
end

--Gotta return the library table!
return heftyGoonie