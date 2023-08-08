local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local sampleNPC = {}

local npcID = NPC_ID

local sampleNPCSettings = {
	id = npcID,

	gfxwidth = 128,
	gfxheight = 96,

	gfxoffsetx = 0,
	gfxoffsety = 24,
	
	width = 48,
	height = 32,
	
	frames = 13,
	framestyle = 1,
	framespeed = 8,

	speed = 1,

	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,

	nohurt = false,
	nogravity = true,
	noblockcollision = true,
	nofireball = false,
	noiceball = true,
	noyoshi = true,
	nowaterphysics = true,
	
	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,

	grabside=false,
	grabtop=false,
}

npcManager.setNpcSettings(sampleNPCSettings)

npcManager.registerHarmTypes(npcID,
	{
		--HARM_TYPE_JUMP,
		--HARM_TYPE_FROMBELOW,
		--HARM_TYPE_NPC,
		--HARM_TYPE_PROJECTILE_USED,
		--HARM_TYPE_LAVA,
		--HARM_TYPE_HELD,
		--HARM_TYPE_TAIL,
		--HARM_TYPE_SPINJUMP,
		--HARM_TYPE_OFFSCREEN,
		--HARM_TYPE_SWORD
	}, 
	{
		--[HARM_TYPE_JUMP]=10,
		--[HARM_TYPE_FROMBELOW]=10,
		--[HARM_TYPE_NPC]=10,
		--[HARM_TYPE_PROJECTILE_USED]=10,
		--[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		--[HARM_TYPE_HELD]=10,
		--[HARM_TYPE_TAIL]=10,
		--[HARM_TYPE_SPINJUMP]=10,
		--[HARM_TYPE_OFFSCREEN]=10,
		--[HARM_TYPE_SWORD]=10,
	}
);

local magicEffectImage = Graphics.loadImageResolved("magic.png")

local thatSound = Misc.resolveSoundFile("thatSound")

local magicEffects = {}

function sampleNPC.onInitAPI()
	npcManager.registerEvent(npcID, sampleNPC, "onTickNPC")
	npcManager.registerEvent(npcID, sampleNPC, "onDrawNPC")
	registerEvent(sampleNPC,"onTick")
	registerEvent(sampleNPC,"onDraw")
end

function sampleNPC.onTickNPC(v)

	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if v.despawnTimer <= 0 then
		data.initialized = false
		return
	end

	if not data.initialized then
		data.initialized = true
		data.timer = data.timer or 0
		data.animTimer = 0
		data.shake = 0
		data.scale = 1
		v.animationTimer = 0
	end

	if v:mem(0x12C, FIELD_WORD) > 0    
	or v:mem(0x136, FIELD_BOOL)        
	or v:mem(0x138, FIELD_WORD) > 0    
	then
		--Handling
	end

	v.despawnTimer = 180
    v:mem(0x124,FIELD_BOOL,true)
	data.timer = data.timer + 1

	if data.timer == 550 then
        v:kill(HARM_TYPE_VANISH)
	elseif data.timer >= 470 then
	    v.speedY = v.speedY - 0.3
		v.speedX = -8
	    v.animationFrame = math.floor(lunatime.tick() / 4) % 2 + 8
	    v.animationTimer = 0
	elseif data.timer >= 460 then
	    v.speedY = 0
		v.x = v.x + 0.3
	    v.animationFrame = 7
	    v.animationTimer = 0
	elseif data.timer >= 450 then
	    v.speedY = 0
		v.x = v.x + 0.3
	    v.animationFrame = 6
	    v.animationTimer = 0
	elseif data.timer >= 375 then
	    v.speedY = math.cos(data.timer / 32) * 0.4
	    v.animationFrame = 0
	    v.animationTimer = 0
	elseif data.timer >= 370 then
	    v.speedY = math.cos(data.timer / 32) * 0.4
	    v.animationFrame = 4
	    v.animationTimer = 0
	elseif data.timer == 350 then
		table.insert(magicEffects,{
			x = v.x + v.width*0.5,
			y = v.y + v.height,
			timer = 0,
		})

		SFX.play(41)
	elseif data.timer >= 335 then
	    v.speedY = math.cos(data.timer / 32) * 0.4
	    v.animationFrame = 5
	    v.animationTimer = 0
	elseif data.timer >= 330 then
	    v.speedY = math.cos(data.timer / 32) * 0.4
	    v.animationFrame = 4
	    v.animationTimer = 0
	elseif data.timer >= 324 then
	    Audio.MusicFadeOut(player.section, 2000)
		v.speedY = math.cos(data.timer / 32) * 0.4
	    data.animTimer = 0
	    v.animationFrame = 0
	    v.animationTimer = 0
	elseif data.timer >= 318 then
        v.sectionObj.music = "music/Kamek's Theme.ogg"
		v.speedY = math.cos(data.timer / 32) * 0.4
	    data.animTimer = 0
	    v.animationFrame = 0
	    v.animationTimer = 0
	elseif data.timer == 287 then
	    SFX.play(thatSound)
	elseif data.timer == 251 then
	    SFX.play(thatSound)
	elseif data.timer >= 250 then
	    v.speedY = math.cos(data.timer / 32) * 0.4
	    data.animTimer = data.animTimer + 1
	    v.animationFrame = math.floor(data.animTimer / 4) % 4 
	    v.animationTimer = 0
	elseif data.timer >= 224 then
	    v.speedY = math.cos(data.timer / 32) * 0.4
	    data.animTimer = 0
	    v.speedX = 0
	    v.animationFrame = 0
	    v.animationTimer = 0
	elseif data.timer >= 200 then
	    Audio.MusicFadeOut(player.section, 1500)
	    v.speedX = v.speedX + 0.3
	    v.animationFrame = 6
	    v.animationTimer = 0
		if v.speedX > -7 then
	        v.animationFrame = 7
	        v.animationTimer = 0
		end
	elseif data.timer >= 1 then
	    v.speedX = -8
	    v.animationFrame = 0
	    v.animationTimer = 0
	end
end

function sampleNPC.onDrawNPC(v)
	local data = v.data
end

local magicEffectShader = Shader()
magicEffectShader:compileFromFile(nil, "magic.frag")

function sampleNPC.onTick()
	for i = #magicEffects, 1, -1 do
		local effect = magicEffects[i]

		effect.timer = effect.timer + 1

		if effect.timer > 256 then
			table.remove(magicEffects,i)
		end
	end
end

function sampleNPC.onDraw()

	for _,effect in ipairs(magicEffects) do

		Graphics.drawBox{
			texture = magicEffectImage,sceneCoords = true,priority = -4,
			color = Color.fromHSV((lunatime.tick()/224) % 1,0.8,0.9),
			x = effect.x - magicEffectImage.width*0.5,y = effect.y - 96,
			height = magicEffectImage.height*2,sourceHeight = magicEffectImage.height,sourceY = 0,
			shader = magicEffectShader,uniforms = {
				imageSize = vector(magicEffectImage.width,magicEffectImage.height),
				time = effect.timer,
			},
		}
	end
end

return sampleNPC