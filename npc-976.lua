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
	gfxheight = 42,
	gfxwidth = 80,
	--Hitbox size. Bottom-center-bound to sprite size.
	width = 30,
	height = 34,
	--Frameloop-related
	frames = 17,
	framestyle = 1,
	framespeed = 8, --# frames between frame change
	--Movement speed. Only affects speedX by default.
	speed = 1,
	--Collision-related
	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = false, --Also handles other NPCs walking atop this NPC.

	nohurt=false,
	nogravity = false,
	noblockcollision = false,
	nofireball = false,
	noiceball = false,
	noyoshi= false,
	nowaterphysics = true,
	--Various interactions
	jumphurt = true, --If true, spiny-like
	spinjumpsafe = true, --If true, prevents player hurt when spinjumping
	harmlessgrab = false, --Held NPC hurts other NPCs if false
	harmlessthrown = false, --Thrown NPC hurts other NPCs if false

	grabside=false,
	grabtop=false,
	staticdirection=true,
}

--Applies NPC settings
npcManager.setNpcSettings(sampleNPCSettings)

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.
npcManager.registerHarmTypes(npcID,
	{
		--HARM_TYPE_JUMP,
		HARM_TYPE_FROMBELOW,
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
		[HARM_TYPE_FROMBELOW]=753,
		[HARM_TYPE_NPC]=753,
		[HARM_TYPE_PROJECTILE_USED]=10,
		[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		[HARM_TYPE_HELD]=10,
		[HARM_TYPE_TAIL]=10,
		--[HARM_TYPE_SPINJUMP]=10,
		[HARM_TYPE_OFFSCREEN]=10,
		[HARM_TYPE_SWORD]=10,
	}
);

local STATE_JUMP = 0
local STATE_SCURRY = 1
local STATE_LEFT_HOP = 2
local STATE_RIGHT_HOP = 3
local STATE_LEFT_LEAP = 4
local STATE_RIGHT_LEAP = 5
local STATE_LEFT_TWIRL = 6
local STATE_RIGHT_TWIRL = 7
local STATE_BUTT = 8

local split = string.split

local sing = Misc.resolveSoundFile("dancingSpearGuy")
local playSound = false
local idleSoundObj

--Register events
function sampleNPC.onInitAPI()
	npcManager.registerEvent(npcID, sampleNPC, "onTickEndNPC")
	registerEvent(sampleNPC,"onTick")
end

function sampleNPC.onTick()
    if playSound then
        -- Create the looping sound effect for all of the NPC's
        if idleSoundObj == nil then
			idleSoundObj = SFX.play{sound = sing,loops = 0}
        end
    elseif idleSoundObj ~= nil then -- If the sound is still playing but there's no NPC's, stop it
        idleSoundObj:stop()
        idleSoundObj = nil
    end
    
    -- Clear playSound for the next tick
    playSound = false
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
		data.timer = 0
		data.buttTimer = 0
		return
	end

	data.behaviourList = settings.sequence or "0"
	
	--Set up a table based on what's in the lineEdit
	if data.behaviourList ~= "" then
		data.behaviourList = split(data.behaviourList, ",")
		for i = 1, #data.behaviourList do
			data.behaviourList[i] = tonumber(data.behaviourList[i])
		end
	else
		error("Please input at least one number from 0 to 8 in the 'Dance Sequence' field.")
	end

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		data.initialized = true
		data.spear = data.spear or {}
		data.timer = data.timer or 0
		data.currentFrame = v.animationFrame
		data.state = data.behaviourList[v.ai2 + 1]
		data.buttTimer = data.buttTimer or 0
		data.frameLocation = v.x
		
		if settings.spearHeight == nil then settings.spearHeight = 2 end
		
		for i=0, (settings.spearHeight - 1) do
			local r = i * 32 - (32 * settings.spearHeight)
			data.spear = NPC.spawn(npcID - 1,v.x,v.y + r,player.section, true --[[centered hitbox around x/y]])
			data.spear.data.owner = v
			data.spear.ai1 = i
			data.spear.ai2 = settings.spearHeight
		end
	end
	
	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	or v:mem(0x138, FIELD_WORD) == 6	--In Yoshi's mouth
	then
		v.animationFrame = data.currentFrame
		data.timer = 0
		data.isBeingThrown = true
	else
		if (v.x + v.width > camera.x and v.x < camera.x + 800 and v.y + v.height > camera.y and v.y < camera.y + 600) then
			playSound = true
		end
		if not data.reverseTimer then
			data.timer = data.timer + 1
		else
			data.timer = data.timer - 1
		end
		data.currentFrame = v.animationFrame
	end
	
	if v.collidesBlockBottom and data.isBeingThrown then 
		v.speedX = 0
		data.isBeingThrown = false	
	end
	
	if data.state == STATE_JUMP then
		--Animation stuff
		if data.timer >= 0 and data.timer <= 7 then
			v.animationFrame = 14
		elseif data.timer > 7 and data.timer <= 11 then
			v.animationFrame = 15
		--Jump up, and when in the air toggle data.reverseTimer, so when it lands the timer goes down instead of up
		elseif data.timer > 11 then
			if data.timer == 12 and v.collidesBlockBottom then 
				v.speedY = -4 
			else
				if v.collidesBlockBottom and data.timer >= 14 then 
					data.reverseTimer = true
					data.timer = 11
				end
			end
			v.animationFrame = 16
		else
			--When below 0, go into the next state
			data.timer = 0
			data.reverseTimer = false
			v.ai2 = v.ai2 + 1
			data.state = data.behaviourList[v.ai2 + 1]
		end
	elseif data.state == STATE_SCURRY then
	
		--Not much here, just play an animation
		if data.timer % 32 < 16 then
			v.animationFrame = math.floor((-data.timer - 1) / 4) % 4 + 1
		else
			v.animationFrame = math.floor((data.timer) / 4) % 4 + 1
		end
		
		if data.timer >= 64 then
			data.timer = 0
			v.ai2 = v.ai2 + 1
			data.state = data.behaviourList[v.ai2 + 1]
		end
	elseif data.state == STATE_LEFT_HOP or data.state == STATE_RIGHT_HOP then
	
		--The only thing separating the two ai states, direction is state dependant
		if data.state == STATE_LEFT_HOP then v.direction = DIR_LEFT else v.direction = DIR_RIGHT end
		
		--Animation stuff
		if v.collidesBlockBottom then
			v.animationFrame = 0
		else
			v.animationFrame = 1
		end
		
		--Do a couple small hops on one foot
		if data.timer == 7 or data.timer == 30 then
			v.speedY = -2
		elseif data.timer > 48 then
			data.timer = 0
			v.ai2 = v.ai2 + 1
			data.state = data.behaviourList[v.ai2 + 1]
		end
	elseif data.state == STATE_LEFT_LEAP or data.state == STATE_RIGHT_LEAP then
	
		if data.state == STATE_LEFT_LEAP then v.direction = DIR_LEFT else v.direction = DIR_RIGHT end
		
		--Crap code but it works lmao
		if data.timer <= 8 then
			if not data.reverseTimer then
				v.animationFrame = 0
			else
				v.animationFrame = 5
			end
		else
			if not data.reverseTimer then
				v.animationFrame = 1
			else
				v.animationFrame = 4
			end
		end
		
		--Move the NPC a bit, the part below reverses the timer so it stays in place for a bit before going to the next ai state
		if data.timer < 0 then
			--When below 0, go into the next state
			data.timer = 0
			data.reverseTimer = false
			v.ai2 = v.ai2 + 1
			data.state = data.behaviourList[v.ai2 + 1]
		elseif data.timer == 16 then 
			data.frameLocation = v.x + v.width * v.direction
			v.speedY = -3
		end
		
		--Animation stuff
		if not v.collidesBlockBottom then
			data.reverseTimer = true
			v.speedX = 3 * v.direction
			data.timer = 16
			if v.x > data.frameLocation then
				v.animationFrame = 2
			else
				v.animationFrame = 3
			end
		else
			v.speedX = 0
		end
	elseif data.state == STATE_LEFT_TWIRL or data.state == STATE_RIGHT_TWIRL then
	
		if data.timer == 1 then
			--Set the NPC's speed to a certain value, and don't change this.
			if data.state == STATE_LEFT_TWIRL then v.direction = DIR_LEFT else v.direction = DIR_RIGHT end
			v.speedX = v.direction
		elseif data.timer == 23 then 
			--When reaching 23, make the timer reverse and flip its direction
			v.direction = -v.direction
			v.speedX = -v.direction
			data.reverseTimer = true	
		elseif data.timer <= 0 then
			--When the timer reaches 0, then move into the next ai state
			v.speedX = 0
			data.timer = 0
			data.reverseTimer = false
			v.ai2 = v.ai2 + 1
			data.state = data.behaviourList[v.ai2 + 1]
		end
		
		--Animation stuff
		v.animationFrame = math.floor(data.timer / 6) % 4 + 6
		
	elseif data.state == STATE_BUTT then
	
		data.buttTimer = data.buttTimer + 1
	
		--Control how the butt shakes
		if data.timer >= 13 then
			data.reverseTimer = true
		elseif data.timer <= 2 then
			data.reverseTimer = false
		end
		
		if data.timer <= 3 then
			v.animationFrame = 10
		elseif data.timer > 3 and data.timer <= 7 then
			v.animationFrame = 11
		elseif data.timer > 7 and data.timer <= 11 then
			v.animationFrame = 12
		else
			v.animationFrame = 13
		end
			
		
		--When the timer reaches a certain number, go into the next ai state
		if data.buttTimer > 46 then
			data.timer = 0
			data.buttTimer = 0
			v.ai2 = v.ai2 + 1
			data.state = data.behaviourList[v.ai2 + 1]
		end
	end
	
	--If v.ai2 becomes greater than the dance sequence list, return to 0
	if v.ai2 >= #data.behaviourList then
		v.ai2 = 0
		data.state = data.behaviourList[v.ai2 + 1]
	end

	-- animation controlling
	v.animationFrame = npcutils.getFrameByFramestyle(v, {
		frame = data.frame,
		frames = sampleNPCSettings.frames
	});
end

--Gotta return the library table!
return sampleNPC