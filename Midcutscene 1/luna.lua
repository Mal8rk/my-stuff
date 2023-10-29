local animationPal = require("animationPal")
local cutscenePal = require("cutscenePal")

local pauseplus = require("pauseplus")

pauseplus.canPause = false

local yoshi
pcall(function() yoshi = require("yiYoshi/yiYoshi") end)

yoshi.introSettings.enabled = false

local littleDialogue = require("littleDialogue")
local warpTransition = require("warpTransition")

local mid = cutscenePal.newScene("mid")

mid.canSkip = false

warpTransition.sameSectionTransition = warpTransition.TRANSITION_PAN
warpTransition.crossSectionTransition = warpTransition.TRANSITION_FADE
warpTransition.levelStartTransition = warpTransition.TRANSITION_FADE

Graphics.activateHud(false)

local finalFadeOut = 0

local function createDialogueBox(speakerObj,text)
	local box = littleDialogue.create{text = text,speakerObj = speakerObj,pauses = false}

	while (box.state ~= littleDialogue.BOX_STATE.REMOVE) do
		Routine.skip()
	end
end

local function spawnKamekActor(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = mid:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("kamek.png")
    actor.spriteOffset = vector(0,17)
    actor.spritePivotOffset = vector(0,-24)
    actor:setFrameSize(128,128) -- each frame is 56x54
    actor:setSize(48,32) -- hitbox size is 32x48

    actor.useAutoFloor = true
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
    mid.data.kamekActor = actor

    return actor
end

local function spawnYoshiActor(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = mid:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("yoshi.png")
    actor.spriteOffset = vector(0,16)
    actor.spritePivotOffset = vector(0,-24)
    actor:setFrameSize(128,128) -- each frame is 56x54
    actor:setSize(48,32) -- hitbox size is 32x48

    actor.useAutoFloor = true
    actor.gravity = 0.26
    actor.terminalVelocity = 8

    actor.priority = -85

    -- Set up an actor's animations, using the same arguments as animationPal.createAnimator.
    actor:setUpAnimator{
        animationSet = {
            --Flying animations
            idle = {1,2,3,4,5,6,7, defaultFrameY = 1, frameDelay = 6},
            idle2 = {1, defaultFrameY = 1},

            turn1 = {1,2,3,4, defaultFrameY = 2, frameDelay = 2, loops = false},
            turn2 = {4,3,2,1, defaultFrameY = 2, frameDelay = 2, loops = false},

            walk = {1,2,3,4,5,6,7,8,9,10, defaultFrameY = 3,frameDelay = 5},

            run = {1,2, defaultFrameY = 4, frameDelay = 4},

            hurt = {1, defaultFrameY = 5},
            spinning = {2,3,4,5,6,7, defaultFrameY = 5,frameDelay = 3},

            lookUp = {1, defaultFrameY = 6},
            jump = {2, defaultFrameY = 6},
            cling = {3,4,5,6,5,4, defaultFrameY = 6, frameDelay = 2},
        },
        startAnimation = "idle",
    }

    -- Add it to the scene's data table (which is of course optional) and return.
    mid.data.yoshiActor = actor

    return actor
end

function mid:mainRoutineFunc()
    local yoshi = spawnYoshiActor(-200096, -200128)
    yoshi.direction = DIR_LEFT

    yoshi:walkAndWait{
        goal = -199776,speed = 1,setDirection = false,
        walkAnimation = "walk",stopAnimation = "idle",
    }

    Routine.wait(1)
    yoshi:setAnimation("turn1")
    Routine.wait(0.8)
    yoshi:setAnimation("turn2")
    yoshi:waitUntilAnimationFinished()

    Routine.wait(0.1)
    yoshi:setAnimation("idle")

    Routine.wait(1.3)
    SFX.play(1)

    yoshi:jumpAndWait{
        goalX = -199648,goalY = -200064,setDirection = false,resetSpeed = true,setPosition = true,
        riseAnimation = "jump",landAnimation = "idle2",
    }
    Routine.wait(0.1)
    SFX.play("S1_AA.wav")
    Effect.spawn(848,yoshi.x-40,yoshi.y-120)
    Routine.wait(1.3)
    yoshi:setAnimation("idle2")
    yoshi.gravity = 0

    Routine.wait(0.1)
    yoshi.speedY = -4.7
    Routine.wait(0.1)
    self:runChildRoutine(function()
        while yoshi.isValid do
            yoshi.speedY = math.cos(lunatime.tick() / 15) * 0.5

            Routine.skip()
        end
    end)
    Routine.wait(1)
    yoshi:setAnimation("idle")
    yoshi.speedX = 2

    Routine.wait(5)
    local warp = Layer.get("warp")
    warp:show(true)

    Routine.wait(2)
    local yoshi = spawnYoshiActor(-180064, -180076)
    yoshi.direction = DIR_LEFT

    yoshi:setAnimation("idle")
    yoshi.gravity = 0
    yoshi.speedX = 2

    local yoshiSwim = self:runChildRoutine(function()
        while yoshi.isValid do
            yoshi.speedY = math.cos(lunatime.tick() / 15) * 0.5

            Routine.skip()
        end
    end)

    Routine.wait(2.7)

    yoshiSwim:abort()
    yoshi.gravity = 0.26

    Effect.spawn(848,yoshi.x-40,yoshi.y-120)
    SFX.play("S1_AA.wav")

    yoshi:jumpAndWait{
        goalX = -179584, goalY = -180128,setDirection = false,resetSpeed = true,setPosition = true,
        riseAnimation = "jump",landAnimation = "idle",
    }

    Routine.wait(1)
    local kamek = spawnKamekActor(-179136, -180416)
    kamek.direction = DIR_RIGHT
    kamek.speedX = -9.4
    kamek:setAnimation("stop")

    yoshi:setAnimation("lookUp")

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
    Audio.MusicFadeOut(player.section, 1000)

    self:runChildRoutine(function()
        while kamek.isValid do
            kamek.speedY = math.cos(lunatime.tick() / 32) * 0.4

            Routine.skip()
        end
    end)
    
    kamek:setAnimation("talk")
    kamekStop:abort()

    for i = 1,2 do
		SFX.play("thatSound.ogg")

		Routine.wait(0.5)
	end

    Routine.wait(0.1)
    Audio.MusicChange(1, "music/Kamek's Theme.ogg")
    Routine.wait(0.1)
    createDialogueBox(vector(kamek.x,kamek.y),"<setPos 400 190 0.5 0><portrait kamek 1>Oh Yoshi... Why do you have to cause so much unnecessary destruction to all the critters with your eggs?<page><portrait kamek 4>And you want to be a hero? Oh please...<page><portrait kamek 2>Nothing you do will matter when you get blown up by a MILLION BOB-OMBS!!!")
    Routine.wait(0.1)
    kamek:setAnimation("turn1")
    kamek:waitUntilAnimationFinished()

    Routine.wait(0.1)
    kamek.direction = DIR_LEFT
    kamek:setAnimation("turn2")
    kamek:waitUntilAnimationFinished()

    Routine.wait(0.1)
    Audio.MusicFadeOut(player.section, 1000)
    kamek:setAnimation("fly")
    kamek.speedX = 10

    Routine.wait(1)
    yoshi:setAnimation("run")
    yoshi.speedX = 7

    Routine.wait(2)
    self:runChildRoutine(function()
        while (finalFadeOut < 1) do
            finalFadeOut = math.min(1,finalFadeOut + 0.032)
            Routine.skip(true)
        end
    end)
    Routine.wait(0.64)
    Level.load("map.lvlx")
end

function onDraw()
    if finalFadeOut > 0 then
		Graphics.drawScreen{priority = 10,color = Color.black.. finalFadeOut}
	end
end

function onEvent(eventName)
    if eventName == "mid start" then
        mid:start()
    end
end