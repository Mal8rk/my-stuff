local block = {}
local blockManager = require("blockManager")

local id = BLOCK_ID

blockManager.setBlockSettings{
	id = id,
	smashable=true,
}

local expandedDefines = require("expandedDefines")
expandedDefines.BLOCK_MEGA_SMASH_MAP[id] = true
expandedDefines.BLOCK_MEGA_HIT_MAP[id] = true

return block