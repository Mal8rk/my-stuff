--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local colliders = API.load("colliders")
--Create the library table
local sampleNPC = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC. You can remove superfluous definitions.
local sampleNPCSettings = {
	id = npcID,
	gfxheight = 88,
	gfxwidth = 72,
	width = 34,
	height = 72,
	frames = 9,
	framestyle = 0,
	framespeed = 8,

	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,
	nohurt=true,
	nogravity = true,
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
}

--Applies NPC settings
npcManager.setNpcSettings(sampleNPCSettings)

npcManager.registerDefines(npcID, {NPC.UNHITTABLE})

--Register events
function sampleNPC.onInitAPI()
	npcManager.registerEvent(npcID, sampleNPC, "onTickEndNPC")
	--npcManager.registerEvent(npcID, sampleNPC, "onDrawNPC")
	--registerEvent(sampleNPC, "onNPCKill")
end

function sampleNPC.onTickEndNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	local settings = v.data._settings
	
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
	end

	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		--Handling
	end
	
		if v.isHidden or v:mem(0x12A, FIELD_WORD) <= 0 then
		v.ai1 = 0 --has depollenated?
		v.ai2 = 0 --depollenation timer
		v.ai3 = 0 --frame value
		return
	end
	
	v.friendly = true
	if v.ai1 == 0 then
		v.animationFrame = math.floor(lunatime.tick() / 8) % 4
		if Colliders.collide(v, player) then
			v.ai1 = 1
		else
			for _,p in ipairs(NPC.getIntersecting(v.x - 5, v.y - 5, v.x + v.width + 5, v.y + v.height + 5)) do
				 if p:mem(0x12A, FIELD_WORD) > 0 and p:mem(0x138, FIELD_WORD) == 0 and (not p.isHidden) and (not p.friendly) and p:mem(0x12C, FIELD_WORD) == 0 and (not NPC.config[p.id].noblockcollision) and (not NPC.config[p.id].isinteractable) then
					v.ai1 = 1
					break
				end
			end
		end
	else
		if v.ai3 < 4 then
			v.ai2 = v.ai2 + 1
			if v.ai2 % 16 == 0 then
				v.ai3 = v.ai3 + 1
				local n = NPC.spawn(npcID - 1, v.x + 0.5 * v.width, v.y + 0.3 * v.height, player.section, false, true)
				if settings.type then
					n.ai4 = 1
				end
				local sX = (v.ai3 % 2) * 2 - 1
				n.speedX = -3 * sX
				n.speedY = -5
				n.ai1 = 64
			end
		end
		v.animationTimer = 666
		v.animationFrame = 4 + v.ai3
	end
	
end

--Gotta return the library table!
return sampleNPC