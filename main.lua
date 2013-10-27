io.stdout:setvbuf("no")
local Player = require("player")
local Barrier = require("barrier")
local Field = require("field")
local Goal = require("Goal")
local tx, ty = 0, 0
local help = true
local firstLevel = "level4.tmx"
tileSize = 32
local nextLevel = 1
function love.draw()
	if(help) then
		love.graphics.drawq(img,q,0,0)
	else
		love.graphics.translate(math.floor(tx), math.floor(ty))
		map:autoDrawRange(math.floor(tx), math.floor(ty), 1, pad)
		map:draw()

		objects.player:draw()
		love.graphics.setColor(255,255,255)
		love.graphics.print(tostring(objects.player.canJump), 0,0)
	end
end
function love.update(dt)
	if love.mouse.isDown("l") then
		help = false
	end
	world:update(dt)
	local player = objects.player
	local pGridCoords = player:getGridCoords()
	for id, field in pairs(objects.fields) do 
		fGridCoords = field:getGridCoords()
		if fGridCoords.x == pGridCoords.x and fGridCoords.y == pGridCoords.y then
			local data = field.fixture:getUserData()
			x, y = player:setControls(data)
			world:setGravity(x * 9.81 * tileSize, y * 9.81 * tileSize)
		end
	end	

	if love.keyboard.isDown("left") then 
		if(player:getState() == "orange") then
			player:jump()
		elseif player:getState() == "yellow" then
		else player:moveLeft()
		end
	end	
	if love.keyboard.isDown("right") then
		if player:getState() == "yellow" then
			player:jump()
		elseif player:getState() == "orange" then
		else player:moveRight()
		end
	end 
	if love.keyboard.isDown("up") then 
		if player:getState() == "orange" then
			player:moveRight()
		elseif player:getState() == "yellow" then
			player:moveLeft()
		elseif player:getState() == "red" then
		else player:jump()
		end
	end
	if love.keyboard.isDown("down") then
		if player:getState() == "orange" then
			player:moveLeft()
		elseif player:getState() == "yellow" then
			player:moveRight()
		elseif player:getState() == "red" then
			player:jump()
		end
	end
end
function loadMap(s)
	atl = require("AdvTiledLoader")
	atl.Loader.path = 'lib/'
	map = atl.Loader.load(tostring(s))
	nextLevel = nextLevel + 1
end
function init()
	love.graphics.setMode(25*tileSize, 25*tileSize, false, false, 0)
	love.physics.setMeter(tileSize)
	world = love.physics.newWorld(0,9.81*tileSize, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)
	objects = {}
	objects.ground = {}
	objects.fields = {}
	for x,y,tile in map("Tile Layer 1"):iterate() do
		local name = tile.properties.name
		if name == "floor" then
			objects.ground[#objects.ground+1] = Barrier:new(world, x*tileSize, y*tileSize, tileSize, tileSize, "Floor")
		end
		if name == "wall" then
			Barrier:new(world, x*tileSize, y*tileSize, tileSize, tileSize, "Wall")	
		end
		if name == "spawn" then
			objects.player = Player:new(world, x*tileSize, y*tileSize)
		end
		if  name == "red" or 
			name == "orange" or
			name == "yellow" or
			name == "green" or 
			name == "blue" or 
			name == "indigo" or 
			name == "violet" then
				objects.fields[#objects.fields + 1] = Field:new(world, x*tileSize, y*tileSize, tileSize, tileSize, name)
		end
		if name == "goal" then
			objects.goal = Goal:new(world, x*tileSize, y*tileSize, tileSize, tileSize, "goal")
		end
	end
	love.graphics.setBackgroundColor(104, 136, 248)
end
function love.load()
	img = love.graphics.newImage("lib/HowToPlay.png")
	q = love.graphics.newQuad(0,0,800,800,800,800)
	loadMap(firstLevel)
	init()
	
end
function loadNextLevel()
	loadMap("level"..tostring(nextLevel)..".tmx")
	init()
end
function beginContact(a, b, coll)	
	local player = objects.player
	player:addCollision()
	if player:onGround(a,b) then
		player:setCanJump(true)
	end
	if(a:getUserData() == "goal" or b:getUserData() == "goal") then
		loadNextLevel()
	end
end
function endContact(a, b, coll)
	local player = objects.player
	player:removeCollision()
	if not player:hasCollisions() then
		player:setCanJump(false)
	end
end
function preSolve(a,b,coll)
	local player = objects.player
	if(player:againstWall(coll:getNormal())) then
		if not (love.physics.getDistance(a,b) == 0) then
			coll:setEnabled(false)
		end
	end
	if(true) then
		if player:onGround(a,b) then
			player:setCanJump(true)
		end
	end
end