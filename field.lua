Field = {}
tileSize = 32
function Field:new(world, x, y, w, h, userData)
	body = love.physics.newBody(world, x+(w/2), y+(h/2))
	shape = love.physics.newRectangleShape(w, h)
	fixture = love.physics.newFixture(body, shape)
	fixture:setUserData(userData)
	fixture:setCategory(7)
	f = {
		body = body,
		shape = shape,
		fixture = fixture
	}
	setmetatable(f, {__index = Field})
	return f
end

function Field:getGridCoords()
	c = {
		x = math.ceil((self.body:getX()-(tileSize/2)) / tileSize) + 1,
		y = math.ceil((self.body:getY()-(tileSize/2)) / tileSize) + 1
	}
	return c
end
return Field
