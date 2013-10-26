Player = {}
tileSize = 32
local force = 110
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
		jumpForces = {x = 0, y = -force/2},
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
		self:setJump(0,force/2)
	elseif s == "orange" then
		self:setRightMove(0,force)
		self:setLeftMove(0,-force)
		self:setJump(-force/2,0)
	elseif s == "yellow" then
		self:setRightMove(0, -force)
		self:setLeftMove(0, force)
		self:setJump(force/2, 0)
	elseif s == "green" then
		self:setRightMove(force, 0)
		self:setLeftMove(-force, 0)
		self:setJump(0, -force/2)
	elseif s == "violet" then
		self:setRightMove(-force, 0)
		self:setLeftMove(force, 0)
		self:setJump(0, -force/2)
	elseif s == "indigo" then
		self.fixture:setRestitution(1-self.fixture:getRestitution())
	elseif s== "blue" then
		self.fixture:setDensity(1-self.fixture:getDensity())
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
function Player:onGround(nx, ny)
	local status = false
	local xDir = math.abs(self.jumpForces.x) / self.jumpForces.x 
	local yDir = math.abs(self.jumpForces.y) / self.jumpForces.y
	print (ny, nx)
	if yDir < 0 then status = ny > 28
	elseif yDir > 0 then status = ny < -28
	elseif xDir > 0 then status = nx > 28
	elseif xDir < 0 then status = nx < -28
	end
	return status
end
function Player:againstWall(nx, ny)
	local status = false
	local xDir = math.abs(self.rightForces.x) / self.rightForces.x
	local yDir = math.abs(self.rightForces.y) / self.rightForces.y
	status = nx == 32 or nx == -32 or ny == 32 or ny == -32
	return status
end
function Player:setCanJump(x)
	self.canJump = x
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