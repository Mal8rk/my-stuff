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

function onTick()
	if player:isGroundTouching() then
		groundTimer = groundTimer + 1

		if groundTimer == 1 then
			Effect.spawn(751, player.x-18, player.y+40, player.section)
		end

		if player.speedX < 0 or player.speedX > 5 then
			if lunatime.tick() % 18 == 0 then
				local smoke = Effect.spawn(757, player.x-12, player.y+32, player.section)
				smoke.direction = player.direction
			end
		end
	else
		groundTimer = 0
	end

	--Text.print(groundTimer, 8, 8)
end