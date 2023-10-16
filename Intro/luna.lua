local animationPal = require("animationPal")
local cutscenePal = require("cutscenePal")

local handycam = require("handycam")
local littleDialogue = require("littleDialogue")
local distortionEffects = require("distortionEffects")
local warpTransition = require("warpTransition")
local easing = require("ext/easing")

warpTransition.sameSectionTransition = warpTransition.TRANSITION_PAN
warpTransition.crossSectionTransition = warpTransition.TRANSITION_FADE
warpTransition.levelStartTransition = warpTransition.TRANSITION_FADE

Player.setCostume(CHARACTER_MARIO,nil,true)
player:transform(CHARACTER_MARIO)
player.powerup = PLAYER_BIG
player.mount = MOUNT_NONE

local intro = cutscenePal.newScene("intro")

intro.canSkip = false

Graphics.activateHud(false)

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
            walking = {4,1, defaultFrameY = 7, frameDelay = 8},

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

local function spawnToadie1Actor(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = intro:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("toadies.png")
    actor:setFrameSize(64,64) -- each frame is 56x54
    actor:setSize(32,32) -- hitbox size is 32x48

    -- Set up an actor's animations, using the same arguments as animationPal.createAnimator.
    actor:setUpAnimator{
        animationSet = {
            --Flying animations
            fly = {1,2,3,4,3,2, defaultFrameY = 1, frameDelay = 5},

            talk = {1,2,3,4,3,2, defaultFrameY = 2, frameDelay = 5},

            surprised = {1,2,3,4,3,2, defaultFrameY = 3, frameDelay = 5},

            tiny = {1,2, defaultFrameY = 4, frameDelay = 3},
        },
        startAnimation = "fly",
    }

    -- Add it to the scene's data table (which is of course optional) and return.
    intro.data.toadie1Actor = actor

    return actor
end

local function spawnToadie2Actor(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = intro:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("toadies.png")
    actor:setFrameSize(64,64) -- each frame is 56x54
    actor:setSize(32,32) -- hitbox size is 32x48

    -- Set up an actor's animations, using the same arguments as animationPal.createAnimator.
    actor:setUpAnimator{
        animationSet = {
            --Flying animations
            fly = {1,2,3,4,3,2, defaultFrameY = 1, frameDelay = 5},

            talk = {1,2,3,4,3,2, defaultFrameY = 2, frameDelay = 5},

            surprised = {1,2,3,4,3,2, defaultFrameY = 3, frameDelay = 5},
        },
        startAnimation = "fly",
    }

    -- Add it to the scene's data table (which is of course optional) and return.
    intro.data.toadie2Actor = actor

    return actor
end

local function spawnToadie3Actor(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = intro:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("toadies.png")
    actor:setFrameSize(64,64) -- each frame is 56x54
    actor:setSize(32,32) -- hitbox size is 32x48

    -- Set up an actor's animations, using the same arguments as animationPal.createAnimator.
    actor:setUpAnimator{
        animationSet = {
            --Flying animations
            fly = {1,2,3,4,3,2, defaultFrameY = 1, frameDelay = 5},

            talk = {1,2,3,4,3,2, defaultFrameY = 2, frameDelay = 5},

            surprised = {1,2,3,4,3,2, defaultFrameY = 3, frameDelay = 5},
        },
        startAnimation = "fly",
    }

    -- Add it to the scene's data table (which is of course optional) and return.
    intro.data.toadie3Actor = actor

    return actor
end

local function spawnToadie4Actor(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = intro:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("toadies.png")
    actor:setFrameSize(64,64) -- each frame is 56x54
    actor:setSize(32,32) -- hitbox size is 32x48

    -- Set up an actor's animations, using the same arguments as animationPal.createAnimator.
    actor:setUpAnimator{
        animationSet = {
            --Flying animations
            fly = {1,2,3,4,3,2, defaultFrameY = 1, frameDelay = 5},

            talk = {1,2,3,4,3,2, defaultFrameY = 2, frameDelay = 5},

            surprised = {1,2,3,4,3,2, defaultFrameY = 3, frameDelay = 5},
        },
        startAnimation = "fly",
    }

    -- Add it to the scene's data table (which is of course optional) and return.
    intro.data.toadie4Actor = actor

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

local function spawnPeachCastle(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = intro:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("peach_castle.png")
    actor.spriteOffset = vector(4,30)
    actor:setFrameSize(256,256) -- each frame is 56x54
    actor:setSize(64,64) -- hitbox size is 32x48

    actor.priority = -10

    -- Set up an actor's animations, using the same arguments as animationPal.createAnimator.
    actor:setUpAnimator{
        animationSet = {
            normal = {1, defaultFrameY = 1},

            attacked = {2,3,4,5,4,3, defaultFrameY = 1, frameDelay = 5},
        },
        startAnimation = "normal",
    }

    -- Add it to the scene's data table (which is of course optional) and return.
    intro.data.castleActor = actor

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
    SFX.play("Bowser 1.wav")

    Routine.wait(1.5)
    createDialogueBox(vector(bowser.x,bowser.y),"<boxStyle yi>.")

    Routine.wait(0.43)
    kamek:setAnimation("talkStanding")
    bowser:setAnimation("idle")

    for i = 1,2 do
		SFX.play("thatSound.ogg")

		Routine.wait(0.5)
	end

    Routine.wait(0.1)
    createDialogueBox(vector(kamek.x,kamek.y),"<boxStyle yi>.")

    Routine.wait(0.43)
    kamek:setAnimation("idleStanding")
    bowser:setAnimation("roaring")

    Routine.wait(0.3)
    Defines.earthquake = 8
    distortionEffects.create{x = bowser.x+(bowser.width/2),y = bowser.y+(bowser.height/2)}

    SFX.play("Bowser 2.wav")

    Routine.wait(2.3)
    createDialogueBox(vector(bowser.x,bowser.y),"<boxStyle yi>.")

    Routine.wait(0.43)
    kamek:setAnimation("talkStanding")
    bowser:setAnimation("idle")

    for i = 1,2 do
		SFX.play("thatSound.ogg")

		Routine.wait(0.5)
	end

    Routine.wait(0.1)
    createDialogueBox(vector(kamek.x,kamek.y),"<boxStyle yi>wanna see a magic trick?")

    Routine.wait(0.43)
    kamek:setAnimation("preparingSpell")

    Routine.wait(0.5)
    local magic = spawnMagicActor(kamek.x + kamek.width*0.5 - 24*kamek.direction,kamek.y + kamek.height - 14)
    magic.speedX = 4*-kamek.direction
    magic.speedY = -0.6

    SFX.play(41)
    SFX.play("Bowser 3.wav")

    Audio.MusicFadeOut(player.section, 2000)

    self:runChildRoutine(function()
        while magic.isValid do
            if RNG.randomInt(1,4) == 1 then
                local e = Effect.spawn(80, magic.x + RNG.randomInt(0,magic.width), magic.y + RNG.randomInt(0,magic.height))
        
                e.x = e.x - e.width *0.5
                e.y = e.y - e.height*0.5
            end

            Routine.skip()
        end
    end)

    kamek:setAnimation("castingSpell")
    bowser:setAnimation("surprised")

    Routine.wait(0.9)
    kamek:setAnimation("idleStanding")
    bowser:setAnimation("pushedAway")

    Defines.earthquake = 5
    distortionEffects.create{x = magic.x+(magic.width/2),y = magic.y+(magic.height/2)}

    magic:remove()

    SFX.play("Explosion.wav")
    SFX.play("Bowser 4.wav")

    bowser.useAutoFloor = false
    bowser.speedX = 2.4*bowser.direction
    bowser.speedY = -10

    Routine.wait(2.9)
    kamek:setAnimation("walking")

    bowser:remove()

    kamek:walkAndWait{
        goal = -199552,speed = 1,setDirection = false,
        walkAnimation = "walking",stopAnimation = "idleStanding",
    }

    Routine.wait(0.28)
    Audio.MusicChange(0, "music/Super Princess Peach OST_ Welcome to Bowser's Villa!.ogg")

    kamek:setAnimation("idleStandingRight")
    kamek.direction = -kamek.direction

    Routine.wait(1.5)
    kamek:setAnimation("talkStandingRight")

    for i = 1,2 do
		SFX.play("thatSound.ogg")

		Routine.wait(0.5)
	end

    Routine.wait(0.1)
    createDialogueBox(vector(kamek.x,kamek.y),"<boxStyle yi>YO I'M FREEEEEEEEEEE")

    Routine.wait(0.43)
    kamek:setAnimation("idleStandingRight")

    local toadie1 = spawnToadie1Actor(-200048, -200128)
    toadie1.direction = DIR_LEFT

    local toadie2 = spawnToadie2Actor(-200096, -200128)
    toadie2.direction = DIR_LEFT

    local toadie3 = spawnToadie3Actor(-200144, -200128)
    toadie3.direction = DIR_LEFT

    local toadie4 = spawnToadie4Actor(-200192, -200128)
    toadie4.direction = DIR_LEFT

    toadie1:walkAndWait{
        goal = -199744,speed = 5.5,setDirection = false,
        walkAnimation = "fly",stopAnimation = "fly",
    }

    toadie2:walkAndWait{
        goal = -199792,speed = 5.5,setDirection = false,
        walkAnimation = "fly",stopAnimation = "fly",
    }

    toadie3:walkAndWait{
        goal = -199840,speed = 5.5,setDirection = false,
        walkAnimation = "fly",stopAnimation = "fly",
    }

    toadie4:walkAndWait{
        goal = -199888,speed = 5.5,setDirection = false,
        walkAnimation = "fly",stopAnimation = "fly",
    }

    Routine.wait(1.5)
    toadie1:setAnimation("talk")

    SFX.play("Toadie talks.wav")

    Routine.wait(0.9)
    createDialogueBox(vector(toadie1.x,toadie1.y),"<boxStyle yi>hey what happened")

    Routine.wait(0.43)
    toadie1:setAnimation("fly")
    toadie3:setAnimation("talk")

    SFX.play("Toadie talks.wav")

    Routine.wait(0.9)
    createDialogueBox(vector(toadie3.x,toadie3.y),"<boxStyle yi>we heard loud noises")

    Routine.wait(0.43)
    toadie3:setAnimation("fly")
    kamek:setAnimation("talkStandingRight")

    for i = 1,2 do
		SFX.play("thatSound.ogg")

		Routine.wait(0.5)
	end

    Routine.wait(0.1)
    createDialogueBox(vector(kamek.x,kamek.y),"<boxStyle yi>nah it's nothin, now CALL ME YOUR MASTER DAMNIT")

    Routine.wait(0.43)
    kamek:setAnimation("idleStandingRight")

    SFX.play(49)

    toadie1:setAnimation("surprised")
    toadie2:setAnimation("surprised")
    toadie3:setAnimation("surprised")
    toadie4:setAnimation("surprised")

    toadie1.speedX = -1.1
    toadie2.speedX = -1.1
    toadie3.speedX = -1.1
    toadie4.speedX = -1.1

    Routine.wait(0.25)
    toadie1.speedX = -0
    toadie2.speedX = -0
    toadie3.speedX = -0
    toadie4.speedX = -0

    Routine.wait(1)
    toadie1:setAnimation("talk")
    toadie2:setAnimation("talk")
    toadie3:setAnimation("talk")
    toadie4:setAnimation("talk")

    SFX.play("Toadie talks.wav")

    Routine.wait(0.9)
    createDialogueBox(vector(toadie2.x,toadie2.y),"<boxStyle yi>yeah master what to do now")

    Routine.wait(0.43)
    toadie1:setAnimation("fly")
    toadie2:setAnimation("fly")
    toadie3:setAnimation("fly")
    toadie4:setAnimation("fly")

    kamek:setAnimation("idle")
    Effect.spawn(772, kamek.x - 40, kamek.y - 40, player.section)

    kamek.y = kamek.y - 16

    kamek.useAutoFloor = false
    kamek.gravity = 0

    local childRoutineObj = self:runChildRoutine(function()
        while kamek.isValid do
            kamek.speedY = math.cos(lunatime.tick() / 32) * 0.4

            Routine.skip()
        end
    end)

    Routine.wait(2)
    kamek:setAnimation("talk")

    for i = 1,2 do
		SFX.play("thatSound.ogg")

		Routine.wait(0.5)
	end

    Routine.wait(0.1)
    createDialogueBox(vector(kamek.x,kamek.y),"<boxStyle yi>follow me")

    Routine.wait(0.43)
    kamek:setAnimation("stop")
    kamek.speedX = 1.1

    Routine.wait(0.25)
    kamek:setAnimation("fly")
    kamek.speedX = -8
    kamek.speedY = 0

    SFX.play("flyIn.ogg")

    toadie1:setAnimation("surprised")
    toadie2:setAnimation("surprised")
    toadie3:setAnimation("surprised")
    toadie4:setAnimation("surprised")

    toadie1.speedY = -4.1
    toadie2.speedY = -4.1
    toadie3.speedY = -4.1
    toadie4.speedY = -4.1

    Routine.wait(0.25)
    toadie1.speedY = 0
    toadie2.speedY = 0
    toadie3.speedY = 0
    toadie4.speedY = 0

    Routine.wait(1.7)
    toadie1:setAnimation("fly")
    toadie2:setAnimation("fly")
    toadie3:setAnimation("fly")
    toadie4:setAnimation("fly")

    toadie1.direction = -toadie1.direction
    toadie2.direction = -toadie2.direction
    toadie3.direction = -toadie3.direction
    toadie4.direction = -toadie4.direction

    Routine.wait(0.25)
    kamek:remove()

    toadie1.speedX = -5
    toadie2.speedX = -5
    toadie3.speedX = -5
    toadie4.speedX = -5

    Routine.wait(2)
    toadie1:remove()
    toadie2:remove()
    toadie3:remove()
    toadie4:remove()

    Routine.wait(0.25)
    local warp = Layer.get("warp")
    warp:show(true)

    local castle = spawnPeachCastle(-179616, -180256)
    castle:setAnimation("normal")

    Routine.wait(1)
    local kamek = spawnKamekActor(-179200, -180448)

    kamek:setAnimation("flySmall")
    kamek.direction = DIR_RIGHT

    kamek.gravity = 0

    kamek.speedX = -3.8
    kamek.speedY = 1.8

    Audio.MusicFadeOut(player.section, 4000)

    Routine.wait(0.7)
    local toadies = spawnToadie1Actor(-179200, -180448)

    toadies:setAnimation("tiny")
    toadies.direction = DIR_RIGHT

    toadies.speedX = -3.8
    toadies.speedY = 1.8

    Routine.wait(1)
    kamek:remove()

    Routine.wait(0.7)
    toadies:remove()

    Routine.wait(1.3)
    castle:setAnimation("attacked")
    SFX.play("MLTP Sounds/Mario 1.ogg")
    Defines.earthquake = 12

    Audio.MusicChange(1, "Intro/Super Princess Peach OST_ Bowser Captures the Bros.ogg")

    Routine.wait(1.8)
    SFX.play("MLTP Sounds/Luigi 1.ogg")
    Defines.earthquake = 12

    Routine.wait(1.8)
    SFX.play("MLTP Sounds/Toad 1.wav")
    Defines.earthquake = 12

    Routine.wait(1.8)
    SFX.play("MLTP Sounds/Peach 1.wav")
    Defines.earthquake = 12

    Routine.wait(1.8)
    SFX.play(4)
    Defines.earthquake = 7

    Routine.wait(0.9)
    SFX.play(39)
    Defines.earthquake = 7

    Routine.wait(0.9)
    SFX.play("Explosion.wav")
    Defines.earthquake = 6

    Routine.wait(0.7)
    SFX.play("Explosion.wav")
    Defines.earthquake = 6

    Routine.wait(0.8)
    SFX.play("MLTP Sounds/Mario 2.ogg")
    SFX.play("MLTP Sounds/Luigi 2.ogg")
    SFX.play("MLTP Sounds/Toad 2.wav")
    SFX.play("MLTP Sounds/Peach 2.wav")
    castle:setAnimation("normal")
    Defines.earthquake = 10

    Routine.wait(3)
    SFX.play("Oh no.ogg")
    local warp2 = Layer.get("warp2")
    warp2:show(true)

    Routine.wait(0.8)
    SFX.play("MLTP Sounds/Mario 2.ogg")
    SFX.play("MLTP Sounds/Luigi 2.ogg")
    SFX.play("MLTP Sounds/Toad 2.wav")
    SFX.play("MLTP Sounds/Peach 2.wav")

    Routine.wait(1)
end

-- Trigger the cutscene using an event
function onEvent(eventName)
    if eventName == "intro start" then
        intro:start()
    end
end