Player = {}
tileSize = 32
local force = 110
local jumpForce = 30
function Player:new(world, x, y)

	body = love.physics.newBody(world, x, y, "dynamic")
	shape = love.physics.newRectangleShape(16,16)
	fixture = love.physics.newFixture(body, shape, 1)
	fixture:setRestitution(0.0)
	fixture:setFriction(0.1)
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
		canJump = true
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
	if(self.canJump) then 
		self.canJump = false
		self.body:applyLinearImpulse(self.jumpForces.x, self.jumpForces.y)
	end
end
function Player:getGridCoords()
	local c = {
		x = math.ceil((self.body:getX()-(16/2)) / tileSize) + 1,
		y = math.ceil((self.body:getY()-(16/2)) / tileSize) + 1
	}
	return c
end
function Player:setControls(s)
	if s == "red" then
		self:setRightMove(force,0)
		self:setLeftMove(-force,0)
		self:setJump(0,jumpForce)
	elseif s == "orange" then
		self:setRightMove(0,-force)
		self:setLeftMove(0,force)
		self:setJump(-jumpForce,0)
	elseif s == "yellow" then
		self:setRightMove(0, force)
		self:setLeftMove(0, -force)
		self:setJump(jumpForce, 0)
	elseif s == "green" then
		self:setRightMove(force, 0)
		self:setLeftMove(-force, 0)
		self:setJump(0, -jumpForce)
	elseif s == "violet" then
		self:setRightMove(-force, 0)
		self:setLeftMove(force, 0)
		self:setJump(0, -jumpForce)
	elseif s == "indigo" then
		self.fixture:setRestitution(1)
	elseif s== "blue" then
		self.fixture:setDensity(0)
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
function Player:onGround(a, b)
	local x,y = nil, nil
	if(a:getUserData() == "Player") then
		x, y = a, b
	else
		x, y = b, a
	end
	local xDir = getSign(self.jumpForces.x)
	local yDir = getSign(self.jumpForces.y)
	local playerX, playerY = x:getBody():getX(), x:getBody():getY()
	local floorX, floorY = y:getBody():getX(), y:getBody():getY()
	local gPX, gPY = math.ceil((playerX-(16/2))/tileSize) + 1, math.ceil((playerY-(16/2))/tileSize)+1
	local fPX, fPY = math.ceil((floorX-(32/2))/tileSize) + 1, math.ceil((floorY - (32/2))/tileSize)+1
	if yDir == -1 then status = playerY < floorY and gPX == fPX end --If gravity is pushing down
	if yDir == 1 then status = playerY > floorY and gPX == fPX end --if gravity is pushing up
	if xDir == 1 then status = playerX > floorX and gPY == fPY end --if gravity is pushing to the left
	if xDir == -1 then status = playerX < floorX and gPY == fPY end -- if gravity is pushing to the right	
	return status
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