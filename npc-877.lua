--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local warpBox = require("AI/warpbox")
local imagic = require("imagic")

--Create the library table
local boxEntrance = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

local boxImg = Graphics.loadImage(Misc.resolveFile("warpbox.png"))
local boxExpand = 0
local boxBounce = 0

--Defines NPC config for our NPC. You can remove superfluous definitions.
local boxEntranceSettings = {
	id = npcID,

	--Define custom properties below
	exitBoxNPC = 878 -- NPC_ID of the exit box NPC
}

local function findMyExit(entrance)
	exitBoxNPC_ID = NPC.config[entrance.id].exitBoxNPC
	for k, v in ipairs(NPC.get(exitBoxNPC_ID, -1)) do	
		if v.data._settings.boxid == entrance.data._settings.boxid then
			myExit = v
			break
		end
	end
	return myExit
end

--Applies NPC settings
npcManager.setNpcSettings(table.join(boxEntranceSettings, warpBox.warpBoxSharedSettings))

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
function boxEntrance.onInitAPI()
	npcManager.registerEvent(npcID, boxEntrance, "onDrawNPC")
	npcManager.registerEvent(npcID, boxEntrance, "onTickNPC")
end

function boxEntrance.onDrawNPC(v)
	v.animationFrame = 0
	for k, p in ipairs(Player.get()) do
		if warpBox.inWarpBox[k] == v.data._settings.boxid and
		warpBox.warpTimer[k] > (warpBox.warpTime/2) then
			v.animationFrame = 1
			break
		end
	end
end

function boxEntrance.onTickNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	local config = NPC.config[v.id]
	
	--If despawned
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		--Reset our properties, if necessary
		data.initialized = false
		return
	end

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		myExit = findMyExit(v)
		if myExit == nil then
			-- delete boxes that don't have an exit
			v:kill(HARM_TYPE_OFFSCREEN)
		end
		data.initialized = true
	end

	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		--Handling
	end
	
	-- Execute main AI
	for k, p in ipairs(Player.get()) do
		if warpBox.inWarpBox[k] == data._settings.boxid then
			-- Player is in this warp box
			Graphics.glDraw{vertexCoords={	v.x + (boxExpand * -1), v.y + (boxExpand * -1) + boxBounce, 
											v.x + v.width + boxExpand, v.y + (boxExpand * -1)+ boxBounce, 
											v.x + (boxExpand * -1), v.y + v.height + boxExpand+ boxBounce, 
											v.x + v.width + boxExpand, v.y + v.height + boxExpand+ boxBounce},
						primitive = Graphics.GL_TRIANGLE_STRIP,
						priority=1.1,
						textureCoords={0,0,1,0,0,1,1,1},
						sceneCoords = true,
						texture=boxImg}
			
			if warpBox.warpTimer[k] > (warpBox.warpTime/2) then
				-- in initial box
				if warpBox.warpTimer[k] > (warpBox.warpTime/1.2) then
					boxExpand = boxExpand + 0.75
					boxBounce = boxBounce - 1.5
				else
					if boxExpand > 0 then
						boxExpand = boxExpand - 0.75
						boxBounce = boxBounce + 1.5
					end
				end
				p.x = v.x
				p.y = v.y
			else
				-- warp the player to the exit of the box
				-- halfway through the countdown				
				myExit = findMyExit(v)
				p.section = myExit:mem(0x146, FIELD_WORD)		
				p.x = myExit.x + 16
				p.y = myExit.y
				playMusic(p.section) -- kludgy fix to update the music if section transition
				if data._settings.oneUseOnly then
					v:kill(HARM_TYPE_OFFSCREEN)
				end
			end
		elseif Colliders.collide(p, v) and warpBox.inWarpBox[k] == 0 and myExit ~= nil and (not p.isMega) then
			-- player has hit this warp box and is not already in a warp box
			warpBox.enterBox(k, data._settings.boxid)
		end
	end
end

--Gotta return the library table!
return boxEntrance