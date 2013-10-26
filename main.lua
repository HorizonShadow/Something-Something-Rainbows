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
fieldCount = {
	red = 0,
	orange = 0,
	yellow = 0,
	green = 0,
	blue = 0,
	indigo = 0,
	violet = 0
}
function love.draw()
	
	love.graphics.translate(math.floor(tx), math.floor(ty))
	map:autoDrawRange(math.floor(tx), math.floor(ty), 1, pad)
	map:draw()

	objects.player:draw()
	
end
function love.update(dt)
	world:update(dt)
	player = objects.player
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
	for x,y,tile in map("Tile Layer 1"):iterate() do
		if tile.properties.name == "floor" then
			Barrier:new(world, x*tileSize, y*tileSize, tileSize, tileSize, "Floor")
		end
		if tile.properties.name == "wall" then
			Barrier:new(world, x*tileSize, y*tileSize, tileSize, tileSize, "Wall")	
		end
		if tile.properties.name == "spawn" then
			objects.player = Player:new(world, x*tileSize, y*tileSize, tileSize, tileSize)
		end
		if tile.properties.name == "red" then
			Field:new(world, x*tileSize, y*tileSize, tileSize, tileSize, "Red")
		end
	end
	  love.graphics.setBackgroundColor(104, 136, 248)
 end

function beginContact(a, b, coll)
	if (a:getUserData() ~= "Wall" and b:getUserData() ~= "Wall") then
			numColl = numColl + 1
	end
	if a:getUserData() == "Red" or b:getUserData() == "Red" then
		fieldCount.red = fieldCount.red + 1
end
function endContact(a, b, coll)
	if (a:getUserData() ~= "Wall" and b:getUserData() ~= "Wall") then
			numColl = numColl - 1
	end
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll)
end