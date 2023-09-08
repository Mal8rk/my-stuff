local cut = require("cutscene")

function onEvent(eventName)
	if eventName == "Start Cutscene" then
        cut.bars(true)
    elseif eventName == "End Cutscene" then
        cut.bars(false)
    end
end