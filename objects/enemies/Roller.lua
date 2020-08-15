Roller = GameObject:extend()

function Roller:new(area, x, y, opts)
    Roller.super.new(self, area, x, y, opts)

    local direction = opts.direction or table.random({-1, 1})
    self.x = opts.x or (random(16, gw - 16))
    self.y = opts.y or (gh/2 + direction*(gh/2 + 48))

    self.w, self.h = 10, 10
    self.shape = HC.circle(self.x, self.y, self.w)
    self.shape.id = self.id
    self.shape.object = self
    self.shape.tag = 'Enemy'

    self.v = -direction*random(20, 40)
    self.vy = self.v
    self.dr = random(-10, 10)

    self.hp = 200*current_room.director.enemy_hp_multiplier
    self.timer:every(0.4, function() self.area:addGameObject('RollerPool', self.x, self.y) end)
end

function Roller:update(dt)
    Roller.super.update(self, dt)

    self:enemyProjectileCollisions()

    self.shape:move(0, self.vy*dt)
    self.shape:rotate(self.dr*dt)
    self.x, self.y = self.shape:center()
end

function Roller:draw()
    love.graphics.setColor(hp_color)
    if self.hit_flash then love.graphics.setColor(default_color) end
    self.shape:draw('line')
    love.graphics.setColor(default_color)
end

function Roller:hit(damage)
    if self.dead then return end

    self.hp = self.hp - (damage or 100)
    if self.hp <= 0 then
        playGameEnemyDie()
        current_room.score = current_room.score + 100
        self.dead = true
        if not current_room.player.no_ammo_drop then self.area:addGameObject('Ammo', self.x, self.y) end
        self.area:addGameObject('EnemyDeathEffect', self.x, self.y, {color = hp_color, w = 3*self.w})
    else
        self.hit_flash = true
        self.timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
    end
end
