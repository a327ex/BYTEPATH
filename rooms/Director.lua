Director = Object:extend()

function Director:new(stage, starting_difficulty)
    self.stage = stage
    self.timer = Timer()

    self.difficulty = starting_difficulty or 1
    self.round_duration = 22
    self.round_timer = 0
    self.resource_duration = 16
    self.resource_timer = 0
    self.attack_duration = 30
    self.attack_timer = 0
    self.item_duration = 62
    self.item_timer = 0

    self.difficulty_to_points = {}
    self.difficulty_to_points[1] = 16
    self.difficulty_to_points[2] = 24
    self.difficulty_to_points[3] = 24
    self.difficulty_to_points[4] = 16
    self.difficulty_to_points[5] = 32
    self.difficulty_to_points[6] = 40
    self.difficulty_to_points[7] = 40 
    self.difficulty_to_points[8] = 26
    self.difficulty_to_points[9] = 52
    self.difficulty_to_points[10] = 60
    self.difficulty_to_points[11] = 60 
    self.difficulty_to_points[12] = 52
    self.difficulty_to_points[13] = 78
    self.difficulty_to_points[14] = 70
    self.difficulty_to_points[15] = 70 
    self.difficulty_to_points[16] = 62 
    self.difficulty_to_points[17] = 98
    self.difficulty_to_points[18] = 98 
    self.difficulty_to_points[19] = 90 
    self.difficulty_to_points[20] = 108
    self.difficulty_to_points[21] = 128
    self.difficulty_to_points[22] = 72 
    self.difficulty_to_points[23] = 80
    self.difficulty_to_points[24] = 140 
    self.difficulty_to_points[25] = 92
    self.difficulty_to_points[26] = 128
    self.difficulty_to_points[27] = 86
    self.difficulty_to_points[28] = 94 
    self.difficulty_to_points[29] = 142
    self.difficulty_to_points[30] = 88
    self.difficulty_to_points[31] = 96
    self.difficulty_to_points[32] = 104 
    self.difficulty_to_points[33] = 112 
    self.difficulty_to_points[34] = 142
    self.difficulty_to_points[35] = 158
    self.difficulty_to_points[36] = 178
    self.difficulty_to_points[37] = 128
    self.difficulty_to_points[38] = 96
    self.difficulty_to_points[39] = 160
    for i = 40, 2048 do self.difficulty_to_points[i] = 160 + 2*i end
    self.enemy_hp_multiplier = 1 

    self.enemy_to_points = {
        ['Rock'] = 1,
        ['BigRock'] = 2,
        ['Shooter'] = 2,
        ['Sapper'] = 4,
        ['Waver'] = 4,
        ['Roller'] = 6,
        ['Rotator'] = 6,
        ['Tanker'] = 6,
        ['Seeker'] = 6,
        ['Triad'] = 8,
        ['Trailer'] = 8,
        ['Orbitter'] = 12,
        ['Reflecteer'] = 12,
        ['Glitcher'] = 16,
    }

    self.enemy_spawn_chances = {
        [1] = chanceList({'Rock', 1}),
        [2] = chanceList({'Rock', 8}, {'BigRock', 4}),
        [3] = chanceList({'Rock', 7}, {'BigRock', 3}, {'Shooter', 3}),
        [4] = chanceList({'Rock', 6}, {'BigRock', 3}, {'Shooter', 3}, {'Seeker', 3}),
        [5] = chanceList({'Rock', 5}, {'BigRock', 3}, {'Shooter', 3}, {'Waver', 4}),
        [6] = chanceList({'Rock', 4}, {'BigRock', 4}, {'Seeker', 1}, {'Waver', 1}),
        [7] = chanceList({'Rock', 4}, {'BigRock', 3}, {'Shooter', 3}, {'Seeker', 2}, {'Waver', 2}, {'Roller', 2}),
        [8] = chanceList({'Rock', 4}, {'BigRock', 3}, {'Shooter', 3}, {'Seeker', 2}, {'Waver', 2}),
        [9] = chanceList({'Rock', 4}, {'BigRock', 4}, {'Shooter', 2}, {'Sapper', 2}),
        [10] = chanceList({'Rock', 4}, {'BigRock', 4}, {'Shooter', 4}), --{'Rotator', 2}),
        [11] = chanceList({'Rock', 6}, {'BigRock', 6}, {'Tanker', 2}),
        [12] = chanceList({'Rock', 4}, {'BigRock', 4}, {'Shooter', 4}, {'Seeker', 4}, {'Waver', 4}),
        [13] = chanceList({'Rock', 4}, {'BigRock', 4}, {'Triad', 1}),
        [14] = chanceList({'Rock', 2}, {'BigRock', 2}, {'Shooter', 2}, {'Waver', 2}, {'Tanker', 2}, {'Trailer', 4}),
        [15] = chanceList({'Rock', 4}, {'BigRock', 4}, {'Tanker', 4}),
        [16] = chanceList({'Rock', 4}, {'BigRock', 2}, {'Shooter', 2}), --{'Rotator', 2}),
        [17] = chanceList({'Rock', 4}, {'BigRock', 4}, {'Shooter', 3}, {'Orbitter', 4}),
        [18] = chanceList({'Rock', 4}, {'BigRock', 4}, {'Shooter', 3}, {'Reflecteer', 2}),
        [19] = chanceList({'Rock', 4}, {'BigRock', 4}, {'Shooter', 3}, {'Glitcher', 2}),
        [20] = chanceList({'Tanker', 1}),
    }
    for i = 21, 1024 do 
        self.enemy_spawn_chances[i] = chanceList({'Rock', love.math.random(2, 12)}, {'BigRock', love.math.random(2, 12)}, {'Shooter', love.math.random(2, 12)}, {'Sapper', love.math.random(2, 12)}, 
        {'Roller', love.math.random(2, 12)}, {'Seeker', love.math.random(2, 12)}, {'Waver', love.math.random(2, 12)}, --[[{'Rotator', love.math.random(2, 12)},]] {'Tanker', love.math.random(2, 12)},
        {'Triad', love.math.random(2, 6)}, {'Trailer', love.math.random(2, 12)}, {'Reflecteer', love.math.random(2, 12)}, {'Orbitter', love.math.random(2, 12)}, {'Glitcher', love.math.random(2, 6)}) 
    end

    local first_10_runs_sp_spawn_chance_multiplier = 1
    if run <= 15 then first_10_runs_sp_spawn_chance_multiplier = 1 + (15 - run)/5 end
    self.resource_spawn_chances = chanceList({'Boost', 28*self.stage.player.boost_spawn_chance_multiplier}, 
    {'HP', 14*self.stage.player.hp_spawn_chance_multiplier}, {'SkillPoint', 92*self.stage.player.sp_spawn_chance_multiplier*first_10_runs_sp_spawn_chance_multiplier})

    self.first_10_runs_resource_spawn_rate = 0
    if run <= 15 then self.first_10_runs_resource_spawn_rate = (15 - run)/15 end

    self.first_10_runs_item_spawn_rate = 0
    if run <= 15 then self.first_10_runs_item_spawn_rate = (15 - run)/15 end

    -- Adaptive difficulty
    self.adaptive_difficulty_enemy_spawn_rate_multiplier = 1 

    self:setEnemySpawnsForThisRound()
    self.timer:after(1, function() 
        self.stage.area:addGameObject('Attack') 
        self.stage.area:addGameObject('Item') 
    end)
    self.spawned_item_count = 0

    -- Spawn keys at the appropriate difficulties
    self.timer:every(1, function()
        for i = 1, 8 do
            if self.difficulty >= i*5 and self.difficulty < (i+1)*5 and found_keys[i] == 0 and not self.key then 
                self.key = self.stage.area:addGameObject('Key', 0, 0, {n = i}) 
            end
        end
    end)
end

function Director:update(dt)
    self.timer:update(dt)

    -- Set adaptive difficulty
    self.adaptive_difficulty_enemy_spawn_rate_multiplier = math.max(3*(self.stage.enemies_killed/self.stage.enemies_created)^4, 1)
    -- print(self.adaptive_difficulty_enemy_spawn_rate_multiplier)

    -- Difficulty
    self.round_timer = self.round_timer + dt
    if self.round_timer > self.round_duration/(self.stage.player.enemy_spawn_rate_multiplier*self.adaptive_difficulty_enemy_spawn_rate_multiplier) then
        self.round_timer = 0
        self.difficulty = self.difficulty + 1
        self:setEnemySpawnsForThisRound()
    end
    if self.key and self.key.dead then self.key = nil end
    if self.difficulty <= 40 then self.enemy_hp_multiplier = 1 
    else self.enemy_hp_multiplier = 1 + (self.difficulty*self.difficulty)/2400 end

    -- Resources
    self.resource_timer = self.resource_timer + dt
    if self.resource_timer > self.resource_duration/(self.stage.player.resource_spawn_rate_multiplier + self.first_10_runs_resource_spawn_rate) then
        self.resource_timer = 0

        if self.stage.player.only_spawn_attack then
            self.stage.area:addGameObject('Attack')
        else
            local resource = self.resource_spawn_chances:next()
            if self.stage.player.only_spawn_boost then resource = 'Boost' end
            self.stage.area:addGameObject(resource)

            if resource == 'HP' then
                if self.stage.player.chances.spawn_double_hp_chance:next() then
                    self.stage.area:addGameObject(resource)
                    self.stage.area:addGameObject('InfoText', self.stage.player.x, self.stage.player.y, {text = 'Double HP!', color = hp_color})
                end
            elseif resource == 'SkillPoint' then
                if self.stage.player.chances.spawn_double_sp_chance:next() then
                    self.stage.area:addGameObject(resource)
                    self.stage.area:addGameObject('InfoText', self.stage.player.x, self.stage.player.y, {text = 'Double SP!', color = skill_point_color})
                end
            end
        end
    end

    -- Attack
    self.attack_timer = self.attack_timer + dt
    if self.attack_timer > self.attack_duration/self.stage.player.attack_spawn_rate_multiplier then
        self.attack_timer = 0
        if self.stage.player.only_spawn_boost then self.stage.area:addGameObject('Boost')
        else self.stage.area:addGameObject('Attack') end
    end

    -- Item
    self.item_timer = self.item_timer + dt
    if self.item_timer > self.item_duration/(self.stage.player.luck_multiplier*self.stage.player.item_spawn_rate_multiplier + self.first_10_runs_item_spawn_rate) and 
       self.spawned_item_count <= math.floor(5*self.stage.player.item_spawn_rate_multiplier) then
        self.item_timer = 0
        self.stage.area:addGameObject('Item')
        self.spawned_item_count = self.spawned_item_count + 1
    end
end

function Director:setEnemySpawnsForThisRound()
    local points = self.difficulty_to_points[self.difficulty]

    -- Find enemies
    local runs = 0
    local enemy_list = {}
    while points > 0 and runs < 1000 do
        local enemy = self.enemy_spawn_chances[self.difficulty]:next()
        points = points - self.enemy_to_points[enemy]
        table.insert(enemy_list, enemy)
        runs = runs + 1
    end

    -- Find enemies spawn times
    local enemy_spawn_times = {}
    for i = 1, #enemy_list do enemy_spawn_times[i] = random(0, self.round_duration) end
    table.sort(enemy_spawn_times, function(a, b) return a < b end)

    -- Set spawn enemy timer
    for i = 1, #enemy_spawn_times do
        self.timer:after(enemy_spawn_times[i], function()
            self.stage.area:addGameObject(enemy_list[i], nil, nil, {difficulty = self.difficulty})
        end)
    end
end
