local animationPal = require("animationPal")
local cutscenePal = require("cutscenePal")
require("collectibleLibs/level E-coins")

local chomp = cutscenePal.newScene("chomp")

chomp.canSkip = false

local function spawnChompActor(x,y)
    -- Spawn an actor.
    -- It is a "child" of the scene rather than a global one, so it will be removed when the scene ends.
    local actor = chomp:spawnChildActor(x,y)

    -- Set up properties for the actor
    actor.image = Graphics.loadImageResolved("big_chomp.png")
    actor:setFrameSize(256,256) -- each frame is 16x16
    actor:setSize(256,256) -- hitbox size is 16x16

    actor.priority = -46

    -- Set up an actor's animations, using the same arguments as animationPal.createAnimator.
    actor:setUpAnimator{
        animationSet = {
            chomp = {1,2,3,4, frameDelay = 6},
        },
        startAnimation = "chomp",
    }

    -- Return it
    chomp.data.chompActor = actor

    return actor
end

function chomp:mainRoutineFunc()
    player.speedX = 0

    local invis = Layer.get("moveinvis")
    invis:hide(true)
    
    Routine.wait(0.25)
    player.direction = DIR_LEFT

    local bigchomp = spawnChompActor(-99936, -99544)
    bigchomp.direction = DIR_RIGHT
    
    bigchomp:walkAndWait{
        goal = -99676,speed = 2,setDirection = false,
        walkAnimation = "chomp",stopAnimation = "chomp",
    }

    Routine.wait(1.9)
    bigchomp:remove()
    local realchomp = Layer.get("bigchomp")
    realchomp:show(true)

    local barrier = Layer.get("barrier")
    barrier:hide(true)
end

function onEvent(eventName)
    if eventName == "log" then
        Effect.spawn(772, -199776 + -40, -200768 + -40)
    elseif eventName == "fall" then
        SFX.play("falling_chomp.wav")
    elseif eventName == "platform" then
        Effect.spawn(833, -119328 + -40, -120096 + -40)
        Effect.spawn(833, -119232 + -40, -120128 + -40)
        Effect.spawn(833, -119264 + -40, -120064 + -40)
        Effect.spawn(833, -119200 + -40, -120064 + -40)
        Defines.earthquake = 7
    elseif eventName == "fall2" then
        SFX.play("falling_chomp.wav")
    elseif eventName == "platform2" then
        Effect.spawn(833, -118016 + -40, -120224 + -40)
        Effect.spawn(833, -117920 + -40, -120256 + -40)
        Effect.spawn(833, -117984 + -40, -120192 + -40)
        Effect.spawn(833, -117888 + -40, -120224 + -40)
        Defines.earthquake = 7
    elseif eventName == "fall3" then
        SFX.play("falling_chomp.wav")
    elseif eventName == "platform3" then
        Effect.spawn(833, -117696 + -40, -120160 + -40)
        Effect.spawn(833, -117728 + -40, -120128 + -40)
        Effect.spawn(833, -117632 + -40, -120096 + -40)
        Effect.spawn(833, -117600 + -40, -120128 + -40)
        Defines.earthquake = 7
    elseif eventName == "fall4" then
        SFX.play("falling_chomp.wav")
    elseif eventName == "platform4" then
        Effect.spawn(833, -116960 + -40, -120096 + -40)
        Effect.spawn(833, -116992 + -40, -120064 + -40)
        Effect.spawn(833, -116896 + -40, -120032 + -40)
        Effect.spawn(833, -116864 + -40, -116864 + -40)
        Defines.earthquake = 7
    elseif eventName == "fall5" then
        SFX.play("falling_chomp.wav")
    elseif eventName == "platform5" then
        Effect.spawn(833, -115936 + -40, -120256 + -40)
        Effect.spawn(833, -115968 + -40, -120224 + -40)
        Effect.spawn(833, -115904 + -40, -120192 + -40)
        Effect.spawn(833, -115840 + -40, -120224 + -40)
        Defines.earthquake = 7
    elseif eventName == "fall6" then
        SFX.play("falling_chomp.wav")
    elseif eventName == "platform6" then
        Effect.spawn(833, -115520 + -40, -120256 + -40)
        Effect.spawn(833, -115552 + -40, -120224 + -40)
        Effect.spawn(833, -115456 + -40, -120192 + -40)
        Effect.spawn(833, -115424 + -40, -120224 + -40)
        Defines.earthquake = 7
    elseif eventName == "log2" then
        Effect.spawn(772, -130688 + -40, -140224 + -40)
    elseif eventName == "fall7" then
        SFX.play("falling_chomp.wav")
    elseif eventName == "platform7" then
        Effect.spawn(833, -114368 + -40, -120224 + -40)
        Effect.spawn(833, -114368 + -40, -120192 + -40)
        Effect.spawn(833, -114304 + -40, -120160 + -40)
        Effect.spawn(833, -114272 + -40, -120192 + -40)
        Defines.earthquake = 7
    elseif eventName == "fall8" then
        SFX.play("falling_chomp.wav")
    elseif eventName == "platform8" then
        Effect.spawn(833, -113568 + -40, -120064 + -40)
        Effect.spawn(833, -113600 + -40, -120032 + -40)
        Effect.spawn(833, -113504 + -40, -120032 + -40)
        Effect.spawn(833, -113472 + -40, -120064 + -40)
        Defines.earthquake = 7
    end

    if eventName == "chomp" then
        chomp:start()
    end
end
