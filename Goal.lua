Goal = {}
function Goal:new(world, x, y, w, h, userData)
	body = love.physics.newBody(world, x+(w/2), y+(h/2))
	shape = love.physics.newRectangleShape(w, h)
	fixture = love.physics.newFixture(body, shape)
	fixture:setUserData(userData)
	g = {
		body = body,
		shape = shape,
		fixture = fixture
	}
	setmetatable(g, {__index = Goal})
	return g
end
return Goal