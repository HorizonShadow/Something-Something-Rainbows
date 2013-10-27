local Player = {}
local tileSize = 32
local force = 110
local jumpForce = 60
local jumpSound = love.audio.newSource("lib/jump7.wav")
local greenSound = love.audio.newSource("lib/powerup42.wav")
local redSound = love.audio.newSource("lib/redSound.wav")
local orangeSound = love.audio.newSource("lib/orangeSound.wav")
local yellowSound = love.audio.newSource("lib/yellowSound.wav")
local blueSound = love.audio.newSource("lib/blueSound.wav")
local violetSound = love.audio.newSource("lib/violetSound.wav")
local indigoSound = love.audio.newSource("lib/indigoSound.wav")
jumpSound:setVolume(.2)
greenSound:setVolume(.2)
redSound:setVolume(.2)
orangeSound:setVolume(.2)
blueSound:setVolume(.2)
violetSound:setVolume(.2)
yellowSound:setVolume(.2)
indigoSound:setVolume(.2)
function Player:new(world, x, y)
	body = love.physics.newBody(world, x, y, "dynamic")
	shape = love.physics.newRectangleShape(16,16)
	fixture = love.physics.newFixture(body, shape, 1)
	fixture:setRestitution(0.0)
	fixture:setFriction(0.9)
	fixture:setDensity(1)
	fixture:setUserData("Player")
	fixture:setMask(7)
	fixture:setCategory(8)
	body:setFixedRotation(true)
	local p = {
		body = body,
		shape = shape,
		fixture = fixture,
		leftForces = {x = -force, y = 0},
		rightForces = {x = force, y = 0},
		jumpForces = {x = 0, y = -jumpForce},
		numColls = 0,
		canJump = true,
		violet = false,
		inViolet = false,
		inRed = false,
		inOrange = false,
		inYellow = false,
		inGreen = false,
		inBlue = false,
		inIndigo = false,
		isJumping = false,
		moveX = 0,
		moveY = 0
	}
	setmetatable(p, {__index = Player})
	return p
end
function Player:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill", self.body:getX()+8, self.body:getY()+8, 16, 16)
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("line", self.body:getX()+8, self.body:getY()+8, 16, 16)
	love.graphics.setColor(love.graphics.getBackgroundColor())
end
function Player:moveLeft()
	self.body:applyForce(self.leftForces.x, self.leftForces.y)
end
function Player:moveRight()
	self.body:applyForce(self.rightForces.x, self.rightForces.y)
end
function Player:jump()
	if(self.canJump and not self.isJumping) then 
		self.isJumping = true
		self.canJump = false
		love.audio.play(jumpSound)
		love.audio.rewind(jumpSound)
		self.body:applyLinearImpulse(self.jumpForces.x, self.jumpForces.y)
		return true
	end
	return false
end
function Player:getIsJumping()
	return self.isJumping
end
function Player:setIsJumping(s)
	self.isJumping = s
end
function Player:getGridCoords()
	local c = {
		x = math.ceil((self.body:getX()-(16/2)) / tileSize) + 1,
		y = math.ceil((self.body:getY()-(16/2)) / tileSize) + 1
	}
	return c
end
function Player:isViolet()
	return self.violet
end
function playSound(s)
	love.audio.play(s)
	s:rewind()
end
function Player:setControls(s)
	if s ~= "violet" then self.inViolet = false end
	if s ~= "red" then self.inRed = false end
	if s ~= "orange" then self.inOrange = false end
	if s ~= "yellow" then self.inYellow = false end
	if s ~= "green" then self.inGreen = false end
	if s == "red" and not self.inRed then
		self.inRed = true
		playSound(redSound)
		self:setRightMove(force,0)
		self:setLeftMove(-force,0)
		self:setJump(0,jumpForce)
	elseif s == "orange" and not self.inOrange then
		self.inOrange = true
		playSound(orangeSound)
		self:setRightMove(0,-force)
		self:setLeftMove(0,force)
		self:setJump(-jumpForce,0)
	elseif s == "yellow" and not self.inYellow then
		self.inYellow = true
		playSound(yellowSound)
		self:setRightMove(0, force)
		self:setLeftMove(0, -force)
		self:setJump(jumpForce, 0)
	elseif s == "green" and not self.inGreen then
		self.inGreen = true
		playSound(greenSound)
		self:setRightMove(force, 0)
		self:setLeftMove(-force, 0)
		self:setJump(0, -jumpForce)
	elseif s == "violet" and not self.inViolet then
		playSound(violetSound)
		self.violet = not self.violet
		self.inViolet = true
	elseif s == "indigo" and not self.inIndigo then
		playSound(indigoSound)
		self.inIndigo = true
		self.fixture:setRestitution(.9)
	elseif s == "blue" and not self.inBlue then
		playSound(blueSound)
		self.inBlue = true
		self.fixture:setDensity(.1)
		self.fixture:getBody():resetMassData()
	end
	local x, y = self.jumpForces.x, self.jumpForces.y
	return x == 0 and 0 or -math.abs(x)/x , y == 0 and 0 or -math.abs(y)/y
end
function Player:addCollision()
	self.numColls = self.numColls + 1
end
function Player:removeCollision()
	self.numColls = self.numColls - 1
end
function Player:setPreDirection()
	local vx, vy = self.body:getLinearVelocity()
	self.moveX = vx
	self.moveY = vy
end
function Player:onGround(nx,ny)
	local xDir = getSign(self.jumpForces.x)
	local yDir = getSign(self.jumpForces.y)
	local vx, vy = self.body:getLinearVelocity()
	if yDir ~= 0 and math.abs(nx) == 32 then return false end
	if xDir ~= 0 and math.abs(ny) == 32 then return false end

	if getSign(vy) == -getSign(self.moveY) and (self.moveY ~= 0 or vy ~= 0) and yDir ~= 0 then return true end
	if getSign(vx) == -getSign(self.moveX) and (self.moveX ~= 0 or vx ~= 0) and xDir ~= 0 then return true end
	if math.floor(vy) == 0 then
		if yDir < 0 and self.moveY >= 0 then return true end
		if yDir > 0 and self.moveY <= 0 then return true end
	end
	if vx == 0 then
		if xDir < 0 and self.moveX >= 0 then return true end
		if xDir > 0 and self.moveX <= 0 then return true end
	end

	return false
end
function Player:getState()
	if self.jumpForces.x > 0 then
		return "yellow"
	elseif self.jumpForces.x < 0 then
		return "orange"
	elseif self.jumpForces.y > 0 then
		return "red"
	elseif self.jumpForces.y < 0 then
		return "green"
	end
end
function calcNormals(a,b)
	local x, y = nil

	if a:getUserData() == "Player" then
		x = a
		y = b
	else
		x = b
		y = a
	end
	local dx = y:getBody():getX() - x:getBody():getX()
	local dy = y:getBody():getY() - x:getBody():getY()
	return dx, -dy
end
function Player:againstWall(nx, ny)
	local status = false
	local xDir = getSign(self.rightForces.x)
	local yDir = getSign(self.rightForces.y)
	status = nx == 32 or nx == -32 or ny == 32 or ny == -32
	return status
end
function getSign(x)
	return x==0 and 0 or math.abs(x) / x
end
function Player:setCanJump(x)
	self.canJump = x
end
function Player:getCanJump()
	return self.canJump
end
function Player:hasCollisions()
	return self.numColls > 0
end
function Player:setRightMove(x, y)
	self.rightForces.x = x
	self.rightForces.y = y
end
function Player:setLeftMove(x, y)
	self.leftForces.x = x
	self.leftForces.y = y
end
function Player:setJump(x, y)
	self.jumpForces.x = x
	self.jumpForces.y = y
end
return Player