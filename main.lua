--[[
	Created by Joshua LeBlanc for http://bacongamejam.org/jams/bacongamejam-06/ between
	October 25th and october 27th 2013
	Music generated at tone.wolfram.com
	Sound effects generated at http://www.bfxr.net/
	Made using LÖVE: https://love2d.org/
	music file: http://tones.wolfram.com/id/GRfDibfNRqU9q3NHcnMb2mGPDT1hn0JvPeujFvRLn3Fzx&abmnk=3
--]]

io.stdout:setvbuf("no")
local Player = require("player")
local Barrier = require("barrier")
local Field = require("field")
local Goal = require("Goal")
local tx, ty = 0, 0
local help = true
local firstLevel = "level1.tmx"
tileSize = 32
local nextLevel = 1
local paused = false
local goalSound = love.audio.newSource("lib/goal.wav")
local hitSound = love.audio.newSource("lib/hitSound.wav")
local hitWall = false
local hitGround = false
hitSound:setVolume(.1)

function love.draw()
	if(help) then
		love.graphics.drawq(img,q,0,0)
		paused = true
	elseif thanks then
		love.graphics.drawq(thanksimg,tq, 0, 0)
		paused = true
	else
		paused = false
		love.graphics.translate(math.floor(tx), math.floor(ty))
		map:autoDrawRange(math.floor(tx), math.floor(ty), 1, pad)
		map:draw()

		objects.player:draw()
		love.graphics.setColor(255,255,255)
		love.graphics.print("level "..(nextLevel-1),0,0)
	end
end
function love.update(dt)

	if love.mouse.isDown("l") then
		help = false
	end
	if paused then return end

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
	if not player:hasCollisions() then
		player:setCanJump(false)
		hitWall = false
		hitGround = false
	end

	if love.keyboard.isDown("left") or love.keyboard.isDown("a") then 
		if(player:getState() == "orange") then
			player:jump()

		elseif player:getState() == "yellow" then
		else 
			if player:isViolet() then
				player:moveRight()
			else
				player:moveLeft()
			end
		end
	end	
	if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
		if player:getState() == "yellow" then
			player:jump()
		elseif player:getState() == "orange" then
		else 
			if player:isViolet() then
				player:moveLeft()
			else
				player:moveRight()
			end
		end
	end 
	if love.keyboard.isDown("up") or love.keyboard.isDown("w") then 
		if player:getState() == "orange" then
			if player:isViolet() then
				player:moveLeft()
			else
				player:moveRight()
			end
		elseif player:getState() == "yellow" then
			if player:isViolet() then
				player:moveRight()
			else
				player:moveLeft()
			end
		elseif player:getState() == "red" then
		else 
			if (player:jump()) then
			end
		end
	end
	if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
		if player:getState() == "orange" then
			if player:isViolet() then
				player:moveRight()
			else
				player:moveLeft()
			end
		elseif player:getState() == "yellow" then
			if player:isViolet() then
				player:moveLeft()
			else
				player:moveRight()
			end
		elseif player:getState() == "red" then
			player:jump()
		end
	end
	if love.keyboard.isDown("r") then
		reset()
	end
	if love.keyboard.isDown("escape") then
		help = true
	end
end
function reset()
	nextLevel = nextLevel - 1
	loadMap("level"..(nextLevel)..".tmx")
	init()
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
			name == "violet" or
			name == "white" then
				objects.fields[#objects.fields + 1] = Field:new(world, x*tileSize, y*tileSize, tileSize, tileSize, name)
		end
		if name == "goal" then
			objects.goal = Goal:new(world, x*tileSize, y*tileSize, tileSize, tileSize, "goal")
		end
	end
	love.graphics.setBackgroundColor(104, 136, 248)
end
function love.load()
	local sound = love.audio.newSource("lib/music1.mp3")
	sound:setVolume(.2)
	sound:setLooping(true)
	love.audio.play(sound)
	goalSound:setVolume(.2)
	goalSound:rewind()
	img = love.graphics.newImage("lib/HowToPlay.png")
	q = love.graphics.newQuad(0,0,800,800,800,800)
	thanksimg = love.graphics.newImage("lib/thanks.png")
	tq = love.graphics.newQuad(0,0,800,800,800,800)
	loadMap(firstLevel)
	init()
	
end
function loadNextLevel()
	if nextLevel == 15 then
		thanks = true
	else
		loadMap("level"..tostring(nextLevel)..".tmx")
		init()
	end
end
function beginContact(a, b, coll)	
	local player = objects.player
	player:addCollision()
	if(a:getUserData() == "goal" or b:getUserData() == "goal") then
		love.audio.play(goalSound)
		goalSound:rewind()
		loadNextLevel()
	end
	
	if not player:getCanJump() and not hitWall then
		love.audio.play(hitSound)
		hitSound:rewind()		
		hitWall = true
	end
end
function endContact(a, b, coll)
	local player = objects.player
	player:removeCollision()
	if not player:hasCollisions() then
		player:setCanJump(false)
		player:setIsJumping(true)
	end
end
function postSolve(a,b,coll)
	local player = objects.player
	if player:onGround(coll:getNormal()) then
		if not hitGround then
			love.audio.play(hitSound)
			hitSound:rewind()
			hitWall = false
		end
		hitGround = true
		if not player:getIsJumping() then
			player:setCanJump(true)
		end
		player:setIsJumping(false)
	end
end
function preSolve(a,b,coll)
	local player = objects.player
	if(player:againstWall(coll:getNormal())) then
		if not (love.physics.getDistance(a,b) == 0) then
			coll:setEnabled(false)
		end
	end
	player:setPreDirection()
end