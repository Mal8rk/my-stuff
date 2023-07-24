--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local gooniesAI = require("gooniesAI")

--Create the library table
local goonieCarrier = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC.
local goonieCarrierSettings = {
	id = npcID,
	gfxheight = 36,
	gfxwidth = 130,
	width = 32,
	height = 20,
	gfxoffsetx = 6,
	gfxoffsety = 10,
	frames = 3,
	framestyle = 1,
	framespeed = 8,
	speed = 1,
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = true,
	nohurt=false,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi= false,
	nowaterphysics = false,
	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,

	--NPC Specific Properties
	xspeed = 1.5,
	--xoffset = 0,
	activerange = 80,
	--basegoonieid = 751, --Base Goonie ID, Default to npcID-1. Uncomment this and set manually otherwise.
	--winglessid = 753, --Wingless Goonie ID, default being npcID+1. Uncomment this and set manually otherwise.
}

--Applies NPC settings
npcManager.setNpcSettings(goonieCarrierSettings)

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
		--HRM_TYPE_OFFSCREEN,
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
		[HARM_TYPE_SWORD]=10,
	}
);

--Custom local definitions below


--Register events
function goonieCarrier.onInitAPI()
	npcManager.registerEvent(npcID, goonieCarrier, "onTickNPC")
	gooniesAI.registerCarrierDrawEvent(npcID)
	gooniesAI.registerHarmEvent(npcID,NPC.config[npcID].winglessid or npcID+1)
end

function goonieCarrier.onTickNPC(v)
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
		--v.ai1 = 1
		
		data.baseGoonieID = cfg.basegoonieid or npcID-1
		
		data.xoffset = cfg.xoffset or 0
		
		if v.ai1 == 0 then
			v:transform(data.baseGoonieID)
			return
		end
		
		data.activerange = cfg.activerange or 80
		
		data.xspeed = cfg.xspeed or 1.5
		
		data.npcyoffset = NPC.config[v.ai1].gfxheight
		if data.npcyoffset==0 then
			data.npcyoffset = NPC.config[v.ai1].height
		end
		
		npcutils.faceNearestPlayer(v)
		
		data.initialized = true
	end

	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		--Handling
	end
	
	--Execute main AI.
	v.speedX = v.direction * data.xspeed
	v.speedY = 0.15
	
	local player = npcutils.getNearestPlayer(v)
	
	if math.abs(player.x-v.x)<data.activerange then
		gooniesAI.dropNPC(v.ai1,v.x+16+data.xoffset,v.y+data.npcyoffset,v.direction,v.section);
		v.ai1 = 0
		
		v:transform(data.baseGoonieID)
		v.data.initialized = false
		v.data.state = 1
		
	end
end

--Gotta return the library table!
return goonieCarrier