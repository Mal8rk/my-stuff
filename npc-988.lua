--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local utils = require("npcs/npcutils")
local AI = require("customExit")
local imagic = require("imagic")
local effectconfig = require("game/effectconfig")

--Create the library table
local sampleNPC = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC. You can remove superfluous definitions.
local sampleNPCSettings = {
	id = npcID,
	--Sprite size
	gfxwidth = 64,
	gfxheight = 64,
	--Hitbox size. Bottom-center-bound to sprite size.
	width = 32,
	height = 32,
	--Sprite offset from hitbox for adjusting hitbox anchor on sprite.
	gfxoffsetx = 0,
	gfxoffsety = 16,
	--Frameloop-related
	frames = 1,
	framestyle = 0,
	framespeed = 7, --# frames between frame change
	--Movement speed. Only affects speedX by default.
	speed = 1,
	--Collision-related
	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = false, --Also handles other NPCs walking atop this NPC.

	nohurt=true,
	nogravity = true,
	noblockcollision = true,
	nofireball = false,
	noiceball = false,
	noyoshi= false,
	nowaterphysics = true,
	--Various interactions
	jumphurt = false, --If true, spiny-like
	spinjumpsafe = false, --If true, prevents player hurt when spinjumping
	harmlessgrab = false, --Held NPC hurts other NPCs if false
	harmlessthrown = false, --Thrown NPC hurts other NPCs if false

	grabside=false,
	grabtop=false,

	--Identity-related flags. Apply various vanilla AI based on the flag:
	--iswalker = false,
	--isbot = false,
	--isvegetable = false,
	--isshoe = false,
	--isyoshi = false,
	--isinteractable = false,
	--iscoin = false,
	--isvine = false,
	--iscollectablegoal = false,
	--isflying = false,
	--iswaternpc = false,
	--isshell = false,

	--Emits light if the Darkness feature is active:
	--lightradius = 100,
	--lightbrightness = 1,
	--lightoffsetx = 0,
	--lightoffsety = 0,
	--lightcolor = Color.white,

	--Define custom properties below
}

--Applies NPC settings
npcManager.setNpcSettings(sampleNPCSettings)

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.
npcManager.registerHarmTypes(npcID,
	{
		--HARM_TYPE_JUMP,
		--HARM_TYPE_FROMBELOW,
		--HARM_TYPE_NPC,
		--HARM_TYPE_PROJECTILE_USED,
		--HARM_TYPE_LAVA,
		--HARM_TYPE_HELD,
		--HARM_TYPE_TAIL,
		--HARM_TYPE_SPINJUMP,
		--HARM_TYPE_OFFSCREEN,
		--HARM_TYPE_SWORD
	}, 
	{
		--[HARM_TYPE_JUMP]=10,
		--[HARM_TYPE_FROMBELOW]=10,
		--[HARM_TYPE_NPC]=10,
		--[HARM_TYPE_PROJECTILE_USED]=10,
		--[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		--[HARM_TYPE_HELD]=10,
		--[HARM_TYPE_TAIL]=10,
		--[HARM_TYPE_SPINJUMP]=10,
		[HARM_TYPE_OFFSCREEN]={id=752, xoffset=1.5, yoffset=1.5},
		--[HARM_TYPE_SWORD]=10,
	}
);

AI.register(npcID)

--Register events
function sampleNPC.onInitAPI()
	npcManager.registerEvent(npcID, sampleNPC, "onTickEndNPC")
	--npcManager.registerEvent(npcID, sampleNPC, "onTickEndNPC")
	npcManager.registerEvent(npcID, sampleNPC, "onDrawNPC")
	registerEvent(sampleNPC, "onNPCHarm")
end

function sampleNPC.onTickEndNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	--If despawned
	if v.despawnTimer <= 0 then
		--Reset our properties, if necessary
		data.initialized = false
		data.turnTimer = 0
		data.turnDirection = v.direction
		return
	end

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		data.initialized = true
		
		data.turnTimer = 0
		data.turnDirection = v.direction
		
		data.dirFrame = 0
		
		data.scale = 0
	end

	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		v.animationTimer = 1
	end
	
	--Execute main AI. This template just jumps when it touches the ground.
	if v.direction == 1 then
		data.dirFrame = sampleNPCSettings.frames
	else
		data.dirFrame = 0
	end
	
	if Colliders.collide(player, v) then
		v:kill(HARM_TYPE_OFFSCREEN)
	end

	v.speedY = math.cos(lunatime.tick() / 10) * 0.8
	
	for _,z in ipairs(NPC.getIntersecting(v.x, v.y, v.x + v.width, v.y + v.height)) do
		if Colliders.collide(z, v) and z.id == 208 then
			v.animationTimer = 1
		end
	end
end

function sampleNPC.onDrawNPC(v)
	local data = v.data
	
	if data.scale ~= nil then
		utils.restoreAnimation(v)
		imagic.Draw{
			texture = Graphics.sprites.npc[v.id].img,
			width = sampleNPCSettings.gfxwidth + data.scale,
			height = sampleNPCSettings.gfxheight + data.scale,
			sourceWidth = sampleNPCSettings.gfxwidth,
			sourceHeight = sampleNPCSettings.gfxheight,
			sourceY = sampleNPCSettings.gfxheight * v.animationFrame,
			scene = true,
			x = v.x + (v.width / 2) + sampleNPCSettings.gfxoffsetx,
			y = v.y + (v.height / 2) + sampleNPCSettings.gfxoffsety,
			align = 2,
			rotation = data.turnTimer,
			priority = -45
		}
		utils.hideNPC(v)
	end
end

function sampleNPC.onNPCHarm(eventObj, v, type, culprit)
	if v.id ~= npcID then return end
	
	if type ~= HARM_TYPE_OFFSCREEN then
		eventObj.cancelled = true
	end
end
--Gotta return the library table!
return sampleNPC