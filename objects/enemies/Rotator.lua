Rotator = GameObject:extend()

function Rotator:new(area, x, y, opts)
    Rotator.super.new(self, area, x, y, opts)

    local direction = opts.direction or table.random({-1, 1})
    self.x = opts.x or (gw/2 + direction*(gw/2 + 80))
    self.y = opts.y or (random(16, gh - 16))

    self.parts = {}
    for i = 1, 5 do self.parts[i] = self.area:addGameObject('RotatorPart', self.x + (i-1)*16, self.y, {center = (i == 1), direction = direction, rotator = self}) end
    self.joints = {}
    self:link(self.parts[1], self.parts[2], self.x + 8 + 16*0, self.y)
    self:link(self.parts[2], self.parts[3], self.x + 8 + 16*1, self.y)
    self:link(self.parts[3], self.parts[4], self.x + 8 + 16*2, self.y)
    self:link(self.parts[4], self.parts[5], self.x + 8 + 16*3, self.y)
end

function Rotator:update(dt)
    Rotator.super.update(self, dt)
end

function Rotator:draw()

end

function Rotator:link(a, b, x, y)
    table.insert(self.joints, self.area.world:addJoint('RevoluteJoint', a.collider, b.collider, x, y, true))
end

function Rotator:unlink()
    for _, part in ipairs(self.parts) do part:setImmune(false); part.rotator = nil end
    for _, joint in ipairs(self.joints) do self.area.world:removeJoint(joint) end
    self.joints = {}
    self.parts = {}
    self.dead = true
end
