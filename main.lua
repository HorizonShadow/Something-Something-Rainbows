io.stdout:setvbuf("no")
local atl = require("AdvTiledLoader")
local Player = require("player")
local Barrier = require("barrier")
local Field = require("field")
atl.Loader.path = 'lib/'
local map = atl.Loader.load("test.tmx")
local tx, ty = 0, 0
tileSize = 32
function love.draw()
	
	love.graphics.translate(math.floor(tx), math.floor(ty))
	map:autoDrawRange(math.floor(tx), math.floor(ty), 1, pad)
	map:draw()

	objects.player:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.print(tostring(objects.player.canJump), 0,0)
	
end
function love.update(dt)
	world:update(dt)
	local player = objects.player
	local pGridCoords = player:getGridCoords()
	for id, field in pairs(objects.fields) do 
		fGridCoords = field:getGridCoords()
		if fGridCoords.x == pGridCoords.x and fGridCoords.y == pGridCoords.y then
			local data = field.fixture:getUserData() 
			if data == "Red" then 
				world:setGravity(0,-9.81*tileSize)
				player:setControls("red")
			elseif data == "Orange" then
				world:setGravity(9.81*tileSize, 0)
				player:setControls("orange")
			elseif data == "Yellow" then
			elseif data == "Green" then
			elseif data == "Blue" then
			elseif data == "Indigo" then
			elseif data == "Violet" then
			end
		end
	end	

	if love.keyboard.isDown("left") then 
		player:moveLeft()
	end	
	if love.keyboard.isDown("right") then
		player:moveRight()
	end 
	if love.keyboard.isDown("up") then 
		player:jump()
	end
end
function love.load()
	love.graphics.setMode(25*tileSize, 25*tileSize, false, false, 0)
	love.physics.setMeter(tileSize)
	world = love.physics.newWorld(0,9.81*tileSize, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)
	objects = {}
	objects.ground = {}
	objects.fields = {}
	for x,y,tile in map("Tile Layer 1"):iterate() do
		if tile.properties.name == "floor" then
			objects.ground[#objects.ground+1] = Barrier:new(world, x*tileSize, y*tileSize, tileSize, tileSize, "Floor")
			
		end
		if tile.properties.name == "wall" then
			Barrier:new(world, x*tileSize, y*tileSize, tileSize, tileSize, "Wall")	
		end
		if tile.properties.name == "spawn" then
			objects.player = Player:new(world, x*tileSize, y*tileSize)
		end
		if tile.properties.name == "red" then
			objects.fields[#objects.fields + 1] = Field:new(world, x*tileSize, y*tileSize, tileSize, tileSize, "Red")
		end
		if tile.properties.name == "orange" then 
			objects.fields[#objects.fields + 1] = Field:new(world, x*tileSize, y*tileSize, tileSize, tileSize, "Orange")
		end
	end
	love.graphics.setBackgroundColor(104, 136, 248)
 end

function beginContact(a, b, coll)
	--print(a:getBody():getLinearVelocity())
	local player = objects.player
	player:addCollision()
	if player:onGround(coll:getNormal()) then
		player:setCanJump(true)
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
	--This is a fix for when the player would get stuck on flat ground
	local player = objects.player
	if(player:againstWall(coll:getNormal())) then
		if not (love.physics.getDistance(a,b) == 0) then
			coll:setEnabled(false)
		end
	end
end