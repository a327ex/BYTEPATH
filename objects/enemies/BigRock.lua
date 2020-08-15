BigRock = GameObject:extend()

function BigRock:new(area, x, y, opts)
    BigRock.super.new(self, area, x, y, opts)

    local direction = opts.direction or table.random({-1, 1})
    self.x = opts.x or gw/2 + direction*(gw/2 + 48)
    self.y = opts.y or random(16, gh - 16)

    self.w, self.h = 16, 16

    self.shape = HC.polygon(unpack(createIrregularPolygon(16)))
    self.shape:moveTo(self.x, self.y)
    self.shape.id = self.id
    self.shape.object = self
    self.shape.tag = 'Enemy'

    self.v = -direction*random(20, 40)
    self.vx = self.v
    self.dr = random(-10, 10)

    self.hp = 300*current_room.director.enemy_hp_multiplier
end

function BigRock:update(dt)
    BigRock.super.update(self, dt)

    self:enemyProjectileCollisions()

    self.shape:move(self.vx*dt, 0)
    self.shape:rotate(self.dr*dt)
    self.x, self.y = self.shape:center()
end

function BigRock:draw()
    love.graphics.setColor(hp_color)
    if self.hit_flash then love.graphics.setColor(default_color) end
    self.shape:draw('line')
    love.graphics.setColor(default_color)
end

function BigRock:destroy()
    BigRock.super.destroy(self)
end

function BigRock:hit(damage)
    if self.dead then return end

    self.hp = self.hp - (damage or 100)
    if self.hp <= 0 then
        playGameEnemyDie()
        current_room.score = current_room.score + 200
        self.dead = true
        if not current_room.player.no_ammo_drop then self.area:addGameObject('Ammo', self.x, self.y) end
        for i = 1, 4 do self.area:addGameObject('Rock', 0, 0, {x = self.x + random(-16, 16), y = self.y + random(-16, 16), direction = -sign(self.v)}) end
    else
        self.hit_flash = true
        self.timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
    end
end
