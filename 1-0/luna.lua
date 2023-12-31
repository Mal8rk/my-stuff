local yoshi
pcall(function() yoshi = require("yiYoshi/yiYoshi") end)

local pauseplus = require("pauseplus")

pauseplus.canPause = false

yoshi.introSettings.enabled = false


function onEvent(eventName)
    if eventName == "log" then
       Effect.spawn(772, -158608 + -40, -160352 + -40)
    elseif eventName == "lig2" then
       Effect.spawn(772, -158448 + -40, -160480 + -40)
    elseif eventName == "musicfade" then
       Audio.MusicFadeOut(player.section, 4000)
    elseif eventName == "star buddy 2" then
       SFX.play("star.ogg")
       Effect.spawn(755, -79648 + 32, -80288 + 32, player.section)
    elseif eventName == "star buddy move" then
       SFX.play("star.ogg")
    elseif eventName == "star buddy disapear" then
       SFX.play(6)
       Effect.spawn(752, player.x + 16, player.y + 16, player.section)
    end
end

