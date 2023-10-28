--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

--Create the library table
local sampleNPC = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC. You can remove superfluous definitions.
local sampleNPCSettings = {
	id = npcID,
	--Sprite size
	gfxheight = 32,
	gfxwidth = 32,
	--Hitbox size. Bottom-center-bound to sprite size.
	width = 32,
	height = 32,
	--Sprite offset from hitbox for adjusting hitbox anchor on sprite.
	gfxoffsetx = 0,
	gfxoffsety = 2,
	--Frameloop-related
	frames = 4,
	framestyle = 0,
	framespeed = 8, --# frames between frame change
	--Movement speed. Only affects speedX by default.
	speed = 1,
	--Collision-related
	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = false, --Also handles other NPCs walking atop this NPC.

	nohurt=true,
	nogravity = false,
	noblockcollision = false,
	nofireball = true,
	noiceball = true,
	noyoshi= false,
	nowaterphysics = true,
	--Various interactions
	jumphurt = true, --If true, spiny-like
	spinjumpsafe = false, --If true, prevents player hurt when spinjumping
	harmlessgrab = false, --Held NPC hurts other NPCs if false
	harmlessthrown = false, --Thrown NPC hurts other NPCs if false

	grabside=false,
	grabtop=false,

	value = 1,
	ignorethrownnpcs = true,
	notcointransformable = true,
	isinteractable=true,
}

--Applies NPC settings
npcManager.setNpcSettings(sampleNPCSettings)

--Register events
function sampleNPC.onInitAPI()
	npcManager.registerEvent(npcID, sampleNPC, "onTickEndNPC")
end

local coinsPointer = 0x00B2C5A8
local livesPointer = 0x00B2C5AC
local function addCoins(amount)
    mem(coinsPointer,FIELD_WORD,(mem(coinsPointer,FIELD_WORD)+amount))

    if mem(coinsPointer,FIELD_WORD) >= 100 then
        if mem(livesPointer,FIELD_FLOAT) < 99 then
            mem(livesPointer,FIELD_FLOAT,(mem(livesPointer,FIELD_FLOAT)+math.floor(mem(coinsPointer,FIELD_WORD)/100)))
            SFX.play(15)

            mem(coinsPointer,FIELD_WORD,(mem(coinsPointer,FIELD_WORD)%100))
        else
            mem(coinsPointer,FIELD_WORD,99)
        end
    end
end

function sampleNPC.onTickEndNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	local config = NPC.config[v.id]

	--If despawned
	if v.despawnTimer <= 0 then
		--Reset our properties, if necessary
		data.initialized = false
		return
	end

	if not data.initialized then
		--Initialize necessary data.
		data.initialized = true
		data.timeLeft = 256
		data.spawning = 0
	end

	v.despawnTimer = 180
    v:mem(0x124,FIELD_BOOL,true)

	if v.collidesBlockBottom then
		v.speedY = -4
	end

	data.timeLeft = data.timeLeft - 1
	if data.timeLeft <= 0 then
		v:kill(HARM_TYPE_VANISH)
	end
	if data.timeLeft > 32 or data.timeLeft%2 == 0 then
		v.animationFrame = math.floor(lunatime.tick() / 8) % 4
	else
		v.animationFrame = -999
	end

	if data.spawning <= 10 then
		v.speedX = config.speed*RNG.randomInt(1,1.2,1.3)*v.direction
		v.speedY = -RNG.random(3,6)
		data.spawning = data.spawning + 1
	end

    if Colliders.collide(player, v) and not v.friendly and not Defines.cheat_donthurtme then

		if config.value then
			addCoins(config.value)
		end

		v:kill(HARM_TYPE_VANISH)
		Effect.spawn(765, v.x+16, v.y+16)
		SFX.play(14)
	end
end
--Gotta return the library table!
return sampleNPC