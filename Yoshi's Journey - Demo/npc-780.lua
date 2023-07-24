local npcManager = require("npcManager")
local npc = {}
local id = NPC_ID

npcManager.setNpcSettings({
	id = id,
	
	width = 256,
	gfxwidth = 256,
	height = 256,
	gfxheight = 256,
	
	jumphurt = true,
	
	frames = 4,
	framespeed = 4,
	framestyle = 1,
	
	nogravity = true,
	noblockcollision = true,
})

function npc.onInitAPI()
	npcManager.registerEvent(id, npc, 'onTickEndNPC')
	npcManager.registerEvent(id, npc, 'onCameraDrawNPC')
end

local function drawNPC(npcobject, args)
    args = args or {}
    if npcobject.__type ~= "NPC" then
        error("Must pass a NPC object to draw. Example: drawNPC(myNPC)")
    end
    local frame = args.frame or npcobject.animationFrame

    local afs = args.applyFrameStyle
    if afs == nil then afs = true end

    local cfg = NPC.config[npcobject.id]
    
    --gfxwidth/gfxheight can be unreliable
    local trueWidth = cfg.gfxwidth
    if trueWidth == 0 then trueWidth = npcobject.width end

    local trueHeight = cfg.gfxheight
    if trueHeight == 0 then trueHeight = npcobject.height end

    --drawing position isn't always exactly hitbox position
    local x = npcobject.x + 0.5 * npcobject.width - 0.5 * trueWidth + cfg.gfxoffsetx + (args.xOffset or 0)
    local y = npcobject.y + npcobject.height - trueHeight + cfg.gfxoffsety + (args.yOffset or 0)

    --cutting off our sprite might be nice for piranha plants and the likes
    local w = args.width or trueWidth
    local h = args.height or trueHeight

    local o = args.opacity or 1

    --the bane of the checklist's existence
    local p = args.priority or -45
    if cfg.foreground then
        p = -15
    end
	
	local direction = args.direction or npcobject.direction
    local sourceX = args.sourceX or 0
    local sourceY = args.sourceY or 0

    --framestyle is a weird thing...

    local frames = args.frames or cfg.frames
    local f = frame or 0
    --but only if we actually pass a custom frame...
    if args.frame and afs and cfg.framestyle > 0 then
        if cfg.framestyle == 2 then
            if npcobject:mem(0x12C, FIELD_WORD) > 0 or npcobject:mem(0x132, FIELD_WORD) > 0 then
                f = f + 2 * frames
            end
        end
        if direction == 1 then
            f = f + frames
        end
    end

	local texture = args.texture or Graphics.sprites.npc[npcobject.id].img
	
    Graphics.drawBox{
		texture = texture, 
		
		x = x + -((args.texwidth) or 0), 
		y = y, 
		
		width = args.texwidth or texture.width,
		sourceX = sourceX, 
		sourceY = sourceY + trueHeight * f, 
		sourceWidth = w, 
		sourceHeight = h, 
		
		color = Color.white .. o, 
		priority = p,
		sceneCoords = true,
	}
end

local CHASE = 0
local DIE = 1

local function drawEye(v, width)
	local config = NPC.config[v.id]
	
	drawNPC(v, {
		frame = config.frames,
		direction = -1,
		texwidth = width
	})	
	
	--tear
	drawNPC(v, {
		frame = config.frames + 1,
		yOffset = v.ai3,
		direction = -1,
		texwidth = width
	})	
	
	--eye
	drawNPC(v, {
		frame = config.frames + 2,
		direction = -1,
		texwidth = width
	})	
end

function npc.onCameraDrawNPC(v)
	if v.despawnTimer <= 0 then return end
	
	local config = NPC.config[v.id]
	local texture = Graphics.sprites.npc[id].img

	if config.framestyle > 0 and v.ai1 == CHASE then
		local time = math.floor(lunatime.tick() / (config.framespeed - math.abs(v.speedX / 6)))
		local frame = time % config.frames
		
		if v.direction == -1 then
			drawNPC(v, {
				frame = frame,
				texwidth = -texture.width,
			})
		else
			drawNPC(v, {
				frame = frame,
				direction = -1,
			})	
		end
	elseif v.ai1 == DIE then
		if config.framestyle > 0 then
			if v.direction == -1 then
				drawEye(v, -texture.width)
			else
				drawEye(v)
			end
		else
			drawEye(v)
		end
	end
end

local function outBounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then
    return c * (7.5625 * t * t) + b
  elseif t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  else
    t = t - (2.625 / 2.75)
    return c * (7.5625 * t * t + 0.984375) + b
  end
end

function npc.onTickEndNPC(v)
	if v.despawnTimer <= 0 then return end
	
	if v.despawnTimer > 0 then
		v.despawnTimer = 180
	end
	
	local data = v.data._basegame
	
	if v.ai2 ~= 0 and not data.id then
		data.id = v.ai2
		v.ai2 = 0
	end
	
	local config = NPC.config[v.id]
	
	if config.framestyle > 0 or v.ai1 == DIE then
		v.animationFrame = -1
	end
	
	local p = Player.getNearest(v.x + v.width / 2, v.y + v.height / 2)
	
	if v.ai1 == CHASE then
		if v.direction == 1 then
			local distance = (p.x - p.width) - (v.x + v.width)
			
			v.speedX = (distance / 12) + 3
			
			v.speedX = math.clamp(v.speedX, 0, 6)
		else
			local distance = (p.x - p.width) - v.x
			
			v.speedX = ((distance / 12) + 3)
			
			v.speedX = math.clamp(v.speedX, -6, 0)
		end
	
		for k,b in Block.iterateIntersecting(v.x, v.y, v.x + v.width, v.y + v.height) do
			local c = Block.config[b.id]
			
			local invis1 = v:mem(0x5A, FIELD_WORD)
			local invis2 = v.isHidden
			
			if c.id == data.id then
				Defines.earthquake = 8
				v.speedX = 0
				v.ai1 = DIE
				v.ai2 = 0
				v.ai3 = -40
				v.friendly = true
				
				return
			end
			
			if c.smashable and not invis2 and invis1 >= 0 then
				b:remove(true)
			end
		end
	else
		v.ai2 = v.ai2 + 0.0075
		
		v.ai2 = math.clamp(v.ai2, 0, 1)
		
		v.ai3 = outBounce(v.ai2, -40, 40, 1)
		
		if v.ai2 >= 1 then
			v.ai4 = v.ai4 + 1
			
			if v.ai4 > 64 then
				v:kill(9)
				
				SFX.play 'falling_chomp.wav'
				
				local e = Effect.spawn(764, v.x, v.y)
				e.direction = v.direction
			end
		end
	end
end

return npc