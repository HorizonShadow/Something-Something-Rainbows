Field = {}
function Field:new(world, x, y, w, h, userData)
	body = love.physics.newBody(world, x, y)
	shape = love.physics.newRectangleShape(w, h)
	fixture = love.physics.newFixture(body, shape)
	fixture:setUserData(userData)
	fixture:setMask(8)
	fixture:setCategory(7)
	f = {
		body = body,
		shape = shape,
		fixture = fixture
	}
	setmetatable(f, {__index = Field})
	return f
end
return Field
