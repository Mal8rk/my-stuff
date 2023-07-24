--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")
local rng = require("rng")

--Create the library table
local balloonEnemy = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC. You can remove superfluous definitions.
local balloonEnemySettings = {
	id = npcID,
	gfxwidth = 32,
	gfxheight = 48,
	width = 32,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 16,
	frames = 1,
	framestyle = 1,
	speed = 1,
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,
	nohurt=true,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi= true,
	nowaterphysics = false,

	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,
	
	--NPC Specific Property
	xspeed = 0.5,
	activerange = 64
}

--Applies NPC settings
npcManager.setNpcSettings(balloonEnemySettings)

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.
npcManager.registerHarmTypes(npcID,
	{
		HARM_TYPE_JUMP,
		HARM_TYPE_NPC,
		HARM_TYPE_SWORD
	}, 
	{
		[HARM_TYPE_JUMP]=10,
		[HARM_TYPE_NPC]=10,
		[HARM_TYPE_SWORD]=10,
	}
);

--Custom local definitions below
local STATE_READY = 0;
local STATE_DEPLOYED = 1;


function dropNPC(id,x,y,direction,section)
	--If id is not valid, do nothing
	if id <= 0 then return end
	
	local w = NPC.spawn(id,x,y,section,false,true)
	w.direction = direction
	w.layerName = "Spawned NPCs"
end

--Register events
function balloonEnemy.onInitAPI()
	npcManager.registerEvent(npcID, balloonEnemy, "onTickEndNPC")
	npcManager.registerEvent(npcID, balloonEnemy, "onDrawNPC")
	registerEvent(balloonEnemy, "onNPCKill")
end

function balloonEnemy.onTickEndNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	local cfg = NPC.config[v.id]
	
	--If despawned
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		--Reset our properties, if necessary
		
		data.f = 0;
		
		--reset friendly property for item variant
		if data.isitem then
			v.friendly = true
		end
		
		data.initialized = false
		return
	end

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		data.state = STATE_READY
		
		data.gfxwidth = cfg.gfxwidth
		data.gfxheight = cfg.gfxheight
		  
		if(data.gfxwidth == 0) then
			data.gfxwidth = cfg.height;
		end
		if(data.gfxheight == 0) then
			data.gfxheight = cfg.width;
		end
		
		
		data.xspeed = cfg.xspeed or 0.5
		
		data.activerange  = cfg.activerange or 64
		
		v.speedX = v.direction * data.xspeed
		
		data.f = 0;
		
		data.isitem = v.friendly
		v.friendly = false
		
		v.color = rng.randomInt(0,3) --random color upon spawn
		v.baseanimframe = v.color*2
		
		
		
		--getting yoffset for the contained npc
		if v.ai1 and v.ai1 > 0 then
			data.npcyoffset = NPC.config[v.ai1].gfxheight
			if data.npcyoffset==0 then
				data.npcyoffset = NPC.config[v.ai1].height
			end
		else
			data.npcyoffset = 0
		end
		
		data.initialized = true
	end

	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		--Handling
		return
	end
	
	if data.state==STATE_DEPLOYED then
    v.ai1 = 0
	end    
	
	--Balloon Graphic
	if v.direction==-1 then
		v.animationFrame = v.baseanimframe
	else
		v.animationFrame = v.baseanimframe+1
	end
	
	--Execute main AI
	if data.state==STATE_DEPLOYED then
		v.speedY = math.max(v.speedY-0.05,-3)
	else
		data.f= data.f + 0.05
		v.speedY = 0.5*math.sin(data.f)
	end
	
	local player = npcutils.getNearestPlayer(v)
	
	--Enemy Variant
	if not data.isitem and math.abs((player.x + 0.5 * player.width) - (v.x + 0.5 * v.width))<64 and data.state==STATE_READY then
		data.state = STATE_DEPLOYED
		SFX.play(9)
		
		dropNPC(v.ai1,v.x+v.width*0.5,v.y+v.height+v.data.npcyoffset,v.direction,v.section);
		
	end
	
	--Item Variant - Set it to "Friendly", player needs to overlap before it deploys
	if data.isitem and math.abs((player.x + 0.5 * player.width) - (v.x + 0.5 * v.width))<32 and math.abs(player.y-v.y)<48 and data.state==STATE_READY then
		v:kill(HARM_TYPE_NPC) -- In YI, the item variant simply vanished when touched
	end
	
end

function balloonEnemy.onDrawNPC(v)
	--Drawing code based on Albatoss by boingboingsplat
	
	--Don't draw if despawned
  if v:mem(0x12A, FIELD_WORD) <= 0 then return end
  
  -- Don't draw if the data is not initialized
  if not v.data.initialized then return end
  
  --If empty container, don't draw anything
  if v.ai1 <= 0 then return end
  
  --Draw the sprite of the contained NPC
 
  local id = v.ai1;
	if(id > 0) then
		local i = Graphics.sprites.npc[id].img;
		local cfg = NPC.config[id];
		local h = cfg.gfxheight;
		local w = cfg.gfxwidth;
		local fs = cfg.framestyle;
		if(h == 0) then
			h = cfg.height;
		end
		if(w == 0) then
			w = cfg.width;
		end
    
    --If facing right, flip the texture
    if v.direction == 1 and fs > 0 then
      w = -w;
    end
		
		local x,y = v.x + v.data.gfxwidth*0.5, v.y + v.data.gfxheight;
    
		x = x - w*0.5;
		y = y;
		
		Graphics.drawBox{
							x = x, y = y, 
							textureCoords = {0,0,1,0,1,h/i.height,0,h/i.height}, 
							width = w, height = h, 
							texture = i, 
							priority=-45, sceneCoords=true
						}
	end
	
	
end

function balloonEnemy.onNPCKill(eventObj,v,killReason,culprit)
	if v.id ~= npcID then return end

	dropNPC(v.ai1,v.x+v.width*0.5,v.y+v.height+v.data.npcyoffset,v.direction,v.section);
	
	--Play Proper SFX
	if killReason==HARM_TYPE_JUMP then
		SFX.play(9)
	end
end

--Gotta return the library table!
return balloonEnemy