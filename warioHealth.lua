--[[
					warioHealth.lua by MrNameless
				A library that gives (basegame) Wario his own 
				  unique health system & some extra stuff.
			
	CREDITS:
	cl.exe - ripped the Wario Land 4 UI sprites used in this library (https://www.spriters-resource.com/game_boy_advance/wl4/sheet/19794/)
	King_Harkinian - ripped the Wario Land 4 SFXs used in this library (https://www.sounds-resource.com/game_boy_advance/warioland4/) 
	
	TO DO:
	-Find the Wario Land Beeping Sound that plays when Wario has one health left.
	-Fix the SMB2 hearts still showing when using the script as one of the "SMB2 health" chars.
	-Improve how this is programmed whenever I rewrite this one day. Seriously, this code looks extremely sloppy.
	
	Note: this library was not tested much with other libraries in mind so be careful!
	Another Note: this library wasn't tested much with the other X2 characters aswell!
	
	Version 0.9.0 (Not 1.0.0 because im not completely satisfied with the current state of this script, but I still want to release it anyways.)
]]--



local npcManager = require("npcManager")

-- respawn rooms stuff --
local respawnRooms
pcall(function() respawnRooms = require("respawnRooms") end)
respawnRooms = respawnRooms or {}
-------------------------

local warioHealth = {}

local coinBar = 0
local coinsCollected = 0
local lowHPOffset = 1
local beepTimer = 64
local healthOffsetX = 5
local healthOffsetY = 0

SaveData.warioHP = SaveData.warioHP or 0
local HPBar = Graphics.loadImage(Misc.resolveFile("warioHealth/warioHPBar.png")) -- graphic used for wario's health bar
local RegenBar = Graphics.loadImage(Misc.resolveFile("warioHealth/warioRegenBar.png")) -- graphic used for wario's HP regen bar
local nothingness = Graphics.loadImage(Misc.resolveFile("warioHealth/wahNothing.png")) -- graphic used to hide the reserve box
local coinMin = Misc.resolveFile("warioHealth/regen_mini.ogg") -- sound used when wario collects 2 coins to fill up the regen bar
local coinFull = Misc.resolveFile("warioHealth/regen_full.ogg") -- sound used when wario gains a heart
local lowHPBeep = Misc.resolveFile("warioHealth/hp_low.ogg") -- sound used when wario is at one health remaining.
local powerupIDs = table.map{9,14,34,169,170,182,183,184,185,249,250,264,277,462}
local coinIDs = table.map{10,33,88,103,138,152,251,252,253,258,274,411,903}
local heartChars = table.map{3,4,5,9,11}
local miscChars = table.map{8,14}

-- configurable settings --
warioHealth.startingHP = 5 -- how much health should wario start out with? (2 by default)
warioHealth.HPCap = 8 -- what is the maximum health possible for wario to have? (3 by default, maximum of 8 only.)
warioHealth.forceHP = false -- should wario always be forced to start out with whatever the startingHP is set to (false by default)
warioHealth.coinBarToggle = true -- should wario have a mini bar that gives him 1 health everytime he collects enough coins (true by default)
warioHealth.smallOnLow = false -- should wario become small whenever he has one health left? (false by default)
warioHealth.beepOnLow = false -- should there be a constant beeping sound whenever wario has one health left? (true by default)
warioHealth.hurtKnockback = true -- should wario take a bit of knockback upon getting hurt? (true by default)
warioHealth.keepReserveBox = false -- should wario be able to store backup items like how mario & luigi could? (false by default)
warioHealth.workAllChars = true -- should this script be usable with ALL characters aside from Wario? (false by default)
---------------------------


function warioHPStartup()
	if SaveData.warioHP <= 0 or warioHealth.forceHP then SaveData.warioHP = warioHealth.startingHP end
	if warioHealth.startingHP <= 1 and warioHealth.smallOnLow and SaveData.warioHP and (player.character == CHARACTER_WARIO and not warioHealth.workAllChars) then
		player.powerup = 1
	else
		player.powerup = player.powerup
	end
end
warioHPStartup()

local function coinRegen(amount)
	if coinBar <= 7 then
		coinBar = coinBar + amount
		SFX.play(coinMin)
	end
	if coinBar > 7 then
		if SaveData.warioHP >= warioHealth.HPCap then 
			coinBar = 8 
		else
			if player.powerup == 1 and player.forcedState == 0 then 
				player.forcedState = 0
				player:mem(0x140, FIELD_WORD, 50)
				SFX.play(6)
			end
			SaveData.warioHP = SaveData.warioHP + 1
			SFX.play(coinFull)
			coinBar = 0 
		end
	end
	coinsCollected = 0
end

local function beepHandling()
	if player.deathTimer > 0 then return
	elseif SaveData.warioHP > 1 then beepTimer = 64 lowHPOffset = 1 return end
	beepTimer = beepTimer + 1
	if beepTimer == 65 then
		if warioHealth.beepOnLow then SFX.play(lowHPBeep) end
		beepTimer = 0
		lowHPOffset = -1
	elseif beepTimer == 33 then
		lowHPOffset = 1
	end
	--Text.print(beepTimer,100,100) -- for debug purposes only
end
function warioHealth.onInitAPI()
	registerEvent(warioHealth, "onTickEnd")
	registerEvent(warioHealth, "onDraw")
	registerEvent(warioHealth, "onPostBlockHit")
	registerEvent(warioHealth, "onPostPlayerHarm")
	registerEvent(warioHealth, "onPostNPCKill")
	registerEvent(warioHealth, "onPlayerKill")
end

function warioHealth.onTickEnd()
	if player.character ~= CHARACTER_WARIO and not warioHealth.workAllChars then return end 
	if SaveData.warioHP > warioHealth.HPCap then SaveData.warioHP = warioHealth.HPCap end -- failsafe if wario somehow has more health than the set HP cap.
	if warioHealth.keepReserveBox == false and not miscChars[player.character] then 
		player.reservePowerup = 0 	
		hideBox = true
		healthOffsetX = 5
		healthOffsetY = 0
	else
		healthOffsetX = -4
		healthOffsetY = 55
		hideBox = false
	end

	if (not warioHealth.smallOnLow or SaveData.warioHP > 1) and player.powerup == 1 and player.forcedState == 0 then --failsafe if wario is still small despite having more than 1 health
		player.powerup = 2
	end

	beepHandling()
end

function warioHealth.onDraw()
	if player.character ~= CHARACTER_WARIO and not warioHealth.workAllChars then Graphics.sprites.hardcoded["48-0"].img = nil return end
	if warioHealth.workAllChars and heartChars[player.character] then
		Graphics.sprites.hardcoded["36-1"].img = nothingness
		Graphics.sprites.hardcoded["36-2"].img = nothingness
	else
		Graphics.sprites.hardcoded["36-1"].img = nil
		Graphics.sprites.hardcoded["36-2"].img = nil
	end
	if hideBox == true then
		Graphics.sprites.hardcoded["48-0"].img = nothingness
	else
		Graphics.sprites.hardcoded["48-0"].img = nil
	end
	Graphics.draw{
		type = RTYPE_IMAGE,
		image = HPBar,
		priority = 5,
		x =  (16 + healthOffsetX) + (56.875 - (6.875 * warioHealth.HPCap)),-- 340 + (8 * warioHealth.HPCap),--468 - (16 * warioHealth.HPCap), -- 340 originally
		y = 27 + healthOffsetY,
		sourceWidth = 32  * warioHealth.HPCap,
		sourceHeight = 32,
		sourceY = 32 * (SaveData.warioHP),
	}
	if not warioHealth.coinBarToggle then return end
	Graphics.draw{
		type = RTYPE_IMAGE,
		image = RegenBar,
		priority = 5,
		x = (16 + healthOffsetX),
		y = 52 + healthOffsetY,
		sourceHeight = 32,
		sourceY = 32 * coinBar,
	}
	--SFX.play(26)
end

function warioHealth.onPostBlockHit(hitBlock,fromUpper,playerOrNil)
	if (player.character ~= CHARACTER_WARIO and not warioHealth.workAllChars) or not warioHealth.coinBarToggle then return end 
	if hitBlock.contentID < 100 and hitBlock.contentID > 0 then
		coinsCollected = coinsCollected + 1
		if coinsCollected == 2 then
			coinRegen(1)
		end
	end
end

function warioHealth.onPostPlayerHarm(harmedPlayer)
	if harmedPlayer.character ~= CHARACTER_WARIO and not warioHealth.workAllChars then return end
	SaveData.warioHP = SaveData.warioHP - 1
	if SaveData.warioHP <= 0 then 
		harmedPlayer:kill() return
	elseif SaveData.warioHP == 1 and warioHealth.smallOnLow then 
		harmedPlayer.powerup = 1
		SFX.play(5)
	elseif player.powerup > 2 then
		harmedPlayer.powerup = 2
		SFX.play(5)
	end
	if coinBar >= 8 and SaveData.warioHP >= (warioHealth.HPCap - 1) then 
		SaveData.warioHP = SaveData.warioHP + 1
		SFX.play(coinFull)
		coinBar = 0 
	end
	if warioHealth.hurtKnockback == true then
		harmedPlayer.speedX = -4 * player.direction
		harmedPlayer.speedY = -4
	end
	harmedPlayer:mem(0x140, FIELD_WORD, 150)
	SFX.play(76)
end


function warioHealth.onPostNPCKill(killedNPC, harmType)
	if player.character ~= CHARACTER_WARIO and not warioHealth.workAllChars then return end
	if not npcManager.collected(killedNPC,9) then return end
	if coinIDs[killedNPC.id] and warioHealth.coinBarToggle then
		coinsCollected = coinsCollected + 1
		if killedNPC.id == 252 or killedNPC.id == 258 then
			coinRegen(1)
		elseif killedNPC.id == 253 then
			coinRegen(1)
		end
		if coinsCollected == 6 then
			coinRegen(1)
		end
	end
	if powerupIDs[killedNPC.id] then
		if killedNPC:mem(0x138, FIELD_WORD) == 2 then return end
		if SaveData.warioHP >= warioHealth.HPCap then return end
		SaveData.warioHP = SaveData.warioHP + 1 
		if warioHealth.coinBarToggle == true then 
			SFX.play(coinFull) 
		end
 	end
end


function warioHealth.onPlayerKill()
	if player.character ~= CHARACTER_WARIO and not warioHealth.workAllChars then return end
	SaveData.warioHP = 0
	coinsCollected = 0
	beepTimer = -100 
	lowHPOffset = 1 
end

function respawnRooms.onPreReset(fromRespawn)
	if fromRespawn then
		warioHPStartup()
		coinBar = 0
	end
end

return warioHealth