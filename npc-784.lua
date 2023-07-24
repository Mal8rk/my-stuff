--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local flightlessGoonie = require("flightlessGooniesAI")

--Create the library table
local goonie = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC.
local goonieSettings = {
	id = npcID,
	gfxheight = 36,
	gfxwidth = 46,
	width = 32,
	height = 30,
	gfxoffsetx = -2,
	gfxoffsety = 0,
	frames = 3,
	framestyle = 1,
	speed = 1,
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,

	nohurt=false,
	nogravity = false,
	noblockcollision = false,
	nofireball = false,
	noiceball = false,
	noyoshi= false,
	nowaterphysics = false,

	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,

	--NPC Specific Properties
	xspeed = 4,
	--defeatsoundID = 57 --Extra sound that plays when defeated
}

--Applies NPC settings
npcManager.setNpcSettings(goonieSettings)

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.
npcManager.registerHarmTypes(npcID,
	flightlessGoonie.VULNERABLE_HARM_TYPE
	, 
	flightlessGoonie.HARM_TYPE_EFFECT_MAP
);

--Custom local definitions below


--Register events
flightlessGoonie.registerNPC(npcID)


--Gotta return the library table!
return goonie