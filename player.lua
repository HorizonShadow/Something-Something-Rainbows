Player = {}
tileSize = 32
moveLeft = -400
moveRight = 400
jump = -100

function Player:new(world, x, y, w, h)
	body = love.physics.newBody(world, x, y, "dynamic")
	shape = love.physics.newRectangleShape(w, h)
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
	self.body:applyForce(moveLeft,0)
end
function Player:moveRight()
	self.body:applyForce(moveRight,0)
end
function Player:jump()
	self.body:applyLinearImpulse(0,jump)
end
return Player