Barrier = {}
tileSize = 32
function Barrier:new(world, x, y, w, h, userData)
	body = love.physics.newBody(world, x, y)
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
return Barrier