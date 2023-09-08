--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")

--Create the library table
local sampleNPC = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Table that affects the offset of the spear from the spear guy. Change how you like but be warned that it could look strange if you don't know what you're doing.
local offsetX = {
4, 
4,
4,
5,
5,
6,
9,
3,
5,
9,
11,
13,
15,
17,
3,
3,
3,
}

--Defines NPC config for our NPC. You can remove superfluous definitions.
local sampleNPCSettings = {
	id = npcID,
	--Sprite size
	gfxheight = 32,
	gfxwidth = 14,
	--Hitbox size. Bottom-center-bound to sprite size.
	width = 14,
	height = 32,
	--Sprite offset from hitbox for adjusting hitbox anchor on sprite.
	gfxoffsetx = 0,
	gfxoffsety = 0,
	--Frameloop-related
	frames = 2,
	framestyle = 0,
	framespeed = 8, --# frames between frame change
	--Movement speed. Only affects speedX by default.
	speed = 1,
	--Collision-related
	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = false, --Also handles other NPCs walking atop this NPC.

	nohurt=false,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi= true,
	nowaterphysics = true,
	--Various interactions
	jumphurt = true, --If true, spiny-like
	spinjumpsafe = true, --If true, prevents player hurt when spinjumping
	harmlessgrab = false, --Held NPC hurts other NPCs if false
	harmlessthrown = false, --Thrown NPC hurts other NPCs if false

	grabside=false,
	grabtop=false,

	ignorethrownnpcs=true,
}

--Applies NPC settings
npcManager.setNpcSettings(sampleNPCSettings)

--Register events
function sampleNPC.onInitAPI()
	npcManager.registerEvent(npcID, sampleNPC, "onTickEndNPC")
end

function sampleNPC.onTickEndNPC(v)

	local data = v.data

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		data.initialized = true
		data.offSetX = data.offSetX or 1 
	end
	
	if not data.owner.isValid then
		v:kill(HARM_TYPE_NPC)
	else
		v.direction = data.owner.direction
		v.despawnTimer = data.owner.despawnTimer
		if v.despawnTimer <= 0 then v:kill(HARM_TYPE_NPC) end
		
		--Make it friendly so it doesnt hurt the player unfairly
		if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
		or v:mem(0x136, FIELD_BOOL)        --Thrown
		or v:mem(0x138, FIELD_WORD) > 0    --Contained within
		or data.owner:mem(0x138, FIELD_WORD) == 5	--On Yoshi's tongue
		or data.owner:mem(0x138, FIELD_WORD) == 6	--In Yoshi's mouth
		then
			v.friendly = true
		else
			v.friendly = false
		end
		
		--Animation stuff
		if data.owner:mem(0x138, FIELD_WORD) == 6	--In Yoshi's mouth
		then
			v.animationFrame = -50
		else
			if v.ai1 == 0 then
				v.animationFrame = 0
			else
				v.animationFrame = 1
			end
		end
		
		if not data.owner.data.isBeingThrown then
			if data.owner.animationFrame > 16 then
				data.offSetX = data.owner.animationFrame + 1 - 17
			else
				data.offSetX = data.owner.animationFrame + 1
			end
		end
		
		--Offset it a bit depending on where the spear guy is looking - so that it stays connected to the sprite
		v.x = (data.owner.x + 24 - ((v.direction + 1) * 8)) + (offsetX[data.offSetX] - math.floor((1 + v.direction) * 8)) * v.direction
		--Formula to keep them in the correct spot
		local r = v.ai1 * 32 - (32 * v.ai2)
		v.y = (data.owner.y + r) - 8
	end
end

--Gotta return the library table!
return sampleNPC