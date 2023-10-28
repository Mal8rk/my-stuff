require("collectibleLibs/level E-coins")
function onEvent(eventName)
    if eventName == "l" then
       Effect.spawn(772, -176064 + -40, -182720 + -40)
    elseif eventName == "o" then
       Effect.spawn(772, -176000 + -40, -182848 + -40)
    elseif eventName == "g" then
       Effect.spawn(772, -176128 + -40, -182976 + -40)
    elseif eventName == "u" then
       Effect.spawn(772, -176000 + -40, -183104 + -40)
    end
end
