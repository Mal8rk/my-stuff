local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")
local colliders = require("Colliders")
local death = Misc.resolveSoundFile("enemyDie")

local guys = {}
local npcIDs = {}

--Register events
function guys.register(id)
	npcManager.registerEvent(id, guys, "onTickEndNPC")
	npcManager.registerEvent(id, guys, "onDrawNPC")
	npcIDs[id] = true
end

function guys.onInitAPI()
    registerEvent(guys, "onNPCHarm")
end

function guys.onTickEndNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	local config = NPC.config[v.id]
	local slopeRotation = 0
	local lock = false
	
	--If despawned
	if v.despawnTimer <= 0 then
		--Reset our properties, if necessary
		data.initialized = false
		data.timer = 0
		data.offset = 0
		data.up = true
		return
	end

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		data.initialized = true
		data.timer = data.timer or 0
		data.squishTimer = 0
		data.offset = data.offset or 0
		data.up = true
		data.detectBox = colliders.Box(v.x, v.y, v.width / 2, v.height * 1 + 1);
	end
	
	--If grabbed then turn it into a rolling shy guy, more intended for MrDoubleA's playable.
	if v:mem(0x12C, FIELD_WORD) > 0 or (v:mem(0x138, FIELD_WORD) > 0 and (v:mem(0x138, FIELD_WORD) ~= 4 and v:mem(0x138, FIELD_WORD) ~= 5)) then
		data.timer = 0
		v:transform(751)
		v.ai2 = config.colour
		if v.direction == DIR_LEFT then
			v.ai1 = config.leftRollFrame
		else
			v.ai1 = config.rightRollFrame
		end
	end
	
	if v.collidesBlockBottom then
		v.speedX = 0
		data.timer = data.timer + 1
	end
	
	--Jump when the timer reaches this number
	if data.timer >= 40 then
		data.timer = -8
		v.speedY = -6
		v.speedX = 2 * v.direction
	end
	
	if data.squishTimer > 3 then
		data.up = false
	end
	
	--Squash the sprite a bit before and after jumping and reset rotation to 0
	if v.speedX == 0 and v.collidesBlockBottom then
		data.rotation = slopeRotation
		if data.timer == -8 or data.timer == 32 then
			data.squishTimer = 1
		elseif data.timer < 0 or data.timer >= 32 then
			if data.up then
				data.squishTimer = data.squishTimer + 1
			else
				data.squishTimer = data.squishTimer - 1
			end
		else
			data.squishTimer = 0
			data.up = true
		end
	else
		data.squishTimer = 0
		data.up = true
	end
	
	--Move collider with NPC
	if v.direction == DIR_LEFT then
		data.detectBox.x = v.x
	else
		data.detectBox.x = v.x + 16
	end
	data.detectBox.y = v.y + 24
	
	--Code to make the NPC adjust its sprite accordingly with slopes
	local collidingBlocks = Colliders.getColliding{
    a = data.detectBox,
    b = Block.SOLID .. Block.SEMISOLID .. Block.PLAYER,
    btype = Colliders.BLOCK,
	}
	
	for _,block in pairs(collidingBlocks) do
		if Block.config[block.id].floorslope ~= 0 then
			lock = true
			if Block.config[block.id].floorslope == 1 then
				if v.direction == DIR_LEFT then
					slopeRotation =	(1 - Block.config[block.id].height / Block.config[block.id].width * 50 * v.direction)
				else
					slopeRotation =	(1 - Block.config[block.id].height / Block.config[block.id].width * -50 * v.direction)
				end
			elseif Block.config[block.id].floorslope == -1 then
				if v.direction == DIR_LEFT then
					slopeRotation =	(1 - Block.config[block.id].height / Block.config[block.id].width * -50 * v.direction)
				else
					slopeRotation =	(1 - Block.config[block.id].height / Block.config[block.id].width * 50 * v.direction)
				end
			end
			
			--Make the sprite display a little better when on slopes
			if v.collidesBlockBottom then
				data.offset = math.floor(0.2 * slopeRotation) * Block.config[block.id].floorslope
			end
		else
			if not lock then
				data.offset = 0
			end
		end
		if v.collidesBlockBottom then
			data.rotation = slopeRotation
		end
	end

	--Rotate when moving
	if not v.collidesBlockBottom and data.timer == -8 then
		data.rotation = ((data.rotation or 0) + math.deg((v.speedX*config.speed)/((v.width+v.height)/4.45)))
	end
end

--When harmed, make the NPC do various things, such as transforming into a rolling shy guy or playing a sound effect.
function guys.onNPCHarm(eventObj,v,reason,culprit)
	local data = v.data
	local config = NPC.config[v.id]
	if not npcIDs[v.id] then return end
	if reason == HARM_TYPE_JUMP then	
		SFX.play(death)
	elseif reason == HARM_TYPE_NPC or reason == HARM_TYPE_TAIL then	
		if culprit then
			if culprit.isValid and type(culprit) == "NPC" and culprit.id == 195 or culprit.id == 50 then
				return
			else
				if type(culprit) == "Player" or (type(culprit) == "NPC" and NPC.HITTABLE_MAP[culprit.id] or culprit.id == 45 and v:mem(0x138, FIELD_WORD) == 0) then -- Turn the shy guy into a rolling version
					eventObj.cancelled = true
					v:transform(751)
					v.dontMove = false
					v.speedX = 3.5 * culprit.direction
					v.ai2 = config.colour
					if v.direction == DIR_LEFT then
						v.ai1 = config.leftRollFrame
					else
						v.ai1 = config.rightRollFrame
					end
					if type(culprit) == "NPC" and NPC.HITTABLE_MAP[culprit.id] or culprit.id == 45 and v:mem(0x138, FIELD_WORD) == 0  then
						culprit:kill()
					elseif type(culprit) == "Player" and reason == HARM_TYPE_TAIL then
						SFX.play(2)
						Animation.spawn(75, v.x, v.y)
					end
				end
			end
		else
		return
		end
	else
	return
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

	sprite.pivot = args.pivot or Sprite.align.CENTER
	sprite.rotation = args.rotation or 0

	if args.texture ~= nil then
		sprite.texpivot = args.texpivot or sprite.pivot or Sprite.align.CENTER
		sprite.texscale = args.texscale or vector(args.texture.width*(args.width/args.sourceWidth),args.texture.height*(args.height/args.sourceHeight))
		sprite.texposition = args.texposition or vector(-args.sourceX*(args.width/args.sourceWidth)+((sprite.texpivot[1]*sprite.width)*((sprite.texture.width/args.sourceWidth)-1)),-args.sourceY*(args.height/args.sourceHeight)+((sprite.texpivot[2]*sprite.height)*((sprite.texture.height/args.sourceHeight)-1)))
	end

	sprite:draw{priority = args.priority,color = args.color,sceneCoords = args.sceneCoords or args.scene}
end

function guys.onDrawNPC(v)
	local config = NPC.config[v.id]
	local data = v.data

	if v:mem(0x12A,FIELD_WORD) <= 0 or not data.rotation then return end

	local priority = -45
	if config.priority then
		priority = -15
	end

	drawSprite{
		texture = Graphics.sprites.npc[v.id].img,

		x = v.x+(v.width/2)+config.gfxoffsetx,y = v.y+v.height-(config.gfxheight/2)+config.gfxoffsety + data.squishTimer * 2 + data.offset,
		width = config.gfxwidth,height = config.gfxheight - data.squishTimer * 4,

		sourceX = 0,sourceY = v.animationFrame*config.gfxheight,
		sourceWidth = config.gfxwidth,sourceHeight = config.gfxheight,

		priority = priority,rotation = data.rotation,
		pivot = Sprite.align.CENTRE,sceneCoords = true,
	}

	npcutils.hideNPC(v)
end

--Gotta return the library table!
return guys