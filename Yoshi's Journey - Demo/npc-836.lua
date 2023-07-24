--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")

--Create the library table
local needleNose = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC. You can remove superfluous definitions.
local needleNoseSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 32,
	width = 32,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 1,
	framestyle = 1,
	framespeed = 8,
	speed = 1,
	npcblock = false,
	npcblocktop = false, 
	playerblock = false,
	playerblocktop = false,
	nohurt=false,
	nogravity = false,
	noblockcollision = true,
	nofireball = false,
	noiceball = false,
	noyoshi= false,
	nowaterphysics = false,
	jumphurt = true,
	spinjumpsafe = true,
	harmlessgrab = false,
	harmlessthrown = false,


	--NPC-Specific Property
	explodesfx = 3, --Sound Effect when collides with solid, can be either filename or SMBX internal ID. Comment this to not play anything
	explodeeffectID = 76 --Effect ID when collides with solid, default value is 76 (spin jump star)
}

--Applies NPC settings
npcManager.setNpcSettings(needleNoseSettings)

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.
npcManager.registerHarmTypes(npcID,
	{
		HARM_TYPE_NPC,
		HARM_TYPE_PROJECTILE_USED,
		HARM_TYPE_LAVA,
		HARM_TYPE_HELD,
	}, 
	{
		[HARM_TYPE_NPC]=10,
		[HARM_TYPE_PROJECTILE_USED]=10,
		[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		[HARM_TYPE_HELD]=10,
	}
);

--Custom local definitions below


--Register events
function needleNose.onInitAPI()
	npcManager.registerEvent(npcID, needleNose, "onTickNPC")
end

function needleNose.onTickNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		
		local cfg = NPC.config[v.id]
		data.explodesfx = cfg.explodesfx
		data.explodeeffectID = cfg.explodeeffectID or 76
		
		local angle = data.angle+math.pi
		
		local speed = 9
		
		v.speedX = speed*math.cos(angle)
		v.speedY = speed*math.sin(angle)
		
		data.counter = 0
		
		data.initialized = true

	end
	
	--Break blocks
	data.destroyCollider = data.destroyCollider or Colliders.Box(v.x, v.y, v.width + 8, v.height + 8);
	data.destroyCollider.x = v.x - 8;
	data.destroyCollider.y = v.y - 8;
	local tbl = Block.SOLID .. Block.PLAYER
	local list = Colliders.getColliding{
	a = data.destroyCollider,
	b = tbl,
	btype = Colliders.BLOCK,
	filter = function(other)
		if other.isHidden or other:mem(0x5A, FIELD_BOOL) then
			return false
		end
		if data.explodesfx~= null then
			SFX.play(data.explodesfx)
		end
		Effect.spawn(data.explodeeffectID, v.x+0.5*v.width, v.y+0.5*v.height)
		v:kill(HARM_TYPE_OFFSCREEN)
		return true
	end
	}
	for _,b in ipairs(list) do
		if (Block.config[b.id].smashable ~= nil and Block.config[b.id].smashable == 3) or b.id == 186 then
			b:remove(true)
		else
			b:hit(true)
		end
	end
	
	data.counter = data.counter+1
	if data.counter%10==0 then
		Effect.spawn(10, v.x, v.y)
	end
end

--Gotta return the library table!
return needleNose