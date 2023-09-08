local animationPal = require("animationPal")
local cutscenePal = require("cutscenePal")

local handycam = require("handycam")
local littleDialogue = require("littleDialogue")
local easing = require("ext/easing")

Player.setCostume(CHARACTER_MARIO,nil,true)
player:transform(CHARACTER_MARIO)
player.powerup = PLAYER_BIG
player.mount = MOUNT_NONE

local intro = cutscenePal.newScene("intro")

intro.canSkip = false

local function createDialogueBox(speakerObj,text)
	local box = littleDialogue.create{text = text,speakerObj = speakerObj,pauses = false}

	while (box.state ~= littleDialogue.BOX_STATE.REMOVE) do
		Routine.skip()
	end
end

local function spawnKamekActor(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = intro:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("kamek.png")
    actor.spriteOffset = vector(0,17)
    actor.spritePivotOffset = vector(0,-24)
    actor:setFrameSize(128,128) -- each frame is 56x54
    actor:setSize(48,32) -- hitbox size is 32x48

    actor.useAutoFloor = true
    actor.gravity = 0.26
    actor.terminalVelocity = 8

    -- Set up an actor's animations, using the same arguments as animationPal.createAnimator.
    actor:setUpAnimator{
        animationSet = {
            --Flying animations
            idle = {1, defaultFrameY = 1},

            stop = {1, defaultFrameY = 2},
            turn1 = {1,2, defaultFrameY = 2, frameDelay = 6, loops = false},
            turn2 = {2,1, defaultFrameY = 2, frameDelay = 6, loops = false},

            fly = {1,2, defaultFrameY = 3,frameDelay = 4},

            talk = {1,2,3,2, defaultFrameY = 4, frameDelay = 4},

            raisingWand = {1,2, defaultFrameY = 5,frameDelay = 5, loops = false},
            loweringWand = {2,1, defaultFrameY = 5,frameDelay = 5, loops = false},

            flySmall = {1,2, defaultFrameY = 6,frameDelay = 4},

            --Standing animations
            idleStanding = {1, defaultFrameY = 7},
            talkStanding = {1,2,3,2, defaultFrameY = 7, frameDelay = 4},

            idleStandingRight = {1, defaultFrameY = 8},
            talkStandingRight = {1,2,3,2, defaultFrameY = 8, frameDelay = 4},

            preparingSpell = {1,2,3,4,5, defaultFrameY = 9, frameDelay = 4, loops = false},
            castingSpell = {2,1, defaultFrameY = 9, frameDelay = 8, loops = false},
        },
        startAnimation = "idleStanding",
    }

    -- Add it to the scene's data table (which is of course optional) and return.
    intro.data.kamekActor = actor

    return actor
end

local function spawnMagicActor(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = intro:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("magic.png")
    actor:setFrameSize(32,32) -- each frame is 16x16
    actor:setSize(32,32) -- hitbox size is 16x16

    actor.priority = -15

    -- Set up an actor's animations, using the same arguments as animationPal.createAnimator.
    actor:setUpAnimator{
        animationSet = {
            idle = {1,2,3,4,5,6,7,8,9,10,11,12, frameDelay = 8},
        },
        startAnimation = "idle",
    }

    -- Return it
    return actor
end

local function spawnBowserActor(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = intro:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("bowser.png")
    actor.spriteOffset = vector(0,24)
    actor.spritePivotOffset = vector(0,64)
    actor:setFrameSize(192,192) -- each frame is 56x54
    actor:setSize(96,128) -- hitbox size is 32x48

    actor.useAutoFloor = true
    actor.gravity = 0.26
    actor.terminalVelocity = 8

    -- Set up an actor's animations, using the same arguments as animationPal.createAnimator.
    actor:setUpAnimator{
        animationSet = {
            --Flying animations
            idle = {1,2,3,2, defaultFrameY = 1, frameDelay = 11},

            talk = {1,2,3,2, defaultFrameY = 2, frameDelay = 6},

            roaring = {1,2,3,4, defaultFrameY = 3,frameDelay = 8,loopPoint = 3},

            surprised = {1,2, defaultFrameY = 4,frameDelay = 10},

            pushedAway = {1,2,3,2, defaultFrameY = 5, frameDelay = 5},
        },
        startAnimation = "idle",
    }

    -- Add it to the scene's data table (which is of course optional) and return.
    intro.data.bowserActor = actor

    return actor
end

function intro:mainRoutineFunc()
    player.direction = DIR_RIGHT
    player.speedX = 0

    local kamek = spawnKamekActor(-199776, -200128)
    local bowser = spawnBowserActor(-199488, -200128)

    kamek:setAnimation("idleStanding")
    bowser:setAnimation("idle")
    kamek.direction = DIR_LEFT
    bowser.direction = DIR_RIGHT

    Routine.wait(2)
    bowser:setAnimation("talk")

    Routine.wait(1.5)
    createDialogueBox(vector(bowser.x,bowser.y),"<boxStyle yi>.")

    Routine.wait(0.43)
    kamek:setAnimation("talkStanding")
    bowser:setAnimation("idle")

    Routine.wait(1.5)
    createDialogueBox(vector(kamek.x,kamek.y),"<boxStyle yi>.")

    Routine.wait(0.43)
    kamek:setAnimation("idleStanding")
    bowser:setAnimation("roaring")

    Routine.wait(0.3)
    Defines.earthquake = 6

    Routine.wait(1.5)
    createDialogueBox(vector(bowser.x,bowser.y),"<boxStyle yi>.")

    Routine.wait(0.43)
    kamek:setAnimation("talkStanding")
    bowser:setAnimation("idle")

    Routine.wait(1.5)
    createDialogueBox(vector(kamek.x,kamek.y),"<boxStyle yi>wanna see a magic trick?")

    Routine.wait(0.43)
    kamek:setAnimation("preparingSpell")

    Routine.wait(0.5)
    local magic = spawnMagicActor(kamek.x + kamek.width*0.5 - 24*kamek.direction,kamek.y + kamek.height - 14)
    magic.speedX = 4*-kamek.direction
    magic.speedY = -0.6

	while RNG.randomInt(1,30) == 1 do
        local e = Effect.spawn(80, v.x + RNG.randomInt(0,v.width), v.y + RNG.randomInt(0,v.height))

        e.x = e.x - e.width *0.5
        e.y = e.y - e.height*0.5
    end

    kamek:setAnimation("castingSpell")
    bowser:setAnimation("surprised")

    Routine.wait(0.9)
    kamek:setAnimation("idleStanding")
    bowser:setAnimation("pushedAway")

    magic:remove()

    bowser.useAutoFloor = false
    bowser.speedX = 2.4*bowser.direction
    bowser.speedY = -10

    Routine.wait(4)
end

function intro:stopFunc()
    -- This function is run whenever the cutscene stops, whether it ends naturally or it is skipped.
    handycam[1]:release() -- releases the camera from handycam's control. important if you're using handycam for the cutscene!
end


-- Trigger the cutscene using an event
function onEvent(eventName)
    if eventName == "intro start" then
        intro:start()
    end
end