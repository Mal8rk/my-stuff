--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local warpBox = require("AI/warpbox")

--Create the library table
local lockBox = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC. You can remove superfluous definitions.
local lockBoxSettings = {
	id = npcID,
	entranceBoxNPC = 877, -- NPC_ID of the exit box NPC
	keyNPC = 31   -- NPC_ID of the key NPC
}

--Applies NPC settings
npcManager.setNpcSettings(table.join(lockBoxSettings, warpBox.warpBoxSharedSettings))

--Registers the category of the NPC. Options include HITTABLE, UNHITTABLE, POWERUP, COLLECTIBLE, SHELL. For more options, check expandedDefines.lua
npcManager.registerDefines(npcID, {NPC.UNHITTABLE})

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
		HARM_TYPE_OFFSCREEN,
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
		[HARM_TYPE_OFFSCREEN]=10,
		--[HARM_TYPE_SWORD]=10,
	}
);

--Custom local definitions below

--Register events
function lockBox.onInitAPI()
	npcManager.registerEvent(npcID, lockBox, "onTickNPC")
	--npcManager.registerEvent(npcID, lockBox, "onTickEndNPC")
	--npcManager.registerEvent(npcID, lockBox, "onDrawNPC")
	--registerEvent(lockBox, "onNPCKill")
end

local function transformIntoEntrance(v)
	-- transfrom into a Warp Box Entrance once unlocked
	oldSettings = v.data._settings
	v:transform(NPC.config[v.id].entranceBoxNPC)
	v.data._settings = oldSettings
	v.data.initialized = false
end

function lockBox.onTickNPC(v)
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
	
	--If hit with a key...
	for _, hitKey in ipairs(Colliders.getColliding{a = Colliders.Box(v.x, v.y, v.width, v.height), b = NPC.config[v.id].keyNPC, btype = Colliders.NPC}) do
		-- transfrom into a Warp Box Entrance
		transformIntoEntrance(v)
		-- consume the key
		hitKey:kill()
		Effect.spawn(63, hitKey.x, hitKey.y)
		SFX.play(53)
		-- if more than one key, only consume the first one
		break
	end
	
	-- Player collides while holding a key in inventory
	for k, p in ipairs(Player.get()) do
		if Colliders.collide(p, v) and player:mem(0x12, FIELD_WORD) == -1 then
			-- transform into a Warp Box Entrance
			transformIntoEntrance(v)
			-- consume the key
			player:mem(0x12, FIELD_WORD, 0)
			Effect.spawn(63, v.x+(v.width/2), v.y+(v.height/2))
			SFX.play(53)
		end
	end	
	
end

--Gotta return the library table!
return lockBox