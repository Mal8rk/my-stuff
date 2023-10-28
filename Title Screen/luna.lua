local littleDialogue = require("littleDialogue")
local warpTransition = require("warpTransition")
Graphics.activateHud(false)

local logo = Graphics.loadImageResolved("yoshi_journey.png")
local mal8rk = Graphics.loadImageResolved("made_by_mal8rk.png")
local press_start = Graphics.loadImageResolved("press_start.png")

local opacity = 0
local triggerExit = false
local sfxPlayed = false

local x = 180
local y = 140

local x2 = 250
local y2 = 450
local movementTimer = 0

local alpha = 0
local alpha2 = 0
local alpha3 = 0
local timer = 0

local newTimer = 0
local title = false

local frame = 0

function onTick()
    timer = timer + 1

    if timer > 32 and not triggerExit then
        Graphics.drawImageWP(mal8rk, x + 100, y + 110, alpha, -50)
        if alpha < 1 then
            alpha = alpha + 0.09
        end

        if timer == 33 then 
            SFX.play("smrpg_correct.ogg")
        end
    end

    if timer > 160 then
        if alpha > 0 then
            alpha = alpha - 0.25
        end
    end

    if timer > 210 and not triggerExit then
        begin = true

        Graphics.drawImageWP(logo, x, y - 80, alpha2, -50)
        if alpha2 < 1 then
            alpha2 = alpha2 + 0.15
        end

        movementTimer = movementTimer + 1
        y2 = math.cos(0.09 * movementTimer)*3 + 450

        for k, v in pairs(player.rawKeys) do
            if player.rawKeys[k] == KEYS_PRESSED then
                triggerExit = true
                if not sfxPlayed then
                    SFX.play("reveal.ogg")
                    sfxPlayed = true
                end
            end
        end
    end

    Text.print(newTimer, 8, 8)

    if triggerExit then
        Graphics.drawImageWP(logo, x, y - 80, alpha2, -50)
        frame = math.floor(lunatime.tick() / 5) % 2

        if not stopTimer then
            newTimer = newTimer + 1

            if newTimer > 32 then
                Graphics.drawScreen{color = Color.black.. opacity,priority = 2}
                Audio.MusicFadeOut(player.section, 100)
                if opacity < 1 then
                    opacity = opacity + 0.08
                end
            end
            if newTimer == 53 then
                if SaveData.introFinished then
                    Level.load("map.lvlx")
                else
                    stopTimer = true
                    littleDialogue.create{
                        text = "Have you played this game before?<question playedBefore>",
                        pauses = false,
                        forcedPosX = 400,
                        forcedPosY = 300,
                        settings = {typewriterEnabled = false}
                    }
                end
            end
        end

        if hasPlayedBefore ~= nil then
            stopTimer = false
        end
        if newTimer == 100 then
            if hasPlayedBefore then
                playedBefore()
            else
                notPlayedBefore()
            end
        end
    end
end

littleDialogue.registerAnswer("playedBefore",{text = "Yes",addText = "Want to skip the Intro and the Tutorial?<question confirmSkipIntro>"})
littleDialogue.registerAnswer("playedBefore",{text = "No",chosenFunction = function() hasPlayedBefore = false end})

littleDialogue.registerAnswer("confirmSkipIntro",{text = "Yes",chosenFunction = function() hasPlayedBefore = true end})
littleDialogue.registerAnswer("confirmSkipIntro",{text = "No",chosenFunction = function() hasPlayedBefore = false end})

function playedBefore()
    SaveData.introFinished = true
    Level.load("map.lvlx")
end

function notPlayedBefore()
    Level.load("Intro.lvlx")
end

function onDraw()
	if begin then
		Graphics.draw{
			type = RTYPE_IMAGE,
			image = press_start,
			x = x2,
			y = y2,
			priority = 1,
			sceneCoords = false,
			sourceX = 0,
			sourceY = frame * 32,
			sourceWidth = 280,
			sourceHeight = 32
		}
	end
end