Tanker = GameObject:extend()

function Tanker:new(area, x, y, opts)
    Tanker.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(16, gh - 16)
    
    self.w, self.h = 32, 32
    self.shape = HC.polygon(unpack(createIrregularPolygon(32)))
    self.shape.id = self.id
    self.shape:moveTo(self.x, self.y)
    self.shape.object = self
    self.shape.tag = 'Enemy'

    self.v = -direction*random(20, 40)
    self.vx = self.v
    self.dr = random(-10, 10)

    self.hp = 1600*current_room.director.enemy_hp_multiplier
end

function Tanker:update(dt)
    Tanker.super.update(self, dt)

    self:enemyProjectileCollisions()

    self.shape:move(self.vx*dt, 0)
    self.shape:rotate(self.dr*dt)
    self.x, self.y = self.shape:center()
end

function Tanker:draw()
    love.graphics.setColor(hp_color)
    if self.hit_flash then love.graphics.setColor(default_color) end
    self.shape:draw('line')
    love.graphics.setColor(default_color)
end

function Tanker:hit(damage)
    if self.dead then return end

    self.hp = self.hp - (damage or 100)
    if self.hp <= 0 then
        playGameEnemyDie()
        current_room.score = current_room.score + 1000
        self.dead = true
        if not current_room.player.no_ammo_drop then self.area:addGameObject('Ammo', self.x, self.y) end
        for i = 1, 4 do self.area:addGameObject('BigRock', 0, 0, {x = self.x + random(-32, 32), y = self.y + random(-32, 32), direction = -sign(self.v)}) end
    else
        self.hit_flash = true
        self.timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
    end
end
