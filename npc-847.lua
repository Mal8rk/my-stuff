--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")

--Create the library table
local spore = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID
local rad, sin, cos, pi = math.rad, math.sin, math.cos, math.pi

--Defines NPC config for our NPC. You can remove superfluous definitions.
local sporeSettings = {
	id = npcID,
	gfxheight = 52,
	gfxwidth = 32,
	width = 16,
	height = 16,
	frames = 5,
	framestyle = 0,
	framespeed = 8,
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,

	nohurt=false,
	nogravity = true,
	noblockcollision = false,
	nofireball = false,
	noiceball = false,
	noyoshi= false,
	nowaterphysics = false,
	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,
	
	grabside=false,
	grabtop=false,
}

--Applies NPC settings
npcManager.setNpcSettings(sporeSettings)

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.
npcManager.registerHarmTypes(npcID,
	{
		--HARM_TYPE_JUMP,
		--HARM_TYPE_FROMBELOW,
		HARM_TYPE_NPC,
		HARM_TYPE_PROJECTILE_USED,
		HARM_TYPE_LAVA,
		HARM_TYPE_HELD,
		HARM_TYPE_TAIL,
		--HARM_TYPE_SPINJUMP,
		HARM_TYPE_OFFSCREEN,
		HARM_TYPE_SWORD
	}, 
	{
		--[HARM_TYPE_JUMP]=10,
		--[HARM_TYPE_FROMBELOW]=10,
		[HARM_TYPE_NPC]=10,
		[HARM_TYPE_PROJECTILE_USED]=10,
		[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		[HARM_TYPE_HELD]=10,
		[HARM_TYPE_TAIL]=10,
		--[HARM_TYPE_SPINJUMP]=10,
		[HARM_TYPE_OFFSCREEN]=10,
		[HARM_TYPE_SWORD]=10,
	}
);

--Register events
function spore.onInitAPI()
	npcManager.registerEvent(npcID, spore, "onTickEndNPC")
end

function spore.onTickEndNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	local settings = v.data._settings
	local maxFrame = 4
	local minFrame = 0
	data.booleanTimer = data.booleanTimer or false
	
	--If despawned
	if v.despawnTimer <= 0 then
		--Reset our properties, if necessary
		data.initialized = false
		return
	end

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		data.initialized = true
		data.originalDirection = v.direction
		v.ai2 = 0
		v.ai3 = 0
		v.ai4 = v.ai4 or 0
	end

	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		--Handling
	end

	v.speedY = 1.21
	data.w = pi/65
	data.timer = data.timer or 0
	data.timer = data.timer + 1
	
	data.spawned = data.spawned or npcID - 1
	if settings.type or v.ai4 > 0 then
		data.spawned = npcID + 2
	end

	v.ai2 = v.ai2 + 1
	v.animationFrame = v.ai3
	
	if v.ai1 <= 0 then
		v.speedX = -16 * data.w * cos(data.w*data.timer)
		if v.ai2 % 8 == 0 then
			if v.x > v.spawnX and v.ai3 ~= maxFrame then
				v.ai3 = v.ai3 + 1
			elseif v.x < v.spawnX and v.ai3 ~= minFrame then
				v.ai3 = v.ai3 - 1
			end
		end
	else
		v.ai1 = v.ai1 - 1
		if v.ai2 % 8 == 0 then
			if data.booleanTimer == true then 
				v.ai3 = v.ai3 + 1
			else
				v.ai3 = v.ai3 - 1
			end
		end
		if v.animationFrame == maxFrame then
			data.booleanTimer = false
		elseif v.animationFrame == minFrame then
			data.booleanTimer = true
		end
	end
	
	if v.collidesBlockBottom then
		v.direction = v.data.originalDirection
		v:transform(data.spawned)
		Effect.spawn(npcID, v.x - 44, v.y - 44)
		SFX.play("shyGuyJumpOutOfPipe.wav")
		v.y = v.y - 2 * v.speedY
	end
	
	if v:mem(0x136, FIELD_WORD) or v:mem(0x12C, FIELD_WORD) > 0 or v:mem(0x138, FIELD_WORD) > 0 then
	v.speedX = v.speedX * 0.9
		if math.abs(v.speedX) < 0.1 then
			v.speedX = 0
		end
	v.speedY = math.min(v.speedY + 0.1, 1)
	v.spawnX = v.x
	end
end

--Gotta return the library table!
return spore