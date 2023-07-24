--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")

--Create the library table
local sampleNPC = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC. You can remove superfluous definitions.
local sampleNPCSettings = {
	id = npcID,
	--Sprite size
	gfxheight = 96,
	gfxwidth = 76,
	--Hitbox size. Bottom-center-bound to sprite size.
	width = 76,
	height = 96,
	--Sprite offset from hitbox for adjusting hitbox anchor on sprite.
	gfxoffsetx = 0,
	gfxoffsety = 0,
	--Frameloop-related
	frames = 5,
	framestyle = 1,
	framespeed = 4, --# frames between frame change
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
	nofireball = true,
	noiceball = true,
	noyoshi= true,
	nowaterphysics = false,
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
		--[HARM_TYPE_OFFSCREEN]=10,
		--[HARM_TYPE_SWORD]=10,
	}
);

--Custom local definitions below
local STATE_GROW = 0
local STATE_IDLE = 1

--Register events
function sampleNPC.onInitAPI()
	npcManager.registerEvent(npcID, sampleNPC, "onTickNPC")
	--npcManager.registerEvent(npcID, sampleNPC, "onTickEndNPC")
	--npcManager.registerEvent(npcID, sampleNPC, "onDrawNPC")
	--registerEvent(sampleNPC, "onNPCKill")
end

function sampleNPC.onTickNPC(v)
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
		--Initialize necessary data.
		data.initialized = true
		data.state = STATE_GROW
		data.timer = 0
		data.growTimer = 0
	end

	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		--Handling
	end
	
	--If you wanna change the length of this, go ahead, although it's a lot of trial and error. Or maybe modify the code, who's to stop ya?!
	v.despawnTimer = 180
    v:mem(0x124,FIELD_BOOL,true)
	data.timer = data.timer + 1
	v.friendly = true

	if data.state == STATE_GROW then
        if data.timer >= 15 then
            data.state = STATE_IDLE
            data.timer = 0
        end
    end
	if data.state == STATE_IDLE then
	    data.growTimer = data.growTimer + 1
		if v.direction == -1 then
			v.animationFrame = math.floor(lunatime.tick() / 8) % 1 + 4
			v.animationTimer = 0
		elseif v.direction == 1 then
			v.animationFrame = math.floor(lunatime.tick() / 8) % 1 + 9
			v.animationTimer = 0
		end
		if data.growTimer == 1 then
		    local bean = NPC.spawn(858, v.x, v.y - 64)
	        bean.direction = -1
	        bean.spawnDirection = v.direction
		end
		if data.growTimer == 5 then
		    local leaf = NPC.spawn(860, v.x - 40, v.y + 16)
	        leaf.direction = -1
	        leaf.spawnDirection = v.direction
		end
		if data.growTimer == 15 then
		    local bean = NPC.spawn(858, v.x, v.y - 128)
	        bean.direction = 1
	        bean.spawnDirection = v.direction
		end
		if data.growTimer == 20 then
		    local leaf = NPC.spawn(860, v.x + 52, v.y - 48)
	        leaf.direction = 1
	        leaf.spawnDirection = v.direction
		end
		if data.growTimer == 30 then
		    local bean = NPC.spawn(858, v.x, v.y - 192)
	        bean.direction = -1
	        bean.spawnDirection = v.direction
		end
		if data.growTimer == 35 then
		    local leaf = NPC.spawn(860, v.x - 40, v.y - 114)
	        leaf.direction = -1
	        leaf.spawnDirection = v.direction
		end
		if data.growTimer == 45 then
		    local bean = NPC.spawn(858, v.x, v.y - 256)
	        bean.direction = 1
	        bean.spawnDirection = v.direction
		end
		if data.growTimer == 50 then
		    local leaf = NPC.spawn(860, v.x + 52, v.y - 178)
	        leaf.direction = 1
	        leaf.spawnDirection = v.direction
		end
		if data.growTimer == 60 then
		    local bean = NPC.spawn(859, v.x, v.y - 320)
	        bean.direction = -1
	        bean.spawnDirection = v.direction
		end
	end
end

--Gotta return the library table!
return sampleNPC