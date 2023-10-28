local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")
local effectconfig = require("game/effectconfig")

local sampleNPC = {}

local npcID = NPC_ID

local sampleNPCSettings = {
	id = npcID,

	gfxheight = 80,
	gfxwidth = 80,

	width = 64,
	height = 64,

	gfxoffsetx = 0,
	gfxoffsety = 8,

	frames = 2,
	framestyle = 0,
	framespeed = 3.3, 

	speed = 1,

	npcblock = false,
	npcblocktop = false, 
	playerblock = false,
	playerblocktop = false, 

	nohurt=true,
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

	grabside=false,
	grabtop=false,

	ignorethrownnpcs = true,
	isinteractable=true,
}

npcManager.setNpcSettings(sampleNPCSettings)

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
		--[HARM_TYPE_OFFSCREEN]=10,
		--[HARM_TYPE_SWORD]=10,
	}
);

function effectconfig.onTick.TICK_KEY(v)
	local keyPositionx = v.x
	local keyPositiony = v.y
	
	v.x = math.lerp(keyPositionx, player.x - 290 + (player.x + 290 - keyPositionx), 0.09)
	v.y = math.lerp(keyPositiony, player.y + (player.y - keyPositiony - 96) * 4, 0.02)

	if v.timer == v.lifetime-420 then
		Effect.spawn(836, v.x-30, v.y-30)
		SFX.play(59)
	 end
end

function sampleNPC.onInitAPI()
	npcManager.registerEvent(npcID, sampleNPC, "onTickEndNPC")
	npcManager.registerEvent(npcID, sampleNPC, "onDrawNPC")
	registerEvent(sampleNPC, "onNPCKill")
end

function sampleNPC.onTickEndNPC(v)

	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if v.despawnTimer <= 0 then
		data.initialized = false
		return
	end

	if not data.initialized then
		data.initialized = true
		data.squishTimer = 23
		data.stretchTimer = 80
		data.timer = data.timer or 0
		data.rotation = 0
	end

	if v:mem(0x12C, FIELD_WORD) > 0    
	or v:mem(0x136, FIELD_BOOL)        
	or v:mem(0x138, FIELD_WORD) > 0    
	then
	    data.squishTimer = 0
		data.stretchTimer = 0
	end

	npcutils.applyLayerMovement(v)

	if Colliders.collide(player, v) then
		Section(player.section).musicID = 0
		SFX.play("yiYoshi/exit_key.ogg")
		Level.finish(LEVEL_END_STATE_SMB3ORB, true)
		Effect.spawn(834, v.x-80, v.y-90)
		Effect.spawn(835, v.x-44, v.y+20)
		SFX.play(91)
	end
end

return sampleNPC