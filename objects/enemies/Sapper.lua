Sapper = GameObject:extend()

function Sapper:new(area, x, y, opts)
    Sapper.super.new(self, area, x, y, opts)

    local direction = opts.direction or table.random({-1, 1})
    self.x = opts.x or (gw/2 + direction*(gw/2 + 48))
    self.y = opts.y or (random(16, gh - 16))

    self.w, self.h = 4, 4

    self.shape = HC.polygon(unpack(createIrregularPolygon(4)))
    self.shape.id = self.id
    self.shape:moveTo(self.x, self.y)
    self.shape.object = self
    self.shape.tag = 'Enemy'

    self.v = -direction*random(40, 60)
    self.r = direction == 1 and math.pi or 0
    self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r)
    self.dr = random(-10, 10)

    self.hp = 50*current_room.director.enemy_hp_multiplier 
    self.r = 0

    self.timer:every(0.1, function()
        if self.in_player_range then
            self.target = current_room.player
            local angle = Vector.angle(self.vx, self.vy) or 0
            self.area:addGameObject('LightningLine', 0, 0, {x1 = self.x + 4*math.cos(angle), y1 = self.y + 4*math.sin(angle), x2 = self.target.x, y2 = self.target.y, color = hp_color})
            for i = 1, love.math.random(1, 3) do self.area.room.explode_particles:add(self.x + 4*math.cos(angle), self.y + 4*math.sin(angle), nil, nil, table.random({default_color, hp_color})) end
            for i = 1, love.math.random(1, 3) do self.area.room.explode_particles:add(self.target.x, self.target.y, nil, nil, table.random({default_color, hp_color})) end
        end
    end)
end

function Sapper:update(dt)
    Sapper.super.update(self, dt)

    self:enemyProjectileCollisions()

    self.target = current_room.player
    if self.target and self.target.dead then self.target = nil end
    if self.target then
        local projectile_heading_x, projectile_heading_y = Vector.normalize(self.vx, self.vy)
        local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
        local to_target_heading_x, to_target_heading_y = Vector.normalize(math.cos(angle), math.sin(angle))
        local final_heading_x, final_heading_y = Vector.normalize(projectile_heading_x + 0.1*current_room.player.pspd_multiplier.value*to_target_heading_x, 
        projectile_heading_y + 0.1*current_room.player.pspd_multiplier.value*to_target_heading_y)
        self.vx, self.vy = self.v*final_heading_x, self.v*final_heading_y

        local d = distance(self.x, self.y, self.target.x, self.target.y)
        if d < 100 and not self.in_player_range then 
            self.in_player_range = true 
            self.target:insertSapper(self.id)
        elseif d >= 100 and self.in_player_range then
            self.in_player_range = false
            self.target:removeSapper(self.id)
        end
    else self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r) end

    self.shape:move(self.vx*dt, self.vy*dt)
    self.r = Vector.angle(self.vx, self.vy)
    self.shape:setRotation(self.r)
    self.x, self.y = self.shape:center()
end

function Sapper:draw()
    love.graphics.setColor(hp_color)
    if self.hit_flash then love.graphics.setColor(default_color) end
    self.shape:draw('line')
    love.graphics.setColor(default_color)
end

function Sapper:hit(damage)
    if self.dead then return end

    self.hp = self.hp - (damage or 100)
    if self.hp <= 0 then
        playGameEnemyDie()
        current_room.score = current_room.score + 100
        self.dead = true
        if not current_room.player.no_ammo_drop then self.area:addGameObject('Ammo', self.x, self.y) end
        self.area:addGameObject('EnemyDeathEffect', self.x, self.y, {color = hp_color, w = 3*self.w})
        current_room.player:removeSapper(self.id)
    else
        self.hit_flash = true
        self.timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
    end
end
