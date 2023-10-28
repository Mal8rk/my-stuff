--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")
local redCoinAI = require("collectibleLibs/redCoin")

--Create the library table
local sampleNPC = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

local collectEffectID = (npcID)

--Defines NPC config for our NPC. You can remove superfluous definitions.
local sampleNPCSettings = {
	id = npcID,
	--Sprite size
	gfxheight = 32,
	gfxwidth = 32,
	--Hitbox size. Bottom-center-bound to sprite size.
	width = 32,
	height = 32,
	--Sprite offset from hitbox for adjusting hitbox anchor on sprite.
	gfxoffsetx = 0,
	gfxoffsety = 2,
	--Frameloop-related
	frames = 4,
	framestyle = 0,
	framespeed = 8, --# frames between frame change
	--Movement speed. Only affects speedX by default.
	speed = 0,
	--Collision-related
	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = false, --Also handles other NPCs walking atop this NPC.

	nohurt=true,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi= true,
	nowaterphysics = true,
	--Various interactions
	jumphurt = true, --If true, spiny-like
	spinjumpsafe = false, --If true, prevents player hurt when spinjumping
	harmlessgrab = false, --Held NPC hurts other NPCs if false
	harmlessthrown = false, --Thrown NPC hurts other NPCs if false

	grabside=false,
	grabtop=false,

	value = 1,
	ignorethrownnpcs = true,
	notcointransformable = true,
	isinteractable=true,
}

local UNCOLLECTED = 0
local SAVED = 1
local COLLECTED = 2
local COLLECTED_WEAK = 3

--Applies NPC settings
npcManager.setNpcSettings(sampleNPCSettings)

--Register events
function sampleNPC.onInitAPI()
	npcManager.registerEvent(npcID, sampleNPC, "onStartNPC")
	npcManager.registerEvent(npcID, sampleNPC, "onDrawNPC")
	npcManager.registerEvent(npcID, sampleNPC, "onTickEndNPC")
	registerEvent(sampleNPC, "onNPCKill", "onNPCKill")
	registerEvent(sampleNPC, "onStart", "onStart", false)
end

function sampleNPC.onStartNPC(coin)
	if coin.ai2 == nil then coin.ai2 = UNCOLLECTED end
	redCoinAI.registerAlive(coin.ai2)
end

function sampleNPC.onStart()
	redCoinAI.init()
end

function sampleNPC.onTickEndNPC(v)
	if Defines.levelFreeze then return end

	v.speedX, v.speedY = npcutils.getLayerSpeed(v)
end

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

function sampleNPC.onDrawNPC(coin)
	local CoinData = redCoinAI.getTemporaryData()
	if coin.ai2 == nil then coin.ai2 = UNCOLLECTED end
	if CoinData[coin.ai2] == nil then
		CoinData[coin.ai2] = UNCOLLECTED
	end
	redCoinAI.registerAlive(coin.ai2)
end

--Spawn effects and coins.
function sampleNPC.onNPCKill(obj, v, r)
	if v.id == npcID and r == 9 then
		if (npcManager.collected(v, r) or v:mem(0x138, FIELD_WORD) == 5) then
			redCoinAI.collect(v)
		end
	end
end
--Gotta return the library table!
return sampleNPC