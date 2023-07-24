local npcManager = require("npcManager")

local gooniesAI = {}

local npcIDs = {}

function gooniesAI.dropNPC(id,x,y,direction,section)
	--If id is not valid, do nothing
	if id <= 0 then return end
	
	local w = NPC.spawn(id,x,y,section,false,true)
	w.direction = direction
	w.layerName = "Spawned NPCs"
	
end

function gooniesAI.registerHarmEvent(id,spawnid)
	registerEvent(gooniesAI, "onNPCKill")
	npcIDs[id]=spawnid
end

function gooniesAI.registerCarrierDrawEvent(id)
	npcManager.registerEvent(id, gooniesAI, "onDrawNPC","onDrawCarrierNPC")
end

function gooniesAI.onNPCKill(eventObj,v,killReason)
	if not npcIDs[v.id] then return end
	
	if not v.isDead then
		v.isDead = true --To make sure it triggered once
	else
		return
	end
	
	if killReason==HARM_TYPE_NPC or killReason==HARM_TYPE_JUMP or killReason==HARM_TYPE_SWORD then
	
		local defeatsound = v.data.defeatsoundID
	
		if defeatsound ~= nil then
			--Play Proper SFX
			SFX.play(defeatsound)
		end
	
		local winglessid = npcIDs[v.id]
		
		if v.ai1 ~= nil and v.ai1 > 0 then
			gooniesAI.dropNPC(v.ai1,v.x+16+v.data.xoffset,v.y+v.data.npcyoffset,v.direction,v.section);
			v.ai1=0
		end
		
		if winglessid then
			local w = NPC.spawn(winglessid,v.x+v.width*0.5,v.y+v.height*0.5,v.section,false,true);
			--w:mem(0x156, FIELD_WORD,30) --make spawned NPC invincible for a bit, doesn't seems to work on custom NPCs
			w.direction = v.direction
			w.layerName = "Spawned NPCs"
			w.delay = 5
			w.fall = true
		end

	end

end

function gooniesAI.onDrawCarrierNPC(v)
  --Drawing code based on Albatoss by boingboingsplat
	
  --Don't draw if despawned
  if v:mem(0x12A, FIELD_WORD) <= 0 then return end
  
  --If empty container, don't draw anything
  if v.ai1 <= 0 then return end
  
  --Draw the sprite of the contained NPC
  
  local xoffset = v.data.xoffset or 0
  
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
    
		--If facing right, with proper frame style, flip the texture
		--Note: for built-in NPCs, framestyle seems to be set to 0 by default
		--So, you need to define framestyle for them again using txt file
		--For example: npc-4(SMB3 Koopa Troopa) with framestyle = 1
		
		if v.direction == 1 and fs > 0 then
		  w = -w;
		end
		
		local x,y = v.x + 16 + xoffset, v.y + v.height + 4;
    
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

return gooniesAI