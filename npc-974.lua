--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")

--Create the library table
local missleProjectile = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC. You can remove superfluous definitions.
local missleProjectileSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 32,
	width = 32,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 1,
	framestyle = 0,
	framespeed = 8,
	speed = 1,
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false, 

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
	ignorethrownnpcs = true
}

--Applies NPC settings
npcManager.setNpcSettings(missleProjectileSettings)

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.

--Custom local definitions below

--Register events
function missleProjectile.onInitAPI()
	npcManager.registerEvent(npcID, missleProjectile, "onTickNPC")
end

function missleProjectile.onTickNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	--If despawned
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		--Reset our properties, if necessary
		data.initialized = false
		return
	end

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		data.initialized = true
	end

	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		--Handling
	end

	local explosions = Explosion.get()
	local myExplosionID = Explosion.register(32, 780, 43, true, false)
	
	--Execute main AI.
	if v.collidesBlockBottom then
		local newExplosion = Explosion.spawn(v.x+v.width*0.5, v.y+v.height*0.5, myExplosionID)
        SFX.play(43)
		v:kill()
	end
end

--Gotta return the library table!
return missleProjectile