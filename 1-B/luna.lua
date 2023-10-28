local animationPal = require("animationPal")
local cutscenePal = require("cutscenePal")

local littleDialogue = require("littleDialogue")

local boss = cutscenePal.newScene("boss")

boss.canSkip = false

local function createDialogueBox(speakerObj,text)
	local box = littleDialogue.create{text = text,speakerObj = speakerObj,pauses = false}

	while (box.state ~= littleDialogue.BOX_STATE.REMOVE) do
		Routine.skip()
	end
end

local magicEffectImage = Graphics.loadImage("magic.png")
local magicEffects = {}

function onTick()
    for i = #magicEffects, 1, -1 do
		local effect = magicEffects[i]

		effect.timer = effect.timer + 1

		if effect.timer > 256 then
			table.remove(magicEffects,i)
		end
	end
end

local magicEffectShader = Shader()
magicEffectShader:compileFromFile(nil, "magic.frag")

function onDraw()
    for _,effect in ipairs(magicEffects) do
		local image = magicEffectImage

		Graphics.drawBox{
			texture = image,sceneCoords = true,priority = -4,
			color = Color.fromHSV((lunatime.tick()/224) % 1,0.8,0.9),
			x = effect.x - image.width*0.5,y = effect.y - 96,
			height = image.height*2,sourceHeight = image.height,sourceY = 0,
			shader = magicEffectShader,uniforms = {
				imageSize = vector(image.width,image.height),
				time = effect.timer,
			},
		}
	end
end

local function spawnKamekActor(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = boss:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("kamek.png")
    actor.spriteOffset = vector(0,17)
    actor.spritePivotOffset = vector(0,-24)
    actor:setFrameSize(128,128) -- each frame is 56x54
    actor:setSize(48,32) -- hitbox size is 32x48

    actor.useAutoFloor = false
    actor.gravity = 0
    actor.terminalVelocity = 8

    -- Set up an actor's animations, using the same arguments as animationPal.createAnimator.
    actor:setUpAnimator{
        animationSet = {
            --Flying animations
            idle = {1, defaultFrameY = 1},

            stop = {1, defaultFrameY = 2},
            turn1 = {1,2, defaultFrameY = 2, frameDelay = 4, loops = false},
            turn2 = {2,1, defaultFrameY = 2, frameDelay = 4, loops = false},

            fly = {1,2, defaultFrameY = 3,frameDelay = 2.6},

            talk = {1,2,3,2, defaultFrameY = 4, frameDelay = 4},

            raisingWand = {1,2, defaultFrameY = 5,frameDelay = 5, loops = false},
            loweringWand = {2,1, defaultFrameY = 5,frameDelay = 5, loops = false},

            flySmall = {1,2, defaultFrameY = 6,frameDelay = 4},

            --Standing animations
            idleStanding = {1, defaultFrameY = 7},
            talkStanding = {1,2,3,2, defaultFrameY = 7, frameDelay = 4},
            walking = {4,1, defaultFrameY = 7, frameDelay = 8},

            idleStandingRight = {1, defaultFrameY = 8},
            talkStandingRight = {1,2,3,2, defaultFrameY = 8, frameDelay = 4},

            preparingSpell = {1,2,3,4,5, defaultFrameY = 9, frameDelay = 4, loops = false},
            castingSpell = {2,1, defaultFrameY = 9, frameDelay = 8, loops = false},
        },
        startAnimation = "idleStanding",
    }

    -- Add it to the scene's data table (which is of course optional) and return.
    boss.data.kamekActor = actor

    return actor
end

local function spawnMildeActor(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = boss:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("milde.png")
    actor.spriteOffset = vector(0,5)
    actor.spritePivotOffset = vector(0,-24)
    actor:setFrameSize(42,42) -- each frame is 56x54
    actor:setSize(32,32) -- hitbox size is 32x48

    actor.useAutoFloor = true
    actor.gravity = 0.22
    actor.terminalVelocity = 8

    -- Set up an actor's animations, using the same arguments as animationPal.createAnimator.
    actor:setUpAnimator{
        animationSet = {
            walking = {1,2,3,4,5,4,3,2, defaultFrameY = 1, frameDelay = 7},

            idle = {1, defaultFrameY = 2},
            shaking = {2,3, defaultFrameY = 2, frameDelay = 1.8},
        },
        startAnimation = "walking",
    }

    -- Add it to the scene's data table (which is of course optional) and return.
    boss.data.mildeActor = actor

    return actor
end

function boss:mainRoutineFunc()
    local milde = spawnMildeActor(-199168, -200096)
    milde:walkAndWait{
        goal = -199330,speed = 1,setDirection = false,
        walkAnimation = "walking",stopAnimation = "idle",
    }

    Routine.wait(0.64)
    local kamek = spawnKamekActor(-199158,-200328)
    kamek.direction = DIR_RIGHT
    kamek.speedX = -9.4
    kamek:setAnimation("stop")

    Audio.MusicFadeOut(player.section, 2000)

    local kamekStop = self:runChildRoutine(function()
        while kamek.isValid do
            kamek.speedX = kamek.speedX + 0.25
            if kamek.speedX > 0 then
                kamek.speedX = 0
                kamek:setAnimation("idle")
                kamek.speedY = math.cos(lunatime.tick() / 32) * 0.4
            end

            Routine.skip()
        end
    end)

    Routine.wait(1)
    kamek:setAnimation("talk")
    kamekStop:abort()

    for i = 1,2 do
		SFX.play("thatSound.ogg")

		Routine.wait(0.5)
	end

    local kamekIdle = self:runChildRoutine(function()
        while kamek.isValid do
            kamek.speedY = math.cos(lunatime.tick() / 32) * 0.4

            Routine.skip()
        end
    end)

    Routine.wait(0.1)
    Audio.MusicChange(0, "music/Kamek's Theme.ogg")
    Routine.wait(0.1)
    createDialogueBox(vector(kamek.x,kamek.y),"<setPos 400 190 0.5 0><portrait kamek 1>Well well well... Our friend Yoshi here is still trying to be an amazing hero<page><portrait kamek 4>Little does he know his brittle bones will be CRUSHED and TARNISHED by the one and only GIGA MILDE!!!")
    Routine.wait(0.1)
    kamek:setAnimation("raisingWand")
    Routine.wait(0.54)

    table.insert(magicEffects,{
        x = kamek.x + kamek.width*0.5,
        y = kamek.y + kamek.height,
        timer = 0,
    })

    SFX.play(41)
    kamek:setAnimation("loweringWand")
    kamek:waitUntilAnimationFinished()

    Routine.wait(0.1)
    kamek:setAnimation("idle")
    Audio.MusicFadeOut(player.section, 2500)

    Routine.wait(1.6)
    milde:setAnimation("shaking")

    kamek:setAnimation("stop")
    kamek.speedX = 1.1
    kamekIdle:abort()

    Routine.wait(0.25)
    kamek:setAnimation("fly")
    kamek.speedX = -8

    local childRoutineObj = self:runChildRoutine(function()
        while kamek.isValid do
            kamek.speedY = kamek.speedY - 0.25

            Routine.skip()
        end
    end)
    Routine.wait(2.5)
    milde:remove()
    local boss = Layer.get("milde")
    boss:show(true)

    Routine.wait(3.8)
end

function onEvent(eventName)
    if eventName == "intro start" then
        boss:start()
    end
end