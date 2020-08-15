Explosion = GameObject:extend()

function Explosion:new(area, x, y, opts)
    Explosion.super.new(self, area, x, y, opts)
    
    playGameExplosion()

    self.w = 16
    self.color = opts.color or {255, 255, 255}
    local w = opts.w or random(48, 56)
    if current_room.player.projectiles_explosions then
        self.timer:tween(0.1, self, {w = w*current_room.player.area_multiplier}, 'in-out-cubic', function()
            camera:shake(w/24, 60, (w/48)*0.4)
            for i = 1, love.math.random(8, 12) do 
                current_room.explode_particles:add(self.x, self.y, (w/48)*random(150, 300), random(6, 10), attacks[current_room.player.attack].color)
            end
            self.timer:tween(0.20, self, {w = 0}, 'in-out-cubic', function() self.dead = true end)
        end)

        for i = 1, 4 do
            self.timer:after((i-1)*0.05, function()
                local random_angle = random(0, 2*math.pi)
                if current_room.player.attack == 'Explode' then self.area:addGameObject('Projectile', self.x + math.cos(random_angle), self.y + math.sin(random_angle), {r = random_angle, attack = 'Neutral'})
                else 
                    self.area:addGameObject('Projectile', self.x + math.cos(random_angle), self.y + math.sin(random_angle), 
                    {r = random_angle, attack = current_room.player.attack, dont_explode = self.from_explode_on_expiration}) 
                end
            end)
        end
    else
        self.timer:tween(0.1, self, {w = w*current_room.player.area_multiplier}, 'in-out-cubic', function()
            camera:shake(w/48, 60, (w/48)*0.4)
            for i = 1, love.math.random(8, 12) do current_room.explode_particles:add(self.x, self.y, (w/48)*random(150, 300), random(6, 10), self.color) end
            self.timer:tween(0.20, self, {w = 0}, 'in-out-cubic', function() self.dead = true end)
        end)

        local objects = self.area.enemies
        for i, object in ipairs(objects) do 
            if distance(object.x, object.y, self.x, self.y) < (opts.w or 48)*current_room.player.area_multiplier then
                self.timer:after((i-1)*0.025, function() 
                    if object.hit then object:hit(200*(self.damage_multiplier or 1))  
                    else object:die() end
                end)
            end
        end
    end

    self.current_color = default_color
    self.timer:after(opts.d1 or 0.1, function()
        self.current_color = self.color
        self.timer:after(opts.d2 or 0.2, function()
            self.dead = true
        end)
    end)

    self.area:addGameObject('ShockwaveDisplacement', self.x, self.y, {wm = (screen_shake/10)*w/48})
    current_room:glitch(self.x, self.y, w, w)
end

function Explosion:update(dt)
    Explosion.super.update(self, dt)
end

function Explosion:draw()
    if current_room.player.projectiles_explosions then return end
    love.graphics.setColor(self.current_color)
    love.graphics.rectangle('fill', self.x - self.w/2, self.y - self.w/2, self.w, self.w)
    love.graphics.setColor(255, 255, 255)
end

function Explosion:destroy()
    Explosion.super.destroy(self)
end
