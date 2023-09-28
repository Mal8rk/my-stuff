local extraBGOProperties = require("extraBGOProperties")
local extraNPCProperties = require("extraNPCProperties")
local warpTransition = require("warpTransition")
local littleDialogue = require("littleDialogue")
local extendedKoopas = require("extendedKoopas")
local customCamera = require("customCamera")
local klonoa = require("characters/klonoa")
local hudoverride = require ("hudoverride")
local warioHealth = require("warioHealth")
local sinelayers = require("sinelayers")
local prismPause = require("pauseMenu")

littleDialogue.defaultStyleName = "yi"

warpTransition.levelStartTransition = warpTransition.TRANSITION_FADE

hudoverride.visible.lives = false
hudoverride.visible.coins = false
hudoverride.visible.score = false


function onStart()
	player.character = CHARACTER_KLONOA;
	player.powerup = 1;
end