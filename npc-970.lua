local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local sampleNPC = {}

local npcID = NPC_ID

local sampleNPCSettings = {
	id = npcID,

	gfxheight = 128,
	gfxwidth = 128,

	width = 96,
	height = 96,

	gfxoffsetx = 0,
	gfxoffsety = 0,

	frames = 11,
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
	nofireball = true,
	noiceball = true,
	noyoshi= true,
	nowaterphysics = false,

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

local STATE_WALKING = 0
local STATE_JUMP = 1
local STATE_HASTY = 2
local STATE_FLIP = 3

function sampleNPC.onInitAPI()
	npcManager.registerEvent(npcID, sampleNPC, "onTickEndNPC")
	npcManager.registerEvent(npcID, sampleNPC, "onDrawNPC")
end

local function doSquish(v)
	local data = v.data
	local config = NPC.config[v.id]

	if v.collidesBlockBottom then
		data.timer = data.timer + 1
		--Squash an stretch the sprite a bit to make it look like it's... dancing?
		if data.timer <= 16 then
				
			--Timer move up and down, the one controlling horizontal squishing is twice as fast as the one controlling the up and down
			data.squishTimer = data.squishTimer + 0.3
			data.stretchTimer = data.stretchTimer - 0.78
				
			--Set the horizontal squishing to -12 to a frame, to give it a "bob" effect
			if data.timer == 10 then
				data.stretchTimer = -10
				data.squishTimer = 2
			end	
		elseif data.timer > 16 and data.timer <= 30 then
			
			data.squishTimer = data.squishTimer - 0.5
			data.stretchTimer = data.stretchTimer + 1
				
			--Similarly here, set it to -8
			if data.timer == 20 then
				data.stretchTimer = 8
			end
		else
			--Set the timer to -4, to finish the animation and reset it.
			if data.timer >= 31 then
				data.timer = -8
			end
		end			
	else
		data.timer = 0
		data.stretchTimer = 0
		data.squishTimer = 0
	end
end

local function doCollision(p, v)
	if Colliders.collide(p, v) and not v.friendly and p:mem(0x13E, FIELD_WORD) == 0 then
		p:mem(0x40, FIELD_WORD, 0) --player climbing state, if he's climbing then have him stop climbing
		Audio.playSFX(24) --bump sound
		p.speedX = Defines.player_runspeed
		if p.x < v.x then
			p.speedX = p.speedX * -1
		end
	end
end

function sampleNPC.onTickEndNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	local config = NPC.config[v.id]
	v.animationTimer = 0
	
	if v.despawnTimer <= 0 then
		data.initialized = false
		return
	end

	if not data.initialized then
		data.initialized = true
		data.squishTimer = 0
		data.stretchTimer = 0
		data.timer = data.timer or 0
		data.state = STATE_WALKING
		data.stateTimer = 0
	end

	if v:mem(0x12C, FIELD_WORD) > 0
	or v:mem(0x136, FIELD_BOOL)
	or v:mem(0x138, FIELD_WORD) > 0
	then
	    data.squishTimer = 0
		data.stretchTimer = 0
	end

	if data.state == STATE_WALKING then
	    data.stateTimer = data.stateTimer + 1
		npcutils.faceNearestPlayer(v)
	    v.speedX = sampleNPCSettings.speed * v.direction
		v.animationFrame = math.floor(lunatime.tick() / 6) % 10
	    for _, p in ipairs(Player.get()) do
		    doCollision(p, v)
	    end

		if data.stateTimer >= 120 then
		    data.state = STATE_JUMP
			data.stateTimer = 0
			v.speedX = 0
		end
	elseif data.state == STATE_JUMP then
	    data.stateTimer = data.stateTimer + 1
		if data.stateTimer >= 1 and data.stateTimer < 20 then
		    v.animationFrame = 3
			doSquish(v)
		elseif data.stateTimer == 20 then
		    v.speedX = sampleNPCSettings.speed * v.direction
			v.speedY = -14
			v.animationFrame = 0
			SFX.play(24)
			data.timer = 0
			data.squishTimer = 0
			data.stretchTimer = 0
		elseif data.stateTimer >= 136 and data.stateTimer <= 166 then
			doSquish(v)
			if data.stateTimer == 136 and v.collidesBlockBottom then
			    Defines.earthquake = 7
				local npc = NPC.spawn(880, Camera.get()[1].x + RNG.randomInt(-536, 800), Camera.get()[1].y + 1 * 10 - 60, player.section)
				v.speedX = 0
				SFX.play(37)
				v.animationFrame = 3
				v.animationTimer = 0
			elseif data.stateTimer == 166 then
				data.timer = 0
				data.stretchTimer = 0
				data.squishTimer = 0
			end
		elseif data.stateTimer == 200 then
		    data.state = STATE_WALKING
			data.stateTimer = 0
		end
	end

	-- animation controlling
	v.animationFrame = npcutils.getFrameByFramestyle(v, {
		frame = data.frame,
		frames = sampleNPCSettings.frames
	});
end

local function drawSprite(args) -- handy function to draw sprites
	args = args or {}

	args.sourceWidth  = args.sourceWidth  or args.width
	args.sourceHeight = args.sourceHeight or args.height

	if sprite == nil then
		sprite = Sprite.box{texture = args.texture}
	else
		sprite.texture = args.texture
	end

	sprite.x,sprite.y = args.x,args.y
	sprite.width,sprite.height = args.width,args.height

	sprite.pivot = args.pivot or Sprite.align.TOPLEFT
	sprite.rotation = args.rotation or 0

	if args.texture ~= nil then
		sprite.texpivot = args.texpivot or sprite.pivot or Sprite.align.TOPLEFT
		sprite.texscale = args.texscale or vector(args.texture.width*(args.width/args.sourceWidth),args.texture.height*(args.height/args.sourceHeight))
		sprite.texposition = args.texposition or vector(-args.sourceX*(args.width/args.sourceWidth)+((sprite.texpivot[1]*sprite.width)*((sprite.texture.width/args.sourceWidth)-1)),-args.sourceY*(args.height/args.sourceHeight)+((sprite.texpivot[2]*sprite.height)*((sprite.texture.height/args.sourceHeight)-1)))
	end

	sprite:draw{priority = args.priority,color = args.color,sceneCoords = args.sceneCoords or args.scene}
end

function sampleNPC.onDrawNPC(v)
	local config = NPC.config[v.id]
	local data = v.data

	if v:mem(0x12A,FIELD_WORD) <= 0 then return end

	local priority = -45
	if config.priority then
		priority = -15
	end

	drawSprite{
		texture = Graphics.sprites.npc[v.id].img,

		x = (v.x - data.stretchTimer)+(v.width/2)+config.gfxoffsetx + data.stretchTimer,y = v.y+v.height-(config.gfxheight/2)+config.gfxoffsety + data.squishTimer * 2,
		width = config.gfxwidth - data.stretchTimer,height = config.gfxheight - data.squishTimer * 4,

		sourceX = 0,sourceY = v.animationFrame*config.gfxheight,
		sourceWidth = config.gfxwidth,sourceHeight = config.gfxheight,

		priority = priority,rotation = data.rotation,
		pivot = Sprite.align.CENTRE,sceneCoords = true,
	}

	npcutils.hideNPC(v)
end

return sampleNPC