Waver = GameObject:extend()

function Waver:new(area, x, y, opts)
    Waver.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(16, gh - 16)

    self.w, self.h = 12, 6
    self.shape = HC.polygon(self.w, 0, 0, self.h, -self.w, 0, 0, -self.h)
    self.shape.id = self.id
    self.shape:moveTo(self.x, self.y)
    self.shape.object = self
    self.shape.tag = 'Enemy'

    self.v = random(90, 110)
    self.r = direction == 1 and math.pi or 0
    self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r)

    self.hp = 70*current_room.director.enemy_hp_multiplier

    -- Attack
    self.timer:every(random(2.2, 2.6), function()
        self.timer:every(0.25, function() self.area:addGameObject('WaverPreAttackEffect', self.x, self.y, {waver = self}) end, 3)
        self.timer:after(1, function()
            for i = 1, 4 do
                self.timer:after((i-1)*0.075, function()
                    self.area:addGameObject('EnemyProjectile', self.x + 1.4*self.w*math.cos(self.r), self.y + 1.4*self.w*math.sin(self.r), {r = self.r, v = random(140, 160)})
                    self.area:addGameObject('EnemyProjectile', self.x + 1.4*self.w*math.cos(self.r - math.pi), self.y + 1.4*self.w*math.sin(self.r - math.pi), {r = self.r - math.pi, v = random(140, 160)})
                end)
            end
        end)
    end)

    -- Waving
    local d = table.random({-1, 1})
    local m = random(1, 4)
    self.timer:tween(0.25, self, {r = self.r + m*d*math.pi/8}, 'linear', function()
        self.timer:tween(0.5, self, {r = self.r - m*d*math.pi/4}, 'linear')
    end)
    self.timer:every(0.75, function()
        self.timer:tween(0.25, self, {r = self.r + m*d*math.pi/4}, 'linear', function()
            self.timer:tween(0.5, self, {r = self.r - m*d*math.pi/4}, 'linear')
        end)
    end)
end

function Waver:update(dt)
    Waver.super.update(self, dt)

    self:enemyProjectileCollisions()

    self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r)
    self.shape:move(self.vx*dt, self.vy*dt)
    self.shape:setRotation(self.r)
    self.x, self.y = self.shape:center()
end

function Waver:draw()
    love.graphics.setColor(hp_color)
    if self.hit_flash then love.graphics.setColor(default_color) end
    self.shape:draw('line')
    love.graphics.setColor(default_color)
end

function Waver:destroy()
    Waver.super.destroy(self)
end

function Waver:hit(damage)
    if self.dead then return end

    self.hp = self.hp - (damage or 100)
    if self.hp <= 0 then
        playGameEnemyDie()
        current_room.score = current_room.score + 300
        self.dead = true
        if not current_room.player.no_ammo_drop then self.area:addGameObject('Ammo', self.x, self.y) end
        self.area:addGameObject('EnemyDeathEffect', self.x, self.y, {color = hp_color, w = 2.5*self.w})
    else
        self.hit_flash = true
        self.timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
    end
end
