Triad = GameObject:extend()

function Triad:new(area, x, y, opts)
    Triad.super.new(self, area, x, y, opts)

    self.direction = opts.direction or table.random({-1, 1})
    self.x = opts.x or (gw/2 + self.direction*(gw/2 + 48))
    self.y = opts.y or (random(16, gh - 16))

    self.w, self.h = 32, math.sqrt(32*32 - 16*16)
    self.shape = HC.polygon(0, -self.h/2, self.w/2, self.h/2, -self.w/2, self.h/2)
    self.shape.id = self.id
    self.shape:moveTo(self.x, self.y)
    self.shape.object = self
    self.shape.tag = 'Enemy'

    self.v = -self.direction*random(10, 20)
    self.vx = self.v
    self.dr = random(-20, 20)

    self.angv = random(-10, 10)
    self.hp = 600*current_room.director.enemy_hp_multiplier

    self.timer:every(random(10, 14), function()
        self.timer:tween(0.5, self, {angv = 0, v = 0}, 'in-out-cubic', function()
            self.immune = true
            self.timer:tween(1.5, self, {angv = random(-10, 10)}, 'in-out-cubic') 
            self.timer:after(0.5, function()
                self.timer:every(0.02, function()
                    local angle = self.angv
                    self.area:addGameObject('EnemyProjectile', self.x + self.h*math.cos(-math.pi/2 + angle), self.y + self.h*math.sin(-math.pi/2 + angle), {r = -math.pi/2 + angle})
                    self.area:addGameObject('EnemyProjectile', self.x + self.h*math.cos(math.pi/4 + angle), self.y + self.h*math.sin(math.pi/4 + angle), {r = math.pi/4 + angle})
                    self.area:addGameObject('EnemyProjectile', self.x + self.h*math.cos(3*math.pi/4 + angle), self.y + self.h*math.sin(3*math.pi/4 + angle), {r = 3*math.pi/4 + angle})
                end, 50)
                self.timer:after(1, function()
                    self.immune = false
                    self.timer:tween(0.5, self, {angv = random(-0.5, 0.5), v = -self.direction*random(10, 20)}, 'in-out-cubic')
                end)
            end)
        end)
    end)
end

function Triad:update(dt)
    Triad.super.update(self, dt)

    self:enemyProjectileCollisions()

    self.shape:move(self.vx*dt, 0)
    if self.immune then self.shape:setRotation(self.angv)
    else self.shape:rotate(self.angv*dt) end
    self.x, self.y = self.shape:center()
end

function Triad:draw()
    love.graphics.setColor(hp_color)
    if self.hit_flash then love.graphics.setColor(default_color) end
    if self.immune then love.graphics.setColor(default_color) end
    self.shape:draw('line')
    love.graphics.setColor(default_color)
end

function Triad:hit(damage)
    if self.dead then return end
    if self.immune then return end

    self.hp = self.hp - (damage or 100)
    if self.hp <= 0 then
        playGameEnemyDie()
        current_room.score = current_room.score + 100
        self.dead = true
        if not current_room.player.no_ammo_drop then self.area:addGameObject('Ammo', self.x, self.y) end
        self.area:addGameObject('EnemyDeathEffect', self.x, self.y, {color = hp_color, w = 1.5*self.w})
    else
        self.hit_flash = true
        self.timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
    end
end
