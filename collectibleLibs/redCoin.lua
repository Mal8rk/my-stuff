--ALL of this is from the basagame's starcoin AI

local redcoin = {}

local LevelName = Level.filename()

if not SaveData[LevelName] then
    SaveData[LevelName] = {}
end

local UNCOLLECTED = 0
local SAVED = 1
local COLLECTED = 2
local COLLECTED_WEAK = 3

SaveData.redcoinCounter = SaveData.redcoinCounter or 0

local CoinData = SaveData[LevelName]

function redcoin.getTemporaryData()
    return CoinData
end

redcoin.sfx_collect = Misc.resolveSoundFile("Redcoin")
redcoin.sfx_collectall = Misc.resolveSoundFile("Allred")

redcoin.gfx_outline = Graphics.loadImage(Misc.resolveFile("red_coin_outline.png"))
redcoin.gfx_collected = Graphics.loadImage(Misc.resolveFile("red_coin.png"))

local checkpoints = require("checkpoints")
local npcManager = require("npcManager")

CoinData.alive = {}
CoinData.maxID = CoinData.maxID or 0

local function validCoin(t, i)
	return t[i] and (not t.alive or t.alive[i])
end

function redcoin.count(name)
	name = name or LevelName
	local t = SaveData[name]
	if not t then return 0 end
	local c = 0
	for i = 1, t.maxID do
		if validCoin(t,i) then
			c = c+1
		end
	end
	return c
end

function redcoin.max()
	return CoinData.maxID
end

function redcoin.getLevelList(name)
	name = name or LevelName
	return SaveData[name]
end

function redcoin.getEpisodeList()
	return SaveData.redcoin
end

function redcoin.getLevelCollected(name)
	local list = redcoin.getLevelList(name)
	local LtotalNum = 0
	for i = 1,list.maxID do
		if validCoin(list,i) and list[i] ~= 0 then
			LtotalNum = LtotalNum + 1
		end
	end
	return LtotalNum
end

function redcoin.getEpisodeCollected()
	local GtotalNum = 0
	for k in pairs(SaveData.redcoin) do
		GtotalNum = GtotalNum + redcoin.getLevelCollected(k)
	end
	return GtotalNum
end

function redcoin.registerAlive(id)
	CoinData.alive[id] = true
	if id > CoinData.maxID then
		CoinData.maxID = id
	end
end

--Called from npc-310 to make sure it runs at the right time
function redcoin.init()
	-- Reset states
	local activeCheckpoint = checkpoints.getActive()
	for i = 1,CoinData.maxID do
		if (CoinData[i] == COLLECTED and not activeCheckpoint) or CoinData[i] == COLLECTED_WEAK then
			CoinData[i] = 0
		end
	end
end

function redcoin.collect(coin)
	Effect.spawn(900, coin.x, coin.y)
	Effect.spawn(765, coin.x+16, coin.y+16)

	if CoinData[coin.ai2] == UNCOLLECTED and redcoin.getLevelCollected() + 1 >= redcoin.count() then
		SFX.play(redcoin.sfx_collectall)
	else
		SFX.play(redcoin.sfx_collect)
	end

	if coin.ai2 > UNCOLLECTED then
		if CoinData[coin.ai2] == UNCOLLECTED then
			CoinData[coin.ai2] = COLLECTED_WEAK
		end
	end

	--mem(0x00B2C8E4, FIELD_DWORD, mem(0x00B2C8E4, FIELD_DWORD) + 4000)

	--local pointEffect = Effect.spawn(79, coin.x + coin.width/2, coin.y, 8)
	--pointEffect.x = pointEffect.x - pointEffect.width/2
	--pointEffect.animationFrame = 7
end

function redcoin.reset(name)
  local list = redcoin.getLevelList(name)
  for i = 1, list.maxID do
    list[i] = UNCOLLECTED
  end
end

function redcoin.onCheckpoint()
	for i = 1,CoinData.maxID do
		if CoinData[i] == COLLECTED_WEAK then
			CoinData[i] = COLLECTED
		end
	end
end

function redcoin.onDraw()
	if Graphics.isHudActivated() then
		if redcoin.getLevelCollected() + 0.5 >= redcoin.count() then
			Graphics.drawImageWP(redcoin.gfx_collected, 64, 84, 5)
		else
			Graphics.drawImageWP(redcoin.gfx_outline, 64, 84, 5)
		end
	end
end

function redcoin.onExitLevel(win)
	if win > 0 then
		for i = 1,CoinData.maxID do
			if CoinData[i] and CoinData[i] >= COLLECTED then
				CoinData[i] = SAVED
				SaveData.redcoinCounter = SaveData.redcoinCounter + 1
			end
		end
	end
end

function redcoin.onInitAPI()
	registerEvent(redcoin, "onStart", "onStart", false)
	registerEvent(redcoin, "onCheckpoint", "onCheckpoint")
	registerEvent(redcoin, "onExitLevel", "onExitLevel")
	registerEvent(redcoin, "onDraw", "onDraw", false)
end

return redcoin
