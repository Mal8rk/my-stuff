local npcManager = require("npcManager")
local paletteChange = require("paletteChange")

local sampleNPC = {}

local npcID = NPC_ID

local sampleNPCSettings = {
	id = npcID,

	gfxheight = 32,
	gfxwidth = 32,

	width = 32,
	height = 32,

	gfxoffsetx = 0,
	gfxoffsety = 0,

	frames = 8,
	framestyle = 1,
	framespeed = 6, 

	speed = 1,

	npcblock = false,
	npcblocktop = false, 
	playerblock = false,
	playerblocktop = false, 

	nohurt=true,
	nogravity = false,
	noblockcollision = false,
	nofireball = false,
	noiceball = false,
	noyoshi= false,
	nowaterphysics = false,

	jumphurt = false, 
	spinjumpsafe = false, 
	harmlessgrab = false, 
	harmlessthrown = false, 

	grabside=false,
	grabtop=false,
	cliffturn=true,
}

npcManager.setNpcSettings(sampleNPCSettings)

npcManager.registerHarmTypes(npcID,
	{
		--HARM_TYPE_JUMP,
		--HARM_TYPE_FROMBELOW,
		HARM_TYPE_NPC,
		HARM_TYPE_PROJECTILE_USED,
		HARM_TYPE_LAVA,
		--HARM_TYPE_HELD,
		HARM_TYPE_TAIL,
		HARM_TYPE_SPINJUMP,
		--HARM_TYPE_OFFSCREEN,
		HARM_TYPE_SWORD
	}, 
	{
		--[HARM_TYPE_JUMP]=10,
		--[HARM_TYPE_FROMBELOW]=10,
		[HARM_TYPE_NPC]=753,
		[HARM_TYPE_PROJECTILE_USED]=753,
		[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		--[HARM_TYPE_HELD]=10,
		[HARM_TYPE_TAIL]=753,
		[HARM_TYPE_SPINJUMP]=753,
		--[HARM_TYPE_OFFSCREEN]=10,
		[HARM_TYPE_SWORD]=753,
	}
);



function sampleNPC.onInitAPI()
	npcManager.registerEvent(npcID, sampleNPC, "onTickNPC")
	npcManager.registerEvent(npcID, sampleNPC, "onDrawNPC")
end

local function doCollision(p, v)
	if Colliders.collide(p, v) and not v.friendly and p:mem(0x13E, FIELD_WORD) == 0 then
		p:mem(0x40, FIELD_WORD, 0) --player climbing state, if he's climbing then have him stop climbing
		Audio.playSFX("duou.ogg") --bump sound
		p.speedX = Defines.player_runspeed
		if p.x < v.x then
			p.speedX = p.speedX * -1
		end
	end
end

function sampleNPC.onTickNPC(v)

    local data = v.data
    local settings = v.data._settings

    if Defines.levelFreeze then return end

	if v:mem(0x12A, FIELD_WORD) <= 0 then return end --offscreen
	if v:mem(0x12C, FIELD_WORD) > 0 or v:mem(0x136, FIELD_BOOL) or v:mem(0x138, FIELD_WORD) > 0 then 
	    v.animationFrame = 4
		v.animationTimer = 0
		return
	end --grabbed/thrown/generated

	--Collision with player.
	for _, p in ipairs(Player.get()) do
		doCollision(p, v)
	end

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		data.initialized = true
		data.timer = 0
		data.shake = 0
		data.palette = 0
		data.scale = 0
		data.shakeY = 0
	end

	--do not show the smoke effect that appears when you jump on the npc
	for _, e in ipairs(Animation.getIntersecting(v.x, v.y, v.x + 32, v.y + 32)) do
		e.width = 0
		e.height = 0
	end

	data.timer = data.timer + 1

    if settings.type == 0 then
	    v.speedX = NPC.config[npcID].speed * v.direction
		data.timer = 0
	elseif settings.type == 1 then
	    v.speedX = NPC.config[npcID].speed * v.direction
		if data.timer == 925 then
		    v.sectionObj.music = "music/Super Princess Peach OST Boss Fight.ogg"
            v:kill(HARM_TYPE_VANISH)
			local boss = NPC.spawn(970, v.x - 32, v.y - 60, player.section)
			boss.data.state = 7
			boss.direction = -1
		elseif data.timer >= 901 then
		    v.speedX = 0
		    v.animationFrame = 0
			v.animationTimer = 0
		elseif data.timer == 900 then
		    SFX.play(1)
            v.speedY = -8
		    v.speedX = 0
		elseif data.timer >= 500 then
		    v.speedX = 0
		    v.animationFrame = 2
			v.animationTimer = 0
			if data.shakeY == 2 then
				data.shakeY = 0
				v.y = v.y + 1
			else
				data.shakeY = 2
				v.y = v.y - 1
			end
		elseif data.timer >= 160 then
		    data.palette = 0
		    v.animationFrame = 2
			v.animationTimer = 0
			v.speedX = 0
		end
	end

	if not Defines.levelFreeze then
		if data.palette > 0 and lunatime.tick() % 6 == 0 then
			data.palette = (data.palette % 15) + 1
		end
	end
end

local scalingBuffer = Graphics.CaptureBuffer(32,32)

local RENDER_SCALE = 0.5

function sampleNPC.onDrawNPC(v)
	if v.despawnTimer <= 0 or v.isHidden then return end

    local data = v.data
    local settings = v.data._settings

	if not data.initialized then return end

	local config = NPC.config[v.id]

	if data.sprite == nil then
		data.sprite = Sprite{texture = Graphics.sprites.npc[v.id].img,frames = config.frames,pivot = Sprite.align.CENTRE}
	end

	local priority = -44
	
	local noiseTexture = Graphics.sprites.hardcoded["53-0"].img


	scalingBuffer:clear(priority)
	--Graphics.drawBox{target = scalingBuffer,x = 0,y = 0,width = scalingBuffer.width,height = scalingBuffer.height,priority = priority,color = Color.purple}

	data.sprite.x = scalingBuffer.width * 0.5
	data.sprite.y = scalingBuffer.height * 0.5
	data.sprite.scale = vector(RENDER_SCALE * data.scale,RENDER_SCALE * data.scale)

	data.sprite:draw{frame = data.frame,priority = priority,target = scalingBuffer,shader = mainShader,uniforms = {
		noiseTexture = noiseTexture,
		noiseSize = vector(noiseTexture.width,noiseTexture.height),
		teleportFade = data.teleportFade,

		imageSize = vector(Graphics.sprites.npc[v.id].img.width,Graphics.sprites.npc[v.id].img.height),
		frames = vector(1,data.sprite.frames),
	}}

	local shader,uniforms = paletteChange.getShaderAndUniforms(data.palette, "palette.png")

	Graphics.drawBox{
		texture = scalingBuffer,centred = true,sceneCoords = true,priority = priority,
		x = v.x + v.width*0.5 + config.gfxoffsetx,
		y = v.y + v.height - (Graphics.sprites.npc[v.id].img.height / config.frames)*0.5 + config.gfxoffsety + ((lunatime.tick() % 2) - 0.5)*2*data.shake,
		width = (scalingBuffer.width / RENDER_SCALE) * -v.direction,height = scalingBuffer.height / RENDER_SCALE,
		sourceWidth = scalingBuffer.width,sourceHeight = scalingBuffer.height,
		shader = shader,uniforms = uniforms,
	}
end

return sampleNPC