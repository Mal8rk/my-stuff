--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local warpBox = require("AI/warpbox")

--Create the library table
local boxExit = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

local boxImg = Graphics.loadImage(Misc.resolveFile("warpbox.png"))
local boxExpand = 0

--Defines NPC config for our NPC. You can remove superfluous definitions.
local boxExitSettings = {
	id = npcID,
	entranceBoxNPC = 877 -- NPC_ID of the exit box NPC
}

--Applies NPC settings
npcManager.setNpcSettings(table.join(boxExitSettings, warpBox.warpBoxSharedSettings))

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

function boxExit.onDrawNPC(v)
	v.animationFrame = 0
	for k, p in ipairs(Player.get()) do
		if warpBox.inWarpBox[k] == v.data._settings.boxid and
		warpBox.warpTimer[k] <= (warpBox.warpTime/2) then
			v.animationFrame = 1
			break
		end
	end
end

--Register events
function boxExit.onInitAPI()
	npcManager.registerEvent(npcID, boxExit, "onTickNPC")
	--npcManager.registerEvent(npcID, boxExit, "onTickEndNPC")
	npcManager.registerEvent(npcID, boxExit, "onDrawNPC")
	--registerEvent(boxExit, "onNPCKill")
end

function boxExit.onTickNPC(v)
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
	
	-- exit the warp box
	for k, p in ipairs(Player.get()) do	
		if warpBox.inWarpBox[k] == data._settings.boxid then
			Graphics.glDraw{vertexCoords={	v.x - boxExpand, v.y - boxExpand,
											v.x + v.width + boxExpand, v.y - boxExpand,
											v.x - boxExpand, v.y + v.height + boxExpand, 
											v.x + v.width + boxExpand, v.y + v.height + boxExpand},
							primitive = Graphics.GL_TRIANGLE_STRIP,
							priority=1.1,
							textureCoords={0,0,1,0,0,1,1,1},
							sceneCoords = true,
							texture=boxImg}
			if boxExpand < 10 and warpBox.warpTimer[k] <= 10 then
				boxExpand = boxExpand + 1
			end
			if warpBox.warpTimer[k] <= 0 then
				boxExpand = 0
				-- warp time has expired
				warpBox.leaveBox(k)
				if data._settings.oneUseOnly then
					v:kill(HARM_TYPE_OFFSCREEN)
				end
			end
		end
	end
	
end

--Gotta return the library table!
return boxExit