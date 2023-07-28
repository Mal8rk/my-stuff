local cutscene = {}

local skipOpacity = 0
local count = false

cutscene.endCutscene = {}

--When this is set to true, do stuff in the luna.lua file
local endC = cutscene.endCutscene

local play

--Example: This will skip the cutscene.
--cut.bars(true)

function cutscene.bars(start)
	if start then 
		play = true
	else
		play = false
	end
end

--[[Example on how to use this:
	if cutscene.endCutscene.doEventsforCutEnd then
		SFX.play(1)
		player:kill()
		cut.endCutscene.doEventsforCutEnd = false
	end]]

--A function to skip a cutscene
function cutscene.skip(skip)
	if skip then 
		play = false
		endC.doEventsforCutEnd = true
		endC.unskippable = false
	end
end

function cutscene.onInitAPI()
	registerEvent(cutscene, "onTick")
    registerEvent(cutscene, "onDraw")
end

local yDown = -80
local yUp = 600

local skipButton = Graphics.loadImage(Misc.resolveFile("skipButton.png"))

function cutscene.onTick()
	if play then
		--Skip the cutscene if the player jumps
		if not endC.unskippable then
			if player.keys.jump == KEYS_PRESSED then
				if skipOpacity <= 0.5 then
					count = true
				elseif skipOpacity >= 0 then
					cutscene.skip(true)
				end
			end
		end

		if not count then
			if skipOpacity > 0 then
				skipOpacity = skipOpacity - 0.01
			end
		else
			skipOpacity = skipOpacity + 0.01
			if skipOpacity >= 1.5 then
				count = false
			end
		end
	else
		skipOpacity = 0
		count = false
	end
end

function cutscene.onDraw()

	if play then
		--Move down when it appears
		yDown = yDown + 6
		
		if yDown >= 0 then
			yDown = 0
		end
			
		--Move up when it appears
		yUp = yUp - 6
		
		if yUp <= 520 then
			yUp = 520
		end
		
		--Draw the skip button
		Graphics.drawImageWP(skipButton, 600, 528, skipOpacity, 51)
		
	else
		yDown = yDown - 6
		
		if yDown <= -80 then
			yDown = -80
		end
		
		
		yUp = yUp + 6
		
		if yUp >= 600 then
			yUp = 600
		end
	end
	
	--Render the image
	Graphics.drawBox{
		x = 0,
		y = yUp,
		width = 800,
		height = 80,
		sceneCoords = false,
		priority = 50,
		color = Color.black
	}
	
	--Render the image
	Graphics.drawBox{
		x = 0,
		y = yDown,
		width = 800,
		height = 80,
		sceneCoords = false,
		priority = 50,
		color = Color.black
	}
end

return cutscene