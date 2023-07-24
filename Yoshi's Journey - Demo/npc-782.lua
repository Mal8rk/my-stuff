--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local gooniesAI = require("gooniesAI")
--Create the library table
local goonies = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC.
local gooniesSettings = {
	id = npcID,
	gfxheight = 110,
	gfxwidth = 130,
	width = 32,
	height = 20,
	gfxoffsetx = 6,
	gfxoffsety = 38,
	frames = 11,
	framestyle = 1,
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = true,
	nohurt=false,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi= false,
	nowaterphysics = false,
	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,

	--NPC Specific Properties
	xspeed = 1.5,
	--winglessid = 753 --Wingless Goonie ID, default being npcID+2. Uncomment this and set manually otherwise.
}

--Applies NPC settings
npcManager.setNpcSettings(gooniesSettings)

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.
npcManager.registerHarmTypes(npcID,
	{
		--HARM_TYPE_JUMP,
		--HARM_TYPE_FROMBELOW,
		HARM_TYPE_NPC,
		--HARM_TYPE_PROJECTILE_USED,
		HARM_TYPE_LAVA,
		--HARM_TYPE_HELD,
		--HARM_TYPE_TAIL,
		--HARM_TYPE_SPINJUMP,
		--HARM_TYPE_OFFSCREEN,
		HARM_TYPE_SWORD
	}, 
	{
		--[HARM_TYPE_JUMP]=10,
		--[HARM_TYPE_FROMBELOW]=10,
		[HARM_TYPE_NPC]=753,
		--[HARM_TYPE_PROJECTILE_USED]=10,
		[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		--[HARM_TYPE_HELD]=10,
		--[HARM_TYPE_TAIL]=10,
		--[HARM_TYPE_SPINJUMP]=10,
		--[HARM_TYPE_OFFSCREEN]=10,
		[HARM_TYPE_SWORD]=10,
	}
);

--Custom local definitions below
local STATE_ASCENT = 0
local STATE_DESCENT = 1
local STATE_RIDE = 2

function updateSpeed(v,state)
	local data = v.data
	
	v.speedX = v.direction * data.xspeed
				
	if state == STATE_DESCENT then
		v.speedY = 1
	elseif state == STATE_ASCENT then
		v.speedY = -0.25
	end
end

--Register events
function goonies.onInitAPI()
	npcManager.registerEvent(npcID, goonies, "onTickEndNPC")
	npcManager.registerEvent(npcID, goonies, "onDrawNPC")
	gooniesAI.registerHarmEvent(npcID,NPC.config[npcID].winglessid or npcID+2)
end

local riddenNPCs = {}

function goonies.onDrawNPC(v)

	if v:mem(0x12A, FIELD_WORD) <= 0 then return end

	local data = v.data
	local f = 0
	
	if data.state==STATE_ASCENT or data.state==STATE_RIDE then
		f  = npcutils.getFrameByFramestyle(v, {frame=math.floor(data.timer/8)%8})
	elseif  data.state==STATE_DESCENT then
		f  = npcutils.getFrameByFramestyle(v, {frame=8+math.floor(data.timer/4)%3})
	end
	v.animationFrame = f
end

function goonies.onTickEndNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	local cfg = NPC.config[v.id]
	
	--If despawned
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		--Reset our properties, if necessary
		data.isRidden = false
		data.initialized = false
		return
	end

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		
		if data.isRidden == nil then
		data.isRidden = false;
		end
		
		if data.state == nil then
			data.state = STATE_ASCENT
		end
		
		data.xspeed = cfg.xspeed or 1.5
		
		data.debouncetime = 0
		
		data.phasetimer = 0
		
		data.timer = 0 --animation timer
		
		v.ai1 = 0
		
		npcutils.faceNearestPlayer(v)
		
		data.initialized = true
	end

	data.timer = data.timer+1

	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		--Handling
		return
	end
	
	--Execute main AI.
	
	--New Riding Detection Logic by Enjl
	local p = npcutils.getNearestPlayer(v)

	if p.standingNPC and p.standingNPC.isValid and p.standingNPC.id == npcID then
		p.standingNPC.ridden = p.idx --lets goonie know which player is riding it
	else
		v.ridden = false --toggle ridden back or else it will fly forever
	end
	
	if v.ridden then
		 data.timer  = data.timer  + 3;
		 v.speedY = -0.25
		 v.speedX = v.direction * data.xspeed * 0.5
		 data.isRidden = true;
		 
		 if data.state ~= STATE_RIDE then
		 data.state = STATE_RIDE
		 data.timer =0
		 end
	else
		if (data.isRidden) then
			data.isRidden = false
			data.state = STATE_ASCENT
			data.timer=0
			data.debouncetime = 10
			updateSpeed(v,STATE_ASCENT)
		elseif data.debouncetime > 0 then
			data.debouncetime = data.debouncetime-1
		else
			--
			
			
			if data.phasetimer>0 then
				data.phasetimer = data.phasetimer-1
			else
				if data.state == STATE_ASCENT then
					updateSpeed(v,STATE_DESCENT)
					data.state = STATE_DESCENT
					data.phasetimer = 120
				elseif data.state == STATE_DESCENT then
					updateSpeed(v,STATE_ASCENT)
					data.state = STATE_ASCENT
					data.phasetimer = 280
				end
				
			end
			
			
		end
	end
end


--Gotta return the library table!
return goonies