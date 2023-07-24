--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

--Create the library table
local nipper = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC. You can remove superfluous definitions.
local nipperSettings = {
	id = npcID,
	gfxheight = 38,
	gfxwidth = 32,
	width = 32,
	height = 32,
	frames = 3,
	framestyle = 1,
	framespeed = 8,
	speed = 1,

	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,
	nohurt=false,
	nogravity = false,
	noblockcollision = false,
	nofireball = false,
	noiceball = false,
	noyoshi= false,
	nowaterphysics = false,
	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,

	grabside=false,
	grabtop=false,
}

local STATE_MOVE = 0
local STATE_STILL = 1

--Applies NPC settings
npcManager.setNpcSettings(nipperSettings)

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.
npcManager.registerHarmTypes(npcID,
	{
		HARM_TYPE_JUMP,
		HARM_TYPE_FROMBELOW,
		HARM_TYPE_NPC,
		HARM_TYPE_PROJECTILE_USED,
		HARM_TYPE_LAVA,
		HARM_TYPE_HELD,
		HARM_TYPE_TAIL,
		HARM_TYPE_SPINJUMP,
		HARM_TYPE_OFFSCREEN,
		HARM_TYPE_SWORD
	}, 
	{
		[HARM_TYPE_JUMP]=10,
		[HARM_TYPE_FROMBELOW]=10,
		[HARM_TYPE_NPC]=10,
		[HARM_TYPE_PROJECTILE_USED]=10,
		[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		[HARM_TYPE_HELD]=10,
		[HARM_TYPE_TAIL]=10,
		[HARM_TYPE_SPINJUMP]=10,
		[HARM_TYPE_OFFSCREEN]=10,
		[HARM_TYPE_SWORD]=10,
	}
);

--Custom local definitions below


--Register events
function nipper.onInitAPI()
	npcManager.registerEvent(npcID, nipper, "onTickEndNPC")
	--npcManager.registerEvent(npcID, nipper, "onTickEndNPC")
	--npcManager.registerEvent(npcID, nipper, "onDrawNPC")
	--registerEvent(nipper, "onNPCKill")
end

function nipper.onTickEndNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	--If despawned
	if v.despawnTimer <= 0 then
		--Reset our properties, if necessary
		data.initialized = false
		return
	end

	--Initialize
	if not data.initialized then
		data.timer = 0
		data.initialized = true
		data.state = STATE_MOVE
	end
	
	if v.isHidden or v:mem(0x12A, FIELD_WORD) <= 0 then
		v.ai1 = 0
		data.timer = 0
		return
	end

	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		--Handling
	end
	
	v.animationTimer = 666
	
	if data.timer == nil then
		data.timer = 0
	end
	
	if data.state == nil then
		data.state = STATE_STILL
	end
	
	local dirMod = 0
	if v.direction == 1 then
		dirMod = 3
	end
	
	if data.state == STATE_STILL then
		v.animationFrame = dirMod + 2
		v.speedX = 0
		data.stilltimer = data.stilltimer or 0
		data.stilltimer = data.stilltimer + 1
		if data.stilltimer == 53 then
			npcutils.faceNearestPlayer(v)
		end
		if data.stilltimer >= 64 then
			data.state = STATE_MOVE
		end
	end
	
	if data.state == STATE_MOVE then
		if v.collidesBlockBottom then
			v.animationFrame = dirMod
			v.ai1 = v.ai1 + 1
			if v.ai1 >= 6 then
				v.ai1 = 0
				v.speedY = -2
				v.speedX = 1.51 * v.direction
				data.timer = 0
			else
				v.speedX = 0
			end
		else
			
			data.timer = data.timer + 1
			if data.timer >= 0 and data.timer <=4 then
				v.animationFrame = dirMod + 1
			elseif data.timer > 4 then
				v.animationFrame = dirMod + 2
			end
		end
	end
end

--Gotta return the library table!
return nipper