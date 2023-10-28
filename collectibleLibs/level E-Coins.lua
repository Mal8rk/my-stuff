--ALL of this taken from Zlaker's Level Collection's level dragon coins

local eCoinsLevel = {}

SaveData[Level.filename()] = SaveData[Level.filename()] or {}
local levelSD = SaveData[Level.filename()]

local eCoinsGlobal = require("collectibleLibs/global E-coins")

local coinTable = {false, false, false, false, false}
local coinCollectedSprite = Graphics.loadImage(Misc.resolveFile("e_coin.png"))
local coinOutlineSprite = Graphics.loadImage(Misc.resolveFile("e_coin_outline.png"))

local level_value = tostring(Level.filename())

function eCoinsLevel.onInitAPI()
   registerEvent(eCoinsLevel, "onDraw")
   registerEvent(eCoinsLevel, "onEvent")
   registerEvent(eCoinsLevel, "onNPCKill")
end

function eCoinsLevel.onDraw()
   Graphics.drawImageWP(coinOutlineSprite, 26, 84, 5)	
   if SaveData.eCoinsGlobal[level_value][1] == true then
      Graphics.drawImageWP(coinCollectedSprite, 26, 84, 5)	
   end
end

function eCoinsLevel.onEvent(eventname)
   if eventname == "e" then
      coinTable[1] = true
	   SaveData.eCoinsGlobal[level_value][1] = true
   end
end

return eCoinsLevel