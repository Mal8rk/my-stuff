--ALL of this taken from Zlaker's Level Collection's global dragon coins

local eCoinsGlobal = {}

local anothercurrency = require("anothercurrency")

SaveData.eCoinsGlobal = SaveData.eCoinsGlobal or {}
local levelSD = SaveData[Level.filename()]

eCoinsGlobal.current = eCoinsGlobal[Level.filename()]

local function addECoinEntry(levelName)
   SaveData.eCoinsGlobal[levelName] = SaveData.eCoinsGlobal[levelName] or {false, false, false, false, false}
end

addECoinEntry("1-1.lvlx")
addECoinEntry("1-2.lvlx")
addECoinEntry("1-3.lvlx")
addECoinEntry("1-4.lvlx")

myCurrency2 = anothercurrency.registerCurrency("E Coins")
myCurrency2:registerCoin(901, 1)

function eCoinsGlobal.onInitAPI()
   registerEvent(eCoinsGlobal, "onTick")
   registerEvent(eCoinsGlobal, "onNPCKill")
end

return eCoinsGlobal