Attack = GameObject:extend()

function Attack:new(area, x, y, opts)
    Attack.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(16, gh - 16)

    self.w, self.h = 10, 10
    self.shape = HC.rectangle(self.x, self.y, self.w, self.h)
    self.shape.object = self
    self.shape.id = self.id
    self.shape.tag = 'Collectable'

    self.v = -direction*random(20, 40)
    self.vx = self.v
    self.dr = random(-10, 10)

    self.font = fonts.m5x7_16

    local player = current_room.player
    self.attack = chanceList(
        {'Double', 10 + player.double_spawn_chance}, {'Triple', 10 + player.triple_spawn_chance}, {'Rapid', 10 + player.rapid_spawn_chance}, 
        {'Spread', 10 + player.spread_spawn_chance}, {'Back', 10 + player.back_spawn_chance}, {'Side', 10 + player.side_spawn_chance}, 
        {'Homing', 10 + player.homing_spawn_chance}, {'Blast', 10 + player.blast_spawn_chance}, {'Spin', 10 + player.spin_spawn_chance}, 
        {'Bounce', 10 + player.bounce_spawn_chance}, {'Lightning', 10 + player.lightning_spawn_chance}, {'Flame', 10 + player.flame_spawn_chance},
        {'2Split', 10 + player.twosplit_spawn_chance}, {'4Split', 10 + player.foursplit_spawn_chance}, {'Explode', 10 + player.explode_spawn_chance}, 
        {'Laser', 10 + player.laser_spawn_chance}
    ):next()
end

function Attack:update(dt)
    Attack.super.update(self, dt)

    self.shape:move(self.vx*dt, 0)
    self.shape:rotate(self.dr*dt)
    self.x, self.y = self.shape:center()
end

function Attack:draw()
    pushRotateScale(self.x, self.y, 0, random(0.95, 1.05), random(0.95, 1.05))
    love.graphics.setColor(attacks[self.attack].color)
    if self.attack == 'Spread' or self.attack == 'Rapid' then love.graphics.setColor(table.random(all_colors)) end
    if self.attack == 'Bounce' then love.graphics.setColor(table.random(default_colors)) end
    love.graphics.print(attacks[self.attack].abbreviation, self.x, self.y, 0, 1, 1, math.floor(self.font:getWidth(attacks[self.attack].abbreviation)/2), math.floor(self.font:getHeight()/2))
    draft:rhombus(self.x, self.y, 3*self.w, 3*self.w, 'line')
    love.graphics.setColor(default_color)
    draft:rhombus(self.x, self.y, 2.5*self.w, 2.5*self.w, 'line')
    love.graphics.pop()
end

function Attack:destroy()
    Attack.super.destroy(self)
end

function Attack:die()
    self.dead = true
    self.area:addGameObject('AttackEffect', self.x, self.y, {color = default_color, w = 1.1*self.w, h = 1.1*self.h}) 
    if self.attack == 'Spread' then self.area:addGameObject('AttackEffect', self.x, self.y, {color = table.random(all_colors), w = 1.3*self.w, h = 1.3*self.h}) 
    else self.area:addGameObject('AttackEffect', self.x, self.y, {color = attacks[self.attack].color, w = 1.3*self.w, h = 1.3*self.h}) end
    self.area:addGameObject('InfoText', self.x + table.random({-1, 1})*self.w, self.y + table.random({-1, 1})*self.h, {color = default_color, text = self.attack})
end
