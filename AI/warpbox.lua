local enterSFX = Audio.SfxOpen(Misc.resolveFile("warpbox-entrance.ogg"))
local exitSFX = Audio.SfxOpen(Misc.resolveFile("warpbox-exit.ogg"))

local warpBox = {}

warpBox.inWarpBox = {0, 0} -- player 1 & 2
warpBox.warpTimer = {0, 0}
warpBox.warpTime = 90 -- number of ticks the player will be in the box

--Defines NPC config for our NPC. You can remove superfluous definitions.
warpBox.warpBoxSharedSettings = {
	--Sprite size
	gfxheight = 64,
	gfxwidth = 64,
	--Hitbox size. Bottom-center-bound to sprite size.
	width = 64,
	height = 64,
	--Sprite offset from hitbox for adjusting hitbox anchor on sprite.
	gfxoffsetx = 0,
	gfxoffsety = 0,
	--Frameloop-related
	frames = 1,
	framestyle = 0,
	framespeed = 8, --# frames between frame change
	--Movement speed. Only affects speedX by default.
	speed = 0,
	--Collision-related
	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = false, --Also handles other NPCs walking atop this NPC.

	nohurt = true,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi= true,
	nowaterphysics = false,
	--Various interactions
	jumphurt = true, --If true, spiny-like
	spinjumpsafe = false, --If true, prevents player hurt when spinjumping
	harmlessgrab = true, --Held NPC hurts other NPCs if false
	harmlessthrown = true, --Thrown NPC hurts other NPCs if false
	notcointransformable = true
}

function warpBox.enterBox(p, boxid)
	warpBox.inWarpBox[p] = boxid
	warpBox.warpTimer[p] = warpBox.warpTime
	SFX.play(enterSFX)
end

function warpBox.leaveBox(p)
	warpBox.inWarpBox[p] = 0
	warpBox.warpTimer[p] = 0
	SFX.play(exitSFX)	
end

function warpBox.onDraw()
	for k, p in ipairs(Player.get()) do
		if warpBox.inWarpBox[k] > 0 then
			-- make the player invisible
			player:setFrame(1)
		end
	end
end

function warpBox.onTick()
	for k, p in ipairs(Player.get()) do
		if warpBox.inWarpBox[k] > 0 then
			-- While in warp box, players are invincible
			p:mem(0x142, FIELD_WORD, 0)	
			-- Hold the player in the warp box
			p.speedX = 0
			p.speedY = 0
			-- Count down to the warp
			warpBox.warpTimer[k] = warpBox.warpTimer[k] - 1
		end
	end
end

function warpBox.onInitAPI()
	registerEvent(warpBox, "onDraw")
	registerEvent(warpBox, "onTick")
end

return warpBox