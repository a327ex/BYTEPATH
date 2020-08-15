Ammo = GameObject:extend()

function Ammo:new(area, x, y, opts)
    Ammo.super.new(self, area, x, y, opts)

    self.w, self.h = 8, 8
    self.shape = HC.rectangle(self.x, self.y, self.w, self.h)
    self.shape.object = self
    self.shape.id = self.id
    self.shape.tag = 'Collectable'

    self.r = random(0, 2*math.pi)
    self.v = random(10, 20)
    self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r)
end

function Ammo:update(dt)
    Ammo.super.update(self, dt)

    self.target = current_room.player
    if self.target and self.target.dead then self.target = nil end
    if self.target then
        local projectile_heading_x, projectile_heading_y = Vector.normalize(self.vx, self.vy)
        local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
        local to_target_heading_x, to_target_heading_y = Vector.normalize(math.cos(angle), math.sin(angle))
        local final_heading_x, final_heading_y = Vector.normalize(projectile_heading_x + 0.1*current_room.player.pspd_multiplier.value*to_target_heading_x, 
        projectile_heading_y + 0.1*current_room.player.pspd_multiplier.value*to_target_heading_y)
        self.vx, self.vy = self.v*final_heading_x, self.v*final_heading_y
    else self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r) end

    self.r = Vector.angle(self.vx, self.vy)
    self.shape:move(self.vx*dt, self.vy*dt)
    self.shape:setRotation(self.r)
    self.x, self.y = self.shape:center()
end

function Ammo:draw()
    love.graphics.setColor(ammo_color)
    pushRotate(self.x, self.y, self.r)
    draft:rhombus(self.x, self.y, self.w, self.h, 'line')
    love.graphics.pop()
    love.graphics.setColor(default_color)
end

function Ammo:destroy()
    Ammo.super.destroy(self)
end

function Ammo:die()
    self.dead = true
    for i = 1, love.math.random(4, 8) do self.area.room.explode_particles:add(self.x, self.y, nil, 3, ammo_color) end
    self.area:addGameObject('AmmoEffect', self.x, self.y, {color = ammo_color, w = self.w, h = self.h})
end
