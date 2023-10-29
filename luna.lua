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
local pauseplus = require("pauseplus")

littleDialogue.defaultStyleName = "yi"

warpTransition.levelStartTransition = warpTransition.TRANSITION_FADE

hudoverride.visible.lives = false
hudoverride.visible.coins = false
hudoverride.visible.score = false

if not GameData.seenTitle and Level.filename() ~= "Title Screen.lvlx" then
	Level.load("Title Screen.lvlx")
end

function onStart()
	player.character = CHARACTER_KLONOA;
	player.powerup = 1;

		pauseplus.createSubmenu("main",{headerText = "PAUSED",headerTextFont = MKDS})
		pauseplus.createOption("main",{text = "Resume",closeMenu = true})
		
		if Level.filename() ~= "1-0.lvlx" and Level.filename() ~= "map.lvlx" then
			pauseplus.createOption("main",{text = "Restart Level",goToSubmenu = "restartConfirmation"}, 2)
			pauseplus.createOption("main",{text = "Exit Level",goToSubmenu = "exitConfirmation"}, 3)
		end

		if Level.filename() == "map.lvlx" then
			pauseplus.createOption("main",{text = "Save Game",action = pauseplus.save,sfx = 58,closeMenu = true})
		end
	
		pauseplus.createOption("main",{text = "Quit Game",goToSubmenu = "quitConfirmation"})

		pauseplus.createSubmenu("exitConfirmation",{headerText = "<align center>Exit the Level?<br>All unsaved progress<br>will be lost</align>"})
		pauseplus.createOption("exitConfirmation",{text = "Yes",closeMenu = true,action = function() mem(0xB25728, FIELD_BOOL, true) exitLevel() end})
		pauseplus.createOption("exitConfirmation",{text = "No",goToSubmenu = "main"})
	
		pauseplus.createSubmenu("quitConfirmation",{headerText = "<align center>Quit the game?<br>All unsaved progress<br>will be lost.</align>"})
		pauseplus.createOption("quitConfirmation",{text = "Yes",action = pauseplus.quit})
		pauseplus.createOption("quitConfirmation",{text = "No",goToSubmenu = "main"})
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

function onExitLevel()
	pauseplus.canPause = true
end