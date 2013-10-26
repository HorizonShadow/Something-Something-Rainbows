io.stdout:setvbuf("no")
local atl = require("AdvTiledLoader")
local Player = require("player")
local Barrier = require("barrier")
local Field = require("field")
atl.Loader.path = 'lib/'
local map = atl.Loader.load("test.tmx")
local tx, ty = 0, 0
tileSize = 32
numColl = 0
canJump = true
function love.draw()
	
	love.graphics.translate(math.floor(tx), math.floor(ty))
	map:autoDrawRange(math.floor(tx), math.floor(ty), 1, pad)
	map:draw()

	objects.player:draw()
	
end
function love.update(dt)
	world:update(dt)
	player = objects.player
	pGridCoords = player:getGridCoords()
	for id, field in pairs(objects.fields) do 
		fGridCoords = field:getGridCoords()
		if fGridCoords.x == pGridCoords.x and fGridCoords.y == pGridCoords.y then
			data = field.fixture:getUserData() 
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
	if love.keyboard.isDown("up") and numColl > 0 then 
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
			Barrier:new(world, x*tileSize, y*tileSize, tileSize, tileSize, "Floor")
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
	numColl = numColl + 1
	

end
function endContact(a, b, coll)
	numColl = numColl - 1
	if numColl == 0 then 
		canJump = false
	end
end

function preSolve(a, b, coll)
	nx, ny = coll:getNormal()
	if(nx < -30 or nx > 30) then 
		canJump = false
	else
end

function postSolve(a, b, coll)
end