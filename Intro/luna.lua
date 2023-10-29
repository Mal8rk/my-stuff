local animationPal = require("animationPal")
local cutscenePal = require("cutscenePal")

local littleDialogue = require("littleDialogue")
local distortionEffects = require("distortionEffects")
local warpTransition = require("warpTransition")

local pauseplus = require("pauseplus")

pauseplus.canPause = false

local yoshi
pcall(function() yoshi = require("yiYoshi/yiYoshi") end)

yoshi.introSettings.enabled = false

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

local function spawnGoombaActor(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = intro:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("goomba.png")
    actor.spriteOffset = vector(0,0)
    actor.spritePivotOffset = vector(0,-24)
    actor:setFrameSize(42,42) -- each frame is 56x54
    actor:setSize(32,48) -- hitbox size is 32x48

    actor.useAutoFloor = true
    actor.gravity = 0.22
    actor.terminalVelocity = 8

    -- Set up an actor's animations, using the same arguments as animationPal.createAnimator.
    actor:setUpAnimator{
        animationSet = {
            idle = {1, defaultFrameY = 1},
            jump = {2, defaultFrameY = 1},

            run = {1,2,3,4, defaultFrameY = 2, frameDelay = 1.4},
        },
        startAnimation = "idle",
    }

    -- Add it to the scene's data table (which is of course optional) and return.
    intro.data.goombaActor = actor

    return actor
end

local function spawnYoshiActor(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = intro:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("yoshi.png")
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
            idle = {1,2,3,4,5,6,7, defaultFrameY = 1, frameDelay = 6},

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
    intro.data.yoshiActor = actor

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

local function spawnJailActor(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = intro:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("hero_jail.png")
    actor:setFrameSize(256,256) -- each frame is 56x54
    actor:setSize(128,128) -- hitbox size is 32x48

    -- Set up an actor's animations, using the same arguments as animationPal.createAnimator.
    actor:setUpAnimator{
        animationSet = {
            --Flying animations
            fly = {1,2,3,4,3,2, defaultFrameY = 1, frameDelay = 4},

            intrigued = {1,2,3,4,3,2, defaultFrameY = 2, frameDelay = 4},

            flyWith3 = {1,2,3,4,3,2, defaultFrameY = 3, frameDelay = 4},

            intriguedWith3 = {1,2,3,4,3,2, defaultFrameY = 4, frameDelay = 4},
        },
        startAnimation = "fly",
    }

    -- Add it to the scene's data table (which is of course optional) and return.
    intro.data.jailActor = actor

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

    self:runChildRoutine(function()
        while bowser.isValid do
            if RNG.randomInt(1,10) == 1 then
                local e = Effect.spawn(772, bowser.x + RNG.randomInt(0,bowser.width), bowser.y + RNG.randomInt(0,bowser.height))
        
                e.x = e.x - e.width *0.5
                e.y = e.y - e.height*0.5

                SFX.play(41)
            end

            Routine.skip()
        end
    end)

    SFX.play("Explosion.wav")
    SFX.play("Bowser 4.wav")

    Routine.wait(3.8)
    Effect.spawn(773, bowser.x - 80, bowser.y - 34, player.section)
    local goomba = spawnGoombaActor(bowser.x + 32, bowser.y + 128)
    goomba.direction = DIR_RIGHT

    bowser:remove()

    Routine.wait(1)
    goomba.direction = DIR_LEFT
    Routine.wait(0.54)
    goomba.direction = DIR_RIGHT
    Routine.wait(1)
    goomba.direction = DIR_LEFT

    SFX.play(1)

    goomba:jumpAndWait{
        goalX = -199360,goalY = -200192,setDirection = false,resetSpeed = true,setPosition = true,
        riseAnimation = "jump",landAnimation = "run",
    }

    goomba.speedX = 7

    Routine.wait(1.4)

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
    Effect.spawn(772, kamek.x - 34, kamek.y - 40, player.section)

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

    toadie1.speedY = -5.1
    toadie2.speedY = -5.1
    toadie3.speedY = -5.1
    toadie4.speedY = -5.1

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

    Routine.wait(0.5)
    SFX.play("MLTP Sounds/Mario 2.ogg")
    SFX.play("MLTP Sounds/Luigi 2.ogg")
    SFX.play("MLTP Sounds/Toad 2.wav")
    SFX.play("MLTP Sounds/Peach 2.wav")

    Routine.wait(2)
    local warp3 = Layer.get("warp3")
    warp3:show(true)

    Routine.wait(0.9)

    local yoshi = spawnYoshiActor(-160064, -160128)
    yoshi.direction = DIR_LEFT

    yoshi:walkAndWait{
        goal = -159808,speed = 1,setDirection = false,
        walkAnimation = "walk",stopAnimation = "idle",
    }

    Routine.wait(1)
    yoshi:setAnimation("turn1")
    Routine.wait(0.8)
    yoshi:setAnimation("turn2")
    yoshi:waitUntilAnimationFinished()

    Routine.wait(0.1)
    yoshi:setAnimation("idle")
    Audio.MusicFadeOut(player.section, 2000)

    Routine.wait(2)
    local kamek = spawnKamekActor(-160064, -160448)
    kamek.direction = DIR_LEFT
    kamek.gravity = 0
    kamek:setAnimation("fly")
    kamek.speedX = 10

    SFX.play("flyIn.ogg")

    yoshi:setAnimation("lookUp")
    Audio.MusicChange(2, "Intro/Super Princess Peach OST_ Pre-Boss.ogg")

    Routine.wait(3)
    yoshi:setAnimation("turn1")
    SFX.play("MLTP Sounds/Mario 2.ogg")
    SFX.play("MLTP Sounds/Luigi 2.ogg")
    SFX.play("MLTP Sounds/Toad 2.wav")
    SFX.play("MLTP Sounds/Peach 2.wav")

    Routine.wait(2)
    yoshi:setAnimation("lookUp")
    SFX.play("MLTP Sounds/Mario 3.ogg")
    SFX.play("MLTP Sounds/Luigi 4.ogg")
    SFX.play("MLTP Sounds/Toad 3.wav")
    SFX.play("MLTP Sounds/Peach 3.wav")

    local jail = spawnJailActor(-160064, -160288)
    jail.direction = DIR_RIGHT
    jail:setAnimation("flyWith3")
    jail.speedX = 9

    Routine.wait(2.4)
    yoshi:setAnimation("hurt")
    SFX.play(49)

    Routine.wait(1)
    local toadie = spawnToadie1Actor(-160064, -160318)
    toadie.direction = DIR_LEFT
    toadie:setAnimation("fly")
    toadie.speedX = 9.4

    yoshi:setAnimation("run")
    yoshi.speedX = 4

    Routine.wait(0.25)
    SFX.play(1)
    yoshi:setAnimation("jump")
    yoshi.speedY = -9.6

    Routine.wait(0.56)
    yoshi:setAnimation("cling")
    yoshi.gravity = 0
    yoshi.speedY = 0
    yoshi.speedX = 0

    toadie.speedX = 0
    toadie.isInvisible = 0

    SFX.play("climbing_5.ogg")

    local yoshiCling = self:runChildRoutine(function()
        while yoshi.isValid do
            yoshi.speedY = math.cos(lunatime.tick() / 3) * 1.5

            Routine.skip()
        end
    end)

    Routine.wait(0.3)
    SFX.play("Toadie talks.wav")

    Routine.wait(0.9)
    createDialogueBox(vector(yoshi.x,yoshi.y),"<boxStyle yi>get off me!!!")

    Routine.wait(0.1)
    local magic = spawnMagicActor(-159168, -160324)
    magic:setAnimation("idle")
    magic.speedX = -5.3
    SFX.play(41)

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

    Routine.wait(1.3)
    yoshiCling:abort()

    Defines.earthquake = 5
    distortionEffects.create{x = magic.x+(magic.width/2),y = magic.y+(magic.height/2)}
    SFX.play("Explosion.wav")
    SFX.play(49)

    magic:remove()

    yoshi:setAnimation("hurt")
    yoshi.gravity = 0.26
    yoshi.speedY = -5.5
    yoshi.speedX = -2

    toadie.isInvisible = false
    toadie.speedX = 5

    Routine.wait(0.25)
    toadie.speedX = 0
    toadie.direction = DIR_RIGHT

    Routine.wait(0.7)
    yoshi:setAnimation("spinning")
    yoshi.speedX = 0

    Routine.wait(0.9)
    kamek.x = -159168
    kamek.y = -160448
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
    jail.x = -159168
    jail.y = -160248
    jail.direction = DIR_RIGHT
    jail.speedX = -10.3
    jail:setAnimation("flyWith3")

    local jailStop = self:runChildRoutine(function()
        while jail.isValid do
            jail.speedX = jail.speedX + 0.25
            if jail.speedX > 0 then
                jail.speedX = 0
                jail:setAnimation("intriguedWith3")
            end

            Routine.skip()
        end
    end)

    Routine.wait(0.9)
    SFX.play("MLTP Sounds/Mario 4.ogg")
    SFX.play("MLTP Sounds/Luigi 3.ogg")
    SFX.play("MLTP Sounds/Toad 4.wav")
    SFX.play("MLTP Sounds/Peach 4.wav")

    yoshi:setAnimation("idle")

    Routine.wait(0.5)
    toadie.speedY = 4
    toadie.speedX = 3
    toadie.direction = DIR_LEFT

    Routine.wait(0.64)
    jailStop:abort()
    jail:setAnimation("intrigued")
    toadie:remove()

    Routine.wait(1)
    yoshi:setAnimation("lookUp")
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
    Audio.MusicChange(2, "music/Kamek's Theme.ogg")
    Routine.wait(0.1)
    createDialogueBox(vector(kamek.x,kamek.y),"<boxStyle yi>who are you???? do not follow us")

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

    Routine.wait(0.54)
    SFX.play("MLTP Sounds/Mario 3.ogg")
    SFX.play("MLTP Sounds/Luigi 4.ogg")
    SFX.play("MLTP Sounds/Toad 3.wav")
    SFX.play("MLTP Sounds/Peach 3.wav")

    yoshi:setAnimation("idle")

    jail:setAnimation("fly")
    jail.speedX = 10

    Routine.wait(1.5)
    yoshi:setAnimation("hurt")
    SFX.play(49)

    Routine.wait(1)
    yoshi:setAnimation("run")
    yoshi.speedX = 7

    Routine.wait(4)
    self:runChildRoutine(function()
        while (finalFadeOut < 1) do
            finalFadeOut = math.min(1,finalFadeOut + 0.032)
            Routine.skip(true)
        end
    end)
    Routine.wait(0.64)
    Level.load("1-0.lvlx")
end

function onDraw()
    if finalFadeOut > 0 then
		Graphics.drawScreen{priority = 10,color = Color.black.. finalFadeOut}
	end
end

-- Trigger the cutscene using an event
function onEvent(eventName)
    if eventName == "intro start" then
        intro:start()
    end
end