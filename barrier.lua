Barrier = {}
tileSize = 32
function Barrier:new(world, x, y, w, h, userData)
	body = love.physics.newBody(world, x, y, "static")
	shape = love.physics.newRectangleShape(w, h)
	fixture = love.physics.newFixture(body, shape)
	fixture:setUserData(userData)
	w = {
		body = body,
		shape = shape,
		fixture = fixture
	}
	setmetatable(w, {__index = Barrier})
	return w
end

function Barrier:draw()
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", self.body:getX(), self.body:getY(), 32,32)
end
return Barrier