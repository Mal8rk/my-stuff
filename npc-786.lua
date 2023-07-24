--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local imagic = require("imagic")

--Create the library table
local bowlingGoonie = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC.
local bowlingGoonieSettings = {
	id = npcID,
	gfxheight = 64,
	gfxwidth = 64,
	width = 48,
	height = 48,
	gfxoffsetx = 0,
	gfxoffsety = 8,
	frames = 1,
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
	--xspeed = 1,
	--rotspeed = 4
}

--Applies NPC settings
npcManager.setNpcSettings(bowlingGoonieSettings)

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
		[HARM_TYPE_SWORD]=deathEffect,
	}
);

--Custom local definitions below

--Sprites Drawing Logic tweaked from Basegame Grrrol AI
function drawNPCFrame(id, frame, x, y, angle)
	local settings = npcManager.getNpcSettings(id)
	local priority = -45
	
	frame = frame or 0
	
	if settings.foreground then
		priority = -15
	end
	imagic.Draw{
		texture = Graphics.sprites.npc[id].img,
		sourceWidth = settings.gfxwidth,
		sourceHeight = settings.gfxheight,
		sourceY = frame * settings.gfxheight,
		scene = true,
		x = x + settings.width  * 0.5,
		y = y + settings.height * 0.5,
		rotation = angle,
		align = imagic.ALIGN_CENTRE,
		priority = -45
	}
end

--Register events
function bowlingGoonie.onInitAPI()
	npcManager.registerEvent(npcID, bowlingGoonie, "onTickNPC")
	npcManager.registerEvent(npcID, bowlingGoonie, "onDrawNPC")
end

function bowlingGoonie.onTickNPC(v)
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
		data.angle = 0
		
		data.frame = 0
		
		data.xspeed = cfg.xspeed or 1
		data.rotspeed = cfg.rotspeed or 4
		
		if v.direction == 1 then
			data.frame = 1
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
		return
	end
	
	--Execute main AI.
	v.speedX = v.direction*data.xspeed
	
	if v.direction==-1 then
		data.angle = data.angle-data.rotspeed
	else
		data.angle = data.angle+data.rotspeed
	end
	
end

function bowlingGoonie.onDrawNPC(v)

	if v:mem(0x12A, FIELD_WORD) > 0 and not v.layerObj.isHidden and v:mem(0x124,FIELD_WORD) ~= 0 then
		v.animationFrame = 999999999
		drawNPCFrame(v.id, v.data.frame, v.x, v.y, v.data.angle)
	end
	
end

--Gotta return the library table!
return bowlingGoonie