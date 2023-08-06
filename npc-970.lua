local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")
local playerStun = require("playerstun")

local sampleNPC = {}

local npcID = NPC_ID

local defeatEffectSound = Misc.resolveSoundFile("defeatEffect")
local smwbossdefeat = Misc.resolveFile("smw-boss-defeat.wav")
local smwbosspoof = Misc.resolveFile("smw-boss-poof.wav")

local defeatEffects = {}

local sampleNPCSettings = {
	id = npcID,

	gfxheight = 128,
	gfxwidth = 128,

	width = 96,
	height = 96,

	gfxoffsetx = 0,
	gfxoffsety = 0,

	frames = 13,
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
	ignorethrownnpcs=true,
}

npcManager.setNpcSettings(sampleNPCSettings)

npcManager.registerHarmTypes(npcID,
	{
		HARM_TYPE_JUMP,
		--HARM_TYPE_FROMBELOW,
		HARM_TYPE_NPC,
		--HARM_TYPE_PROJECTILE_USED,
		--HARM_TYPE_LAVA,
		--HARM_TYPE_HELD,
		--HARM_TYPE_TAIL,
		HARM_TYPE_SPINJUMP,
		HARM_TYPE_OFFSCREEN,
		--HARM_TYPE_SWORD
	}, 
	{
		--[HARM_TYPE_JUMP]=10,
		--[HARM_TYPE_FROMBELOW]=10,
		[HARM_TYPE_NPC]=10,
		--[HARM_TYPE_PROJECTILE_USED]=10,
		--[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		--[HARM_TYPE_HELD]=10,
		--[HARM_TYPE_TAIL]=10,
		[HARM_TYPE_SPINJUMP]=10,
		--[HARM_TYPE_OFFSCREEN]=753,
		--[HARM_TYPE_SWORD]=10,
	}
);

local STATE_WALKING = 0
local STATE_JUMP = 1
local STATE_GROUNDPOUND = 2
local STATE_FLIP = 3
local STATE_HURT = 4
local STATE_DEAD = 5
local STATE_RECOVER = 6

function sampleNPC.onInitAPI()
	npcManager.registerEvent(npcID, sampleNPC, "onTickEndNPC")
	npcManager.registerEvent(npcID, sampleNPC, "onDrawNPC")
	registerEvent(sampleNPC, "onNPCHarm")
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

local function doHurtSquish(v)
	local data = v.data
	local config = NPC.config[v.id]

	if v.collidesBlockBottom then
		data.timer = data.timer + 1
		if data.timer > 1 and data.timer <= 30 then
		    data.squishTimer = data.squishTimer + 0.9
			data.stretchTimer = data.stretchTimer - 1.2
		elseif data.timer > 31 and data.timer <= 52 then
		    data.squishTimer = data.squishTimer - 0.9
			data.stretchTimer = data.stretchTimer + 1.2
		end
	end
end

local function deathEffect(v)
    table.insert(defeatEffects,{
	    x = v.x + v.width*0.5,
		y = v.y + v.height*0.5,

	    timer = 0,
		radius = 0,
		opacity = 1,
    })

	SFX.play(defeatEffectSound)
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

function sampleNPC.onTickEndNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	local config = NPC.config[v.id]
	local shakeTimer = 0
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
		data.rotation = 0
		data.shakeX = 0
		data.shakeY = 0
		data.health = 3
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

		if data.stateTimer >= 130 then
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
				NPC.spawn(880, Camera.get()[1].x + RNG.randomInt(-500, 800), Camera.get()[1].y + 1 * 10 - 60, player.section)
				for k, p in ipairs(Player.get()) do
					if p:isGroundTouching() and not playerStun.isStunned(k) and v:mem(0x146, FIELD_WORD) == player.section then
						playerStun.stunPlayer(k, 90)
						NPC.spawn(974, player.x + 0.5 * player.width, Camera.get()[1].y - 0, player.section, false, true)
					end
				end
				v.speedX = 0
				SFX.play(37)
				v.animationFrame = 3
				v.animationTimer = 0
                if Colliders.collide(player, v) then
                    player:harm()
                end
			elseif data.stateTimer == 166 then
				data.timer = 0
				data.stretchTimer = 0
				data.squishTimer = 0
			end
		elseif data.stateTimer == 200 then
		    data.state = STATE_WALKING
			data.stateTimer = 0
		end
	elseif data.state == STATE_FLIP then
	    data.stateTimer = data.stateTimer + 1
	    v.animationFrame = 10
		data.timer = 0
		data.stretchTimer = 0
		data.squishTimer = 0
	    for _, p in ipairs(Player.get()) do
		    doCollision(p, v)
	    end
	    if data.stateTimer == 1 then
		    data.rotation = 0
	    elseif data.stateTimer >= 2 and data.stateTimer <= 13 then
		    data.rotation = ((data.rotation or 0) + math.deg((8.4 * v.direction)/((v.width+v.height)/-6)))
	    elseif data.stateTimer == 22 then
		    v.speedX = 0
		elseif data.stateTimer > 200 and data.stateTimer <= 310 then
			if data.shakeY == 2 then
				data.shakeY = 0
				v.y = v.y + 1
			else
				data.shakeY = 2
				v.y = v.y - 1
			end
		elseif data.stateTimer == 311 then
		    data.state = STATE_RECOVER
			data.stateTimer = 0
		end
	elseif data.state == STATE_HURT then
	    data.stateTimer = data.stateTimer + 1
		if data.stateTimer >= 1 and data.stateTimer < 50 then
		    data.rotation = 180 * v.direction
		    v.animationFrame = math.floor(data.stateTimer / 5) % 2 + 10
			doHurtSquish(v)
		elseif data.stateTimer == 52 then
			data.timer = 0
			data.stretchTimer = 0
			data.squishTimer = 0
			v.animationFrame = 3
			v.speedY = -5.5
	    elseif data.stateTimer >= 53 and data.stateTimer <= 64 then
		    data.rotation = ((data.rotation or 0) + math.deg((8.4 * v.direction)/((v.width+v.height)/-6)))
		elseif data.stateTimer >= 94 and data.stateTimer <= 115 then
			doSquish(v)
			if data.stateTimer == 94 and v.collidesBlockBottom then
				SFX.play(37)
				v.animationFrame = 3
				v.animationTimer = 0
			elseif data.stateTimer == 115 then
				data.timer = 0
				data.stretchTimer = 0
				data.squishTimer = 0
			end
		elseif data.stateTimer == 160 then
		    data.state = STATE_GROUNDPOUND
			data.stateTimer = 0
		end
	elseif data.state == STATE_RECOVER then
	    data.stateTimer = data.stateTimer + 1
		if data.stateTimer == 1 then
			data.timer = 0
			data.stretchTimer = 0
			data.squishTimer = 0
			v.animationFrame = 3
			v.speedY = -5.5
	    elseif data.stateTimer >= 1 and data.stateTimer <= 13 then
		    data.rotation = ((data.rotation or 0) + math.deg((8.4 * v.direction)/((v.width+v.height)/-6)))
		elseif data.stateTimer >= 44 and data.stateTimer <= 64 then
			doSquish(v)
			if data.stateTimer == 44 and v.collidesBlockBottom then
				SFX.play(37)
				v.animationFrame = 3
				v.animationTimer = 0
			elseif data.stateTimer == 64 then
				data.timer = 0
				data.stretchTimer = 0
				data.squishTimer = 0
			end
		elseif data.stateTimer == 100 then
		    data.state = STATE_WALKING
			data.stateTimer = 0
		end
    elseif data.state == STATE_GROUNDPOUND then
	    data.stateTimer = data.stateTimer + 1
		if data.stateTimer >= 1 and data.stateTimer < 20 then
		    v.animationFrame = 3
			doSquish(v)
		elseif data.stateTimer == 20 then
			v.speedY = -14
			v.animationFrame = 0
			SFX.play(24)
			data.timer = 0
			data.squishTimer = 0
			data.stretchTimer = 0
		elseif data.stateTimer >= 74 and data.stateTimer <= 166 then
			if data.stateTimer == 75 then
				SFX.play(36)
			end
			v.speedY = -Defines.npc_grav
			if data.stateTimer >= 76 and data.stateTimer <= 99 then
		        data.rotation = ((data.rotation or 0) + math.deg((8.4 * -v.direction)/((v.width+v.height)/-6)))
			elseif data.stateTimer >= 120 and data.stateTimer <= 167 then
			    v.speedY = 20
			end
		elseif data.stateTimer == 167 then
			v.speedY = Defines.npc_grav
			Defines.earthquake = 9
			for k, p in ipairs(Player.get()) do
				if p:isGroundTouching() and not playerStun.isStunned(k) and v:mem(0x146, FIELD_WORD) == player.section then
					playerStun.stunPlayer(k, 90)
				end
			end
			local npc = NPC.spawn(972, v.x + 32, v.y + 64)
			local npc2 = NPC.spawn(972, v.x + 32, v.y + 64)
			npc.speedX = -5
			npc2.speedX = 5
			SFX.play(37)
			v.animationFrame = 3
			v.animationTimer = 0
			if Colliders.collide(player, v) then
				player:harm()
			end
		elseif data.stateTimer >= 168 and data.stateTimer <= 189 then
			doSquish(v)
	    elseif data.stateTimer == 190 then
			data.timer = 0
			data.stretchTimer = 0
			data.squishTimer = 0
		elseif data.stateTimer == 220 then
		    data.state = STATE_WALKING
			data.stateTimer = 0
		end
	elseif data.state == STATE_DEAD then
	    data.stateTimer = data.stateTimer + 1
		Audio.MusicFadeOut(player.section, 200)
		v.friendly = true
		if data.stateTimer >= 1 and data.stateTimer < 50 then
		    data.rotation = 180 * v.direction
		    v.animationFrame = math.floor(data.stateTimer / 5) % 2 + 10
			doHurtSquish(v)
		elseif data.stateTimer == 52 then
			data.timer = 0
			data.stretchTimer = 0
			data.squishTimer = 0
			v.animationFrame = 12
			v.speedY = -5.5
	    elseif data.stateTimer >= 53 and data.stateTimer <= 64 then
		    data.rotation = ((data.rotation or 0) + math.deg((8.4 * v.direction)/((v.width+v.height)/-6)))
		elseif data.stateTimer >= 94 and data.stateTimer <= 115 then
			doSquish(v)
			if data.stateTimer == 94 and v.collidesBlockBottom then
				SFX.play(37)
				v.animationFrame = 12
				v.animationTimer = 0
			elseif data.stateTimer == 115 then
				data.timer = 0
				data.stretchTimer = 0
				data.squishTimer = 0
			end
		elseif data.stateTimer == 180 then
		    deathEffect(v)
		elseif data.stateTimer == 260 then
		    deathEffect(v)
		elseif data.stateTimer >= 350 and data.stateTimer <= 370 then
		    data.squishTimer = data.squishTimer - 1
			data.stretchTimer = data.stretchTimer - 3.5
			if data.stateTimer == 351 then
			    SFX.play(smwbossdefeat)
			end
		elseif data.stateTimer >= 371 and data.stateTimer <= 536 then
		    data.squishTimer = data.squishTimer + 0.3
			data.stretchTimer = data.stretchTimer + 1.1
			data.rotation = ((data.rotation or 0) + math.deg((6 * v.direction)/((v.width+v.height)/-6)))
		elseif data.stateTimer == 537 then
		    SFX.play(smwbosspoof)
			v:kill(HARM_TYPE_OFFSCREEN)
			Effect.spawn(753, v.x + 48, v.y + 80)
		end
	end

	-- animation controlling
	v.animationFrame = npcutils.getFrameByFramestyle(v, {
		frame = data.frame,
		frames = sampleNPCSettings.frames
	});
end

function sampleNPC.onNPCHarm(eventObj, v, reason, culprit)
    local data = v.data
    if v.id ~= npcID then return end
	eventObj.cancelled = true

    if culprit then
        if data.state == STATE_FLIP and (reason == HARM_TYPE_JUMP or reason == HARM_TYPE_SPINJUMP) and type(culprit) == "Player" then
		    if culprit.x+culprit.width*0.5 < v.x+v.width*0.5 then
			    culprit.speedX = -4.5
		    else
			    culprit.speedX = 4.5
		    end
		    data.health = data.health - 1
		    data.state = STATE_HURT
			data.stateTimer = 0
			SFX.play(39)
		end
    else
        for _,p in ipairs(NPC.getIntersecting(v.x - 12, v.y - 12, v.x + v.width + 12, v.y + v.height + 12)) do
            if data.state == STATE_WALKING and p.id == 953 then
                p:kill(HARM_TYPE_VANISH)
                data.state = STATE_FLIP
				data.stateTimer = 0
				SFX.play(2)
			    if p.x <= v.x then
				    v.direction = -1
			    else
				    v.direction = 1
			    end
                v.speedX = 3 * v.direction
				v.speedY = -3
            end
        end
    end
	if data.health <= 0 then
        data.state = STATE_DEAD
		data.stateTimer = 0
		eventObj.cancelled = true
	end
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
	Text.print(data.stateTimer, 8, 8)

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

	for i = #defeatEffects, 1, -1 do
		local effect = defeatEffects[i]

		if effect.emitter == nil then
			effect.emitter = Particles.Emitter(effect.x,effect.y,Misc.resolveFile("defeatParticle.ini"))
			effect.emitter.enabled = false

			effect.emitter:emit(25)

			local particles = effect.emitter.particles

			for index,particle in ipairs(particles) do
				local speed = vector(0,-9):rotate((index-1) / (#particles) * 360)

				particle.initSpeedX = speed.x
				particle.initSpeedY = speed.y
			end
		end

		effect.timer = effect.timer + 1

		effect.radius = effect.radius + (68 - effect.timer) * 0.2
		effect.opacity = math.clamp((68 - effect.timer) / 24)

		if effect.opacity > 0 then
			local color = Color.fromHSV((lunatime.drawtick()/224) % 1,0.8,0.9).. (effect.opacity * 0.5)

			Graphics.drawCircle{
				x = effect.x,y = effect.y,radius = effect.radius,priority = -4,sceneCoords = true,color = color,
			}
		end

		effect.emitter:Draw(-4,true,nil,true,nil,nil,true)


		if effect.opacity == 0 and effect.emitter:Count() == 0 then
			table.remove(defeatEffects,i)
		end
	end
end

return sampleNPC