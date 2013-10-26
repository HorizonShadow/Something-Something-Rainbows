Player = {}
tileSize = 32
moveLeft = {x = -400, y = 0}
moveRight = {x = 400, y = 0}
jump = {x = 0, y = -100}

function Player:new(world, x, y)
	body = love.physics.newBody(world, x, y, "dynamic")
	shape = love.physics.newRectangleShape(tileSize,tileSize)
	fixture = love.physics.newFixture(body, shape, 1)
	fixture:setRestitution(0.1)
	fixture:setFriction(0.1)
	fixture:setUserData("Player")
	fixture:setMask(7)
	fixture:setCategory(8)
	local p = {
		body = body,
		shape = shape,
		fixture = fixture,
	}
	setmetatable(p, {__index = Player})
	return p
end
function Player:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill", self.body:getX(), self.body:getY(), tileSize , tileSize)
	love.graphics.setColor(love.graphics.getBackgroundColor())
end
function Player:moveLeft()
	self.body:applyForce(moveLeft.x, moveLeft.y)
end
function Player:moveRight()
	self.body:applyForce(moveRight.x, moveRight.y)
end
function Player:jump()
	self.body:applyLinearImpulse(jump.x, jump.y)
end
function Player:getGridCoords()
	c = {
		x = math.ceil((self.body:getX()-(tileSize/2)) / tileSize) + 1,
		y = math.ceil((self.body:getY()-(tileSize/2)) / tileSize) + 1
	}
	return c
end
function Player:setControls(s)
	if s == "red" then
		setRightMove(400,0)
		setLeftMove(-400,0)
		setJump(0,100)
	elseif s == "orange" then
		setRightMove(0,400)
		setLeftMove(0,-400)
		setJump(-100,0)
	end
end
function setRightMove(x, y)
	moveRight.x = x
	moveRight.y = y
end
function setLeftMove(x, y)
	moveLeft.x = x
	moveLeft.y = y
end
function setJump(x, y)
	jump.x = x
	jump.y = y
end
return Player