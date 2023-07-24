local npcManager = require("npcManager")


--AI used from MrDoubleA's Big Coins. Full credit goes to him.


local sack = {}

local npcID = NPC_ID

local collectEffectID = (npcID)

local sackSettings = {
	id = npcID,
	
	gfxwidth = 32,
	gfxheight = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,

	width = 32,
	height = 32,

	frames = 1,
	framestyle = 0,
	framespeed = 10,

	speed = 0,
	
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,

	nohurt = true,
	nogravity = false,
	noblockcollision = false,
	nofireball = false,
	noiceball = false,
	noyoshi = false,
	nowaterphysics = false,
	
	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = true,
	harmlessthrown = false,

	isinteractable = true,
	notcointransformable = true,

	value = 50,
	collectEffectID = collectEffectID,
	collectSoundEffect = 14,
}

npcManager.setNpcSettings(sackSettings)
npcManager.registerDefines(npcID,{NPC.COLLECTIBLE})
npcManager.registerHarmTypes(npcID,{HARM_TYPE_OFFSCREEN},{})

function sack.onInitAPI()
	registerEvent(sack,"onPostNPCKill")
end

-- Fun fact: this function is based off of the source code!
local coinsPointer = 0x00B2C5A8
local livesPointer = 0x00B2C5AC
local function addCoins(amount)
    mem(coinsPointer,FIELD_WORD,(mem(coinsPointer,FIELD_WORD)+amount))

    if mem(coinsPointer,FIELD_WORD) >= 100 then
        if mem(livesPointer,FIELD_FLOAT) < 99 then
            mem(livesPointer,FIELD_FLOAT,(mem(livesPointer,FIELD_FLOAT)+math.floor(mem(coinsPointer,FIELD_WORD)/100)))
            SFX.play(15)

            mem(coinsPointer,FIELD_WORD,(mem(coinsPointer,FIELD_WORD)%100))
        else
            mem(coinsPointer,FIELD_WORD,99)
        end
    end
end

function sack.onPostNPCKill(v,reason)
	if v.id == npcID and reason == HARM_TYPE_OFFSCREEN and (npcManager.collected(v,reason) or v:mem(0x138,FIELD_WORD) == 5) then
		local config = NPC.config[v.id]

		if config.value then
			addCoins(config.value)
		end
		if config.collectSoundEffect then
			SFX.play(config.collectSoundEffect)
		end
		if config.collectEffectID then
			local w = Effect.spawn(config.collectEffectID,0,0)
			w.x = (v.x+(v.width /2)-(w.width /2))
			w.y = (v.y+(v.height/2)-(w.height/2))
		end
	end
end


return sack