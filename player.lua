Player = {}
tileSize = 32
local force = 400
function Player:new(world, x, y)

	body = love.physics.newBody(world, x, y, "dynamic")
	shape = love.physics.newRectangleShape(32,32)
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
	love.graphics.rectangle("fill", self.body:getX(), self.body:getY(), 32, 32)
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
		x = math.ceil((self.body:getX()-(tileSize/2)) / tileSize) + 1,
		y = math.ceil((self.body:getY()-(tileSize/2)) / tileSize) + 1
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
	end
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
	if yDir < 0 then 
		status = ny > 28
	elseif yDir > 0 then status = ny < -28
	elseif xDir < 0 then status = nx > 28
	elseif xDir > 0 then status = ny < -28
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