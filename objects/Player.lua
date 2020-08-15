Player = GameObject:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)

    -- This is only set to false when the player presses a key
    -- When it's true the ship won't move or shoot
    self.paused = true

    -- Movement
    self.r = -math.pi/2
    self.rv = 1.66*math.pi
    self.v = 0
    self.vx, self.vy = 0, 0
    self.base_max_v = 100
    self.max_v = self.base_max_v
    self.a = 100

    -- Cycle
    self.cycle_timer = 0
    self.cycle_cooldown = 5

    -- Boost
    self.max_boost = 100
    self.boost = self.max_boost
    self.boosting = false
    self.can_boost = true
    self.boost_timer = 0
    self.boost_cooldown = 2

    -- HP
    self.max_hp = 100
    self.hp = self.max_hp

    -- Ammo
    self.max_ammo = 100
    self.ammo = self.max_ammo
    self.protective_barrier = 0

    -- Attacks
    self.shoot_timer = 0
    self.shoot_cooldown = 0.24
    self:setAttack(opts.attack or 'Neutral')
    self.rampage_counter = 0
    self.rampage_timer = 0
    self.rampage_cooldown = 2.5
    self.damage_multiplier = 1

    -- ES
    self.energy_shield_recharge_cooldown = 2
    self.energy_shield_recharge_amount = 1

    -- Commented to the right of each stat are its maximum values from the tree alone.
    -- For stats that have both increases and decreases, the maximum/minimum of each is listed.
    -- i.e. The player can get +1.87 (=2.87) maximum ASPD multiplier or -0.72 (=0.28) minimum ASPD multiplier from the tree, meaning he can attack ~3 times as fast as normal or ~4 times as slow.

    -- Flats
    self.flat_hp = 0 -- 115 +185 -70
    self.flat_ammo = 0 -- 130 +200 -70
    self.flat_boost = 0 -- 250
    self.ammo_gain = 0 -- 2

    -- Limiters
    self.barrage_cooldown = 1
    self.barrage_timer = 0
    self.launch_homing_projectile_cooldown = 0.5
    self.launch_homing_projectile_timer = 0

    -- Multipliers
    self.hp_multiplier = 1 -- 4.46
    self.ammo_multiplier = 1 -- 2.38
    self.boost_multiplier = 1 -- 2.65
    self.aspd_multiplier = Stat(1) -- 2.15 +1.87 -0.72
    self.mvspd_multiplier = Stat(1) -- 1.24 +1.28 -1.04
    self.pspd_multiplier = Stat(1) -- 1.22 +1.79 -1.57
    self.cycle_multiplier = Stat(1) -- 3.06
    self.luck_multiplier = 1 -- 2.15
    self.enemy_spawn_rate_multiplier = 1 -- ????
    self.item_spawn_rate_multiplier = 1 -- 3.43
    self.hp_spawn_chance_multiplier = 1 -- 1.98
    self.sp_spawn_chance_multiplier = 1 --3.98
    self.boost_spawn_chance_multiplier = 1 -- 2.04
    self.resource_spawn_rate_multiplier = 1 -- 2.04
    self.attack_spawn_rate_multiplier = 1 -- 2.28
    self.turn_rate_multiplier = 1 -- 0.82 +0.66 -0.84
    self.boost_effectiveness_multiplier = 1 -- 2.1
    self.projectile_size_multiplier = 1 -- 2.28
    self.boost_recharge_rate_multiplier = 1 -- 2.22
    self.invulnerability_time_multiplier = 1 -- 1.64
    self.ammo_consumption_multiplier = 1 -- 1.58 +1 -0.42
    self.size_multiplier = 1 -- 1.5 +0.7 -0.2
    self.stat_boost_duration_multiplier = 1 -- 1.6
    self.projectile_angle_change_frequency_multiplier = 1 -- 2.2
    self.projectile_waviness_multiplier = 1 -- 2
    self.projectile_acceleration_multiplier = 1 -- 1.6
    self.projectile_deceleration_multiplier = 1 -- 1.6
    self.projectile_duration_multiplier = 1 -- 1.78 +1.34 -0.56
    self.area_multiplier = 1 -- 2.65
    self.laser_width_multiplier = 1 -- 2.1
    self.energy_shield_recharge_amount_multiplier = 1 -- 2.3 +1.6 -0.3
    self.energy_shield_recharge_cooldown_multiplier = 1 -- 3.02 +2.32 -0.3
    self.shield_projectile_damage_multiplier = 1
    self.homing_speed_multiplier = 1

    -- Chances
    self.regain_hp_on_item_pickup_chance = 0 -- 20
    self.regain_hp_on_sp_pickup_chance = 0 -- 10
    self.spawn_haste_area_on_hp_pickup_chance = 0 -- 20
    self.spawn_haste_area_on_sp_pickup_chance = 0 -- 44
    self.spawn_haste_area_on_cycle_chance = 0 -- 10
    self.spawn_haste_area_on_item_pickup_chance = 0 -- 20
    self.barrage_on_cycle_chance = 0 -- 22
    self.launch_homing_projectile_on_cycle_chance = 0 -- 22
    self.spawn_hp_on_cycle_chance = 0 -- 12
    self.regain_hp_on_cycle_chance = 0 -- 11
    self.regain_full_ammo_on_cycle_chance = 0 -- 11
    self.regain_ammo_on_kill_chance = 0 -- 32
    self.launch_homing_projectile_on_kill_chance = 0 -- 11
    self.regain_boost_on_kill_chance = 0 -- 10
    self.spawn_boost_on_kill_chance = 0 -- 10
    self.change_attack_on_cycle_chance = 0 -- 50
    self.launch_homing_projectile_on_item_pickup_chance = 0 -- 40
    self.spawn_sp_on_cycle_chance = 0 -- 20
    self.barrage_on_kill_chance = 0 -- 21
    self.gain_aspd_boost_on_kill_chance = 0 -- 15
    self.gain_mvspd_boost_on_cycle_chance = 0 -- 23
    self.gain_pspd_boost_on_cycle_chance = 0 -- 20
    self.gain_pspd_inhibit_on_cycle_chance = 0 -- 20
    self.launch_homing_projectile_while_boosting_chance = 0 -- 8
    self.shield_projectile_chance = 0 -- 24
    self.added_chance_to_all_on_kill_events = 0 -- 5
    self.drop_double_ammo_chance = 0 -- 30
    self.attack_twice_chance = 0 -- 20
    self.spawn_double_hp_chance = 0 -- 22
    self.spawn_double_sp_chance = 0 -- 24
    self.gain_double_sp_chance = 0 -- 20
    self.drop_mines_chance = 0 -- 5
    self.self_explode_on_cycle_chance = 0 -- 31
    self.attack_from_sides_chance = 0 -- 20
    self.attack_from_back_chance = 0 -- 20
    self.spin_projectile_on_expiration_chance = 0 -- 50

    -- Booleans
    self.increased_cycle_speed_while_boosting = false -- true
    self.invulnerability_while_boosting = false -- true
    self.increased_luck_while_boosting = false -- true
    self.projectile_ninety_degree_change = false -- true
    self.projectile_random_degree_change = false -- true
    self.wavy_projectiles = false -- true
    self.fast_slow = false -- true
    self.slow_fast = false -- true
    self.energy_shield = false -- true
    self.barrage_nova = false -- true
    self.projectiles_explode_on_expiration = false -- true
    self.lesser_increased_self_explosion_size = false -- true
    self.greater_increased_self_explosion_size = false -- true
    self.projectiles_explosions = false -- true
    self.change_attack_periodically = false -- true
    self.gain_sp_on_death = false -- true
    self.convert_hp_to_sp_if_hp_full = false -- true
    self.no_boost = false -- true
    self.half_ammo = false -- true
    self.half_hp = false -- true
    self.deals_damage_while_invulnerable = false -- true
    self.refill_ammo_if_hp_full = false -- true
    self.refill_boost_if_hp_full = false -- true
    self.only_spawn_boost = false -- true
    self.only_spawn_attack = false -- true
    self.no_ammo_drop = false -- true
    self.infinite_ammo = false -- true
    self.cant_launch_homing_projectiles = false
    self.cant_barrage = false
    self.item_restores_hp = false
    self.protective_barrier_when_no_ammo = false
    self.gain_stat_boost_on_attack_change = false
    self.rampage = false
    self.absorb_hits = false
    self.cant_trigger_on_cycle_events = false
    self.change_attack_when_no_ammo = false
    self.blast_shield = false
    self.double_homing = false
    self.ammo_gives_boost = false

    -- Conversions
    self.ammo_to_aspd = 0 -- 30
    self.mvspd_to_aspd = 0 -- 30
    self.mvspd_to_hp = 0 -- 30
    self.mvspd_to_pspd = 0 -- 30

    -- Adds
    self.additional_barrage_projectile = 0 -- 6
    self.additional_homing_projectile = 0 -- 2
    self.additional_blast_projectile = 0 -- 6
    self.projectile_pierce = 0 -- 2

    -- Attack
    self.additional_lightning_bolt = 0 -- 2
    self.lightning_trigger_distance_multiplier = 1 -- 1.5
    self.additional_bounce = 0 -- 4
    self.fixed_spin_direction = false -- true
    self.split_projectiles_split_chance = 0 -- 24
    self.start_with_double = false -- true
    self.start_with_triple = false -- true
    self.start_with_rapid = false -- true
    self.start_with_spread = false -- true
    self.start_with_back = false -- true
    self.start_with_side = false -- true
    self.start_with_homing = false -- true
    self.start_with_blast = false -- true
    self.start_with_spin = false -- true
    self.start_with_lightning = false -- true
    self.start_with_flame = false -- true
    self.start_with_2split = false -- true
    self.start_with_4split = false -- true
    self.start_with_explode = false -- true
    self.start_with_laser = false -- true
    self.start_with_bounce = false -- true
    self.double_spawn_chance = 0 -- 40
    self.triple_spawn_chance = 0 -- 50
    self.rapid_spawn_chance = 0 -- 40
    self.spread_spawn_chance = 0 -- 40
    self.back_spawn_chance = 0 -- 70
    self.side_spawn_chance = 0 -- 30
    self.homing_spawn_chance = 0 -- 40
    self.blast_spawn_chance = 0 -- 50
    self.spin_spawn_chance = 0 -- 70
    self.lightning_spawn_chance = 0 -- 40
    self.flame_spawn_chance = 0 -- 50
    self.twosplit_spawn_chance = 0 -- 50
    self.foursplit_spawn_chance = 0 -- 40
    self.explode_spawn_chance = 0 -- 60
    self.laser_spawn_chance = 0 -- 70
    self.bounce_spawn_chance = 0 -- 50

    -- Classes
    self.cycler = false
    self.tanker = false
    self.gunner = false
    self.runner = false
    self.swapper = false
    self.barrager = false
    self.seeker = false
    self.shielder = false
    self.regeneeer = false
    self.recycler = false
    self.buster = false
    self.buffer = false
    self.berserker = false
    self.absorber = false
    self.turner = false
    self.driver = false
    self.processor = false
    self.gambler = false
    self.panzer = false
    self.reserver = false
    self.repeater = false
    self.launcher = false
    self.deployer = false
    self.booster = false
    self.discharger = false
    self.hoamer = false
    self.splitter = false
    self.spinner = false
    self.bouncer = false
    self.blaster = false
    self.raider = false
    self.waver = false
    self.bomber = false
    self.zoomer = false
    self.racer = false
    self.miner = false
    self.piercer = false
    self.dasher = false
    self.engineer = false
    self.threader = false

    self.ship = (trailer_mode and opts.device) or device or 'Fighter'
    self:setShip()

    if not opts.trailer_stats then treeToPlayer(self) 
    else
        for k, v in pairs(opts.trailer_stats) do 
            if type(self[k]) == 'number' then self[k] = self[k] + v
            elseif type(self[k]) == 'boolean' then self[k] = v
            elseif self[k]:is(Stat) then self[k] = Stat(self[k].value + v) end
        end
    end
    self:setStats()
    self:setClasses()

    -- Collider
    self.x, self.y = x, y
    self.w, self.h = 12*self.size_multiplier, 12*self.size_multiplier
    self.shape = HC.circle(self.x, self.y, self.w)
    self.shape.object = self
    self.shape.tag = 'Player'
    self.shape.id = self.id

    -- Ship visuals
    self.polygons = {}
    self:shipVisuals()
    self:boostTrails()
    self:generateChances()

    if self.threader then
        self.cycle_timer_2 = 0
        self.cycle_cooldown_2 = 5
        self.cycle_timer_3 = 0
        self.cycle_cooldown_3 = 5
        self.cycle_timer_4 = 0
        self.cycle_cooldown_4 = 5
    end

    -- Mine drop
    self.timer:every('drop_mines', 0.5, function()
        if self.drop_mines_chance > 0 then
            if self.chances.drop_mines_chance:next() then
                local d = 1.2*self.w
                self.area:addGameObject('Projectile', self.x - d*math.cos(self.r), self.y - d*math.sin(self.r),
                {r = self.r, rv = table.random({random(-12*math.pi, -10*math.pi), random(10*math.pi, 12*math.pi)}), mine = true, attack = self.attack})
            end
        end
    end)

    -- Change attack periodically
    self.timer:every('change_attack', 10, function()
        if self.change_attack_periodically then
            self:setAttack(table.random(attack_names))
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Attack Change!'})
        end
    end)

    -- RollerPool
    self.timer:every('roller_pool', 0.5, function()
        if self.inside_roller_pool then
            self:hit(10)
        end
    end)

    -- Sapper
    self.sappers = {}
    self.timer:every(10, function() self.sappers = {} end)

    -- Item
    self.permanent_buffs = {
        ['stat_buffs'] = {
            ['protective_barrier'] = {chanceList({2, 10}, {5, 4}, {10, 1}), 'Protective Barrier'},
            ['flat_hp'] = {chanceList({10, 10}, {25, 4}, {50, 1}), 'HP'},
            ['flat_ammo'] = {chanceList({10, 10}, {25, 4}, {50, 1}), 'Ammo'},
            ['flat_boost'] = {chanceList({10, 10}, {25, 4}, {50, 1}), 'Boost'},
            ['ammo_gain'] = {chanceList({0.5, 10}, {1, 4}, {1.5, 1}), 'Ammo Gain'},
            ['hp_multiplier'] = {chanceList({0.1, 10}, {0.2, 4}, {0.3, 1}), 'HP'},
            ['ammo_multiplier'] = {chanceList({0.1, 10}, {0.2, 4}, {0.3, 1}), 'Ammo'},
            ['mvspd_multiplier'] = {chanceList({0.1, 10}, {0.2, 4}, {0.3, 1}), 'MVPSD'},
            ['pspd_multiplier'] = {chanceList({0.1, 10}, {0.2, 4}, {0.3, 1}), 'PSPD'},
            ['cycle_multiplier'] = {chanceList({0.1, 10}, {0.2, 4}, {0.3, 1}), 'Cycle Speed'},
            ['luck_multiplier'] = {chanceList({0.1, 10}, {0.2, 4}, {0.3, 1}), 'Luck'},
            ['turn_rate_multiplier'] = {chanceList({0.1, 10}, {0.2, 4}, {0.3, 1}), 'Turn Rate'},
            ['projectile_size_multiplier'] = {chanceList({0.1, 10}, {0.25, 4}, {0.5, 1}), 'Projectile Size'},
            ['invulnerability_time_multiplier'] = {chanceList({0.1, 10}, {0.25, 4}, {0.5, 1}), 'Invulnerability Time'},
            ['stat_boost_duration_multiplier'] = {chanceList({0.1, 10}, {0.25, 4}, {0.5, 1}), 'Stat Boost Duration'},
            ['ammo_consumption_multiplier'] = {chanceList({-0.1, 10}, {-0.2, 4}, {-0.3, 1}), 'Ammo Consumption'},
            ['projectile_waviness_multiplier'] = {chanceList({0.1, 10}, {0.25, 4}, {0.5, 1}), 'Projectile Waviness'},
            ['projectile_duration_multiplier'] = {chanceList({0.1, 10}, {0.25, 4}, {0.5, 1}), 'Projectile Duration'},
            ['projectile_angle_change_frequency_multiplier'] = {chanceList({0.1, 10}, {0.25, 4}, {0.5, 1}), 'Projectile Angle Change Frequency'},
            ['projectile_acceleration_multiplier'] = {chanceList({0.1, 10}, {0.25, 4}, {0.5, 1}), 'Projectile Acceleration'},
            ['projectile_deceleration_multiplier'] = {chanceList({0.1, 10}, {0.25, 4}, {0.5, 1}), 'Projectile Deceleration'},
            ['area_multiplier'] = {chanceList({0.1, 10}, {0.25, 4}, {0.5, 1}), 'Area'},
            ['energy_shield_recharge_amount_multiplier'] = {chanceList({0.1, 10}, {0.2, 4}, {0.3, 1}), 'Energy Shield Recharge Amount'},
            ['energy_shield_recharge_cooldown_multiplier'] = {chanceList({0.1, 10}, {0.2, 4}, {0.3, 1}), 'Energy Shield Recharge Cooldown'},
            ['barrage_on_cycle_chance'] = {chanceList({2, 10}, {4, 4}, {8, 1}), 'Barrage on Cycle Chance'},
            ['launch_homing_projectile_on_cycle_chance'] = {chanceList({2, 10}, {4, 4}, {8, 1}), 'Launch Homing Projectile on Cycle Chance'},
            ['launch_homing_projectile_on_kill_chance'] = {chanceList({1, 10}, {2, 4}, {4, 1}), 'Launch Homing Projectile on Kill Chance'},
            ['change_attack_on_cycle_chance'] = {chanceList({10, 10}, {25, 4}, {50, 1}), 'Change Attack on Cycle Chance'},
            ['barrage_on_kill_chance'] = {chanceList({2, 10}, {4, 4}, {8, 1}), 'Barrage on Kill Chance'},
            ['shield_projectile_chance'] = {chanceList({10, 10}, {25, 4}, {50, 1}), 'Shield Projectile Chance'},
            ['added_chance_to_all_on_kill_events'] = {chanceList({1, 10}, {2, 4}, {3, 1}), 'Added Chance to All "On Kill" Events'},
            ['drop_mines_chance'] = {chanceList({2, 10}, {4, 4}, {8, 1}), 'Drop Mines Chance'},
            ['self_explode_on_cycle_chance'] = {chanceList({8, 10}, {16, 4}, {24, 1}), 'Self Explode on Cycle Chance'},
            ['attack_twice_chance'] = {chanceList({10, 10}, {20, 4}, {30, 1}), 'Attack Twice Chance'},
            ['attack_from_sides_chance'] = {chanceList({10, 10}, {15, 4}, {20, 1}), 'Attack from Sides Chance'},
            ['attack_from_back_chance'] = {chanceList({10, 10}, {15, 4}, {20, 1}), 'Attack from Back Chance'},
            ['additional_barrage_projectile'] = {chanceList({1, 10}, {2, 4}, {3, 1}), 'Additional Barrage Projectile'},
            ['additional_homing_projectile'] = {chanceList({1, 10}, {2, 1}), 'Additional Homing Projectile'},
            ['projectile_pierce'] = {chanceList({1, 10}, {2, 4}, {3, 1}), 'Projectile Pierce'},
            ['additional_lightning_bolt'] = {chanceList({1, 10}, {2, 1}), 'Additional Lightning Bolt'},
            ['additional_bounce'] = {chanceList({1, 10}, {2, 4}, {4, 1}), 'Additional Bounce'},
            ['split_projectiles_split_chance'] = {chanceList({6, 10}, {12, 4}, {24, 1}), 'Split Projectiles Split Chance'},
        },

        ['modifier_buffs'] = {
            ['projectile_ninety_degree_change'] = {true, 'Projectile 90 Degree Change'},
            ['projectile_random_degree_change'] = {true, 'Projectile Random Degree Change'},
            ['increased_cycle_speed_while_boosting'] = {true, 'Increased Cycle Speed While Boosting'},
            ['fast_slow'] = {true, 'Fast -> Slow Projectiles'},
            ['slow_fast'] = {true, 'Slow -> Fast Projectiles'},
            ['barrage_nova'] = {true, 'Barrage Nova'},
            ['projectiles_explode_on_expiration'] = {true, 'Projectiles Explode on Expiration'},
            ['projectiles_explosions'] = {true, 'Explosions Create Projectiles Instead'},
            ['change_attack_periodically'] = {true, 'Change Attack Every 10 Seconds'},
            ['deals_damage_while_invulnerable'] = {true, 'Deals Damage While Invulnerable'},
            ['protective_barrier_when_no_ammo'] = {true, 'Protective Barrier When No Ammo'},
            ['rampage'] = {true, 'Rampage'},
            ['absorb_hits'] = {true, 'Absorb Hits'},
        },

        ['classes'] = {
            ['cycler'] = {true, 'Cycler'},
            ['tanker'] = {true, 'Tanker'},
            ['gunner'] = {true, 'Gunner'},
            ['runner'] = {true, 'Runner'},
            ['swapper'] = {true, 'Swapper'},
            ['barrager'] = {true, 'Barrager'},
            ['launcher'] = {true, 'Launcher'},
            ['shielder'] = {true, 'Shielder'},
            ['regeneer'] = {true, 'Regeneer'},
            ['recycler'] = {true, 'Recycler'},
            ['buster'] = {true, 'Buster'},
            ['berserker'] = {true, 'Berserker'},
            ['absorber'] = {true, 'Absorber'},
            ['panzer'] = {true, 'Panzer'},
            ['reserver'] = {true, 'Reserver'},
            ['repeater'] = {true, 'Repeater'},
            ['launcher'] = {true, 'Launcher'},
            ['deployer'] = {true, 'Deployer'},
            ['piercer'] = {true, 'Piercer'},
            ['dasher'] = {true, 'Dasher'},
            ['engineer'] = {true, 'Engineer'},
            ['threader'] = {true, 'Threader'},
        },

        ['attack_change'] = {
            ['attack_change'] = {true, 'Attack Change'}
        },
    }
    self.item_type_chance_list = chanceList({'stat_buffs', 30}, {'modifier_buffs', 10}, {'classes', 3}, {'attack_change', 8})
end

function Player:update(dt)
    Player.super.update(self, dt)

    -- Stat boosts
    if self.inside_haste_area then self.aspd_multiplier:increase(100) end
    if self.aspd_boosting then self.aspd_multiplier:increase(100) end
    if self.mvspd_boosting then self.mvspd_multiplier:increase(50) end
    if self.pspd_boosting then self.pspd_multiplier:increase(50) end
    if self.pspd_inhibiting then self.pspd_multiplier:decrease(50) end
    if self.cycle_boosting then self.cycle_multiplier:increase(200) end
    if self.inside_roller_pool then self.mvspd_multiplier:decrease(150) end
    self.inside_roller_pool = false
    if self.rampage then
        if self.rampage_counter >= 10 then
            self.aspd_multiplier:increase(math.floor(self.rampage_counter/10))
            self.pspd_multiplier:increase(math.floor(self.rampage_counter/10))
        end
    end

    -- Sappers
    for id, sap_type in pairs(self.sappers) do
        if sap_type == 'ASPD' then self.aspd_multiplier:decrease(50)
        elseif sap_type == 'PSPD' then self.pspd_multiplier:decrease(50)
        elseif sap_type == 'MVSPD' then self.mvspd_multiplier:decrease(50)
        elseif sap_type == 'Cycle' then self.cycle_multiplier:decrease(50) end
    end

    -- Conversions
    if self.ammo_to_aspd > 0 then self.aspd_multiplier:increase((self.ammo_to_aspd/100)*(self.max_ammo - 100)) end
    if self.mvspd_to_aspd > 0 then self.aspd_multiplier:increase((self.mvspd_to_aspd/100)*(self.mvspd_multiplier.value*100 - 100)) end
    if self.mvspd_to_pspd > 0 then self.pspd_multiplier:increase((self.mvspd_to_pspd/100)*(self.pspd_multiplier.value*100 - 100)) end

    self.aspd_multiplier:update(dt)
    self.mvspd_multiplier:update(dt)
    self.pspd_multiplier:update(dt)
    self.cycle_multiplier:update(dt)

    -- Collision
    if self.x < 0 then self.r = math.pi - self.r; self:hit(10) end
    if self.y < 0 then self.r = 2*math.pi - self.r; self:hit(10) end
    if self.x > gw then self.r = math.pi - self.r; self:hit(10) end
    if self.y > gh then self.r = 2*math.pi - self.r; self:hit(10) end

    for _, shape in ipairs(self:enter('Collectable')) do
        local object = shape.object
        if object then
            if object:is(Ammo) then
                object:die()
                self:addAmmo(5)
                self:onAmmoPickup()

            elseif object:is(Boost) then
                playGameItem()
                object:die()
                self:addBoost(math.floor(self.max_boost/4))

            elseif object:is(SkillPoint) then
                playGameItem()
                object:die()
                self:addSP(1)
                self:onSPPickup()

            elseif object:is(Attack) then
                playGameItem()
                object:die()
                self:setAttack(object.attack)
                current_room.score = current_room.score + 200

            elseif object:is(HP) then
                playGameItem()
                object:die()
                self:addHP(math.floor(self.max_hp/4))
                self:onHPPickup()

            elseif object:is(Key) then
                playGameItem()
                object:die()
                current_room.key_found = 'KEY ' .. keys[object.n].address.. ' FOUND'
                timer:after(3, function() current_room.key_found = false end)
                found_keys[object.n] = 1
                current_room:glitchError()

            elseif object:is(Item) then
                playGameItem()
                object:die()
                self:onItemPickup()

                local buff_type = self.item_type_chance_list:next()
                local buff = table.randomh(self.permanent_buffs[buff_type])
                if buff_type == 'attack_change' then
                    self:setAttack(table.random(attack_names))
                    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Attack Change!'})

                elseif type(self.permanent_buffs[buff_type][buff][1]) == 'table' then
                    local n = self.permanent_buffs[buff_type][buff][1]:next()
                    if buff == 'aspd_multiplier' or buff == 'mvspd_multiplier' or buff == 'pspd_multiplier' or buff == 'cycle_multiplier' then self[buff] = Stat(self[buff].value + n)
                    elseif buff == 'hp_multiplier' then self.max_hp = self.max_hp*(1+n)
                    elseif buff == 'ammo_multiplier' then self.max_ammo = self.max_ammo*(1+n)
                    elseif buff == 'boost_multiplier' then self.max_boost = self.max_boost*(1+n)
                    elseif buff == 'flat_hp' then self.max_hp = self.max_hp + n
                    elseif buff == 'flat_ammo' then self.max_ammo = self.max_ammo + n
                    elseif buff == 'flat_boost' then self.max_boost = self.max_boost + n
                    else self[buff] = self[buff] + n end
                    if self.projectile_waviness_multiplier > 1 then self.wavy_projectiles = true end
                    if self.pspd_multiplier.value < 0 then self.pspd_multiplier.base = 0 end
                    self:setClass(buff)
                    self:generateChances()
                    local text = ''
                    if n < 1 then text = text .. '+' .. n*100 .. '% ' .. self.permanent_buffs[buff_type][buff][2] .. '!'
                    else 
                        if self.permanent_buffs[buff_type][buff][2]:find('Chance') then text = text .. '+' .. n .. '% ' .. self.permanent_buffs[buff_type][buff][2] .. '!'
                        else text = text .. '+' .. n .. ' ' .. self.permanent_buffs[buff_type][buff][2] .. '!' end
                    end
                    self.area:addGameObject('InfoText', object.x, object.y, {text = text})

                elseif type(self.permanent_buffs[buff_type][buff][1]) == 'boolean' then
                    self[buff] = true
                    local text = self.permanent_buffs[buff_type][buff][2] .. '!'
                    self:setClass(buff)
                    self:generateChances()
                    self.area:addGameObject('InfoText', object.x, object.y, {text = text})
                end
            end
        end
    end

    for _, shape in ipairs(self:enter('Enemy')) do
        local object = shape.object
        if object then 
            if object:is(Sapper) then self:hit(10) 
            else self:hit(30) end
            if self.deals_damage_while_invulnerable then object:hit(1000) end
        end
    end

    -- Rampage
    self.rampage_timer = self.rampage_timer + dt
    if self.rampage_timer > self.rampage_cooldown then
        self.rampage_counter = 0
        self.rampage_timer = 0
    end

    -- Cycle
    self.cycle_timer = self.cycle_timer + dt*self.cycle_multiplier.value
    if self.cycle_timer > self.cycle_cooldown then
        self.cycle_timer = 0
        self:cycle()
    end

    if self.threader then
        self.cycle_timer_2 = self.cycle_timer_2 + dt*self.cycle_multiplier.value*0.47
        if self.cycle_timer_2 > self.cycle_cooldown_2 then
            self.cycle_timer_2 = 0
            self:cycle()
        end

        self.cycle_timer_3 = self.cycle_timer_3 + dt*self.cycle_multiplier.value*0.22
        if self.cycle_timer_3 > self.cycle_cooldown_3 then
            self.cycle_timer_3 = 0
            self:cycle()
        end

        self.cycle_timer_4 = self.cycle_timer_4 + dt*self.cycle_multiplier.value*0.06
        if self.cycle_timer_4 > self.cycle_cooldown_4 then
            self.cycle_timer_4 = 0
            self:cycle()
        end
    end

    -- Boost
    self.boost = math.min(self.boost + 10*dt*self.boost_recharge_rate_multiplier, self.max_boost)
    self.boost_timer = self.boost_timer + dt
    if self.boost_timer > self.boost_cooldown then self.can_boost = true end
    self.max_v = self.base_max_v
    self.boosting = false
    if self.turner then
        self.boosting_up = false
        self.boosting_down = false
    end
    if input:pressed('up') and self.boost > 1 and self.can_boost then self:onBoostStart() end
    if input:released('up') then self:onBoostEnd() end
    if input:down('up') and self.boost > 1 and self.can_boost then 
        self.boosting = true
        if self.turner then self.boosting_up = true end
        self.max_v = 1.5*self.base_max_v*self.boost_effectiveness_multiplier
        self.boost = self.boost - 50*dt
        if self.boost <= 1 then
            self.boosting = false
            if self.turner then self.boosting_up = false end
            self.can_boost = false
            self.boost_timer = 0
            self:onBoostEnd()
        end
    end
    if input:pressed('down') and self.boost > 1 and self.can_boost then self:onBoostStart() end
    if input:released('down') then self:onBoostEnd() end
    if input:down('down') and self.boost > 1 and self.can_boost then 
        self.boosting = true
        if self.turner then self.boosting_down = true end
        self.max_v = 0.5*self.base_max_v*(2-self.boost_effectiveness_multiplier)
        self.boost = self.boost - 50*dt
        if self.boost <= 1 then
            self.boosting = false
            if self.turner then self.boosting_down = false end
            self.can_boost = false
            self.boost_timer = 0
            self:onBoostEnd()
        end
    end
    self.trail_color = skill_point_color 
    if self.boosting then self.trail_color = boost_color end

    -- Shoot
    self.shoot_timer = self.shoot_timer + dt
    if self.shoot_timer > self.shoot_cooldown/self.aspd_multiplier.value then
        self.shoot_timer = 0
        self:shoot()
    end

    -- Barrage
    self.barrage_timer = self.barrage_timer + dt

    -- Protective Barrier
    if self.protective_barrier > 10 then self.protective_barrier = 10 end

    -- Dash
    if self.dasher and input:sequence('up', 0.5, 'up') then
        if self.boost >= 50 then
            local angle = Vector.angle(self.vx, self.vy)
            local tx, ty = self.x + 64*math.cos(angle), self.y + 64*math.sin(angle)
            self.shape:moveTo(tx, ty)
            self:removeBoost(50)
            self.invincible = true
            self.timer:after('invincibility', 2*self.invulnerability_time_multiplier, function() self.invincible = false end)
            for i = 1, math.floor(50*self.invulnerability_time_multiplier) do self.timer:after((i-1)*0.04, function() self.invisible = not self.invisible end) end
            self.timer:after((math.floor(50*self.invulnerability_time_multiplier)+1)*0.04, function() self.invisible = false end)
            for i = 1, 10 do
                self.timer:after(0.1*i, function() self.area:addGameObject('Explosion', self.x + random(-32, 32), self.y + random(-32, 32), {color = boost_color, damage_multiplier = 2}) end)
            end
        end
    end

    -- Movement
    if input:down('left') then self.r = self.r - (self.boosting_up and 1.5 or 1)*(self.boosting_down and 0.5 or 1)*self.turn_rate_multiplier*self.rv*dt end
    if input:down('right') then self.r = self.r + (self.boosting_up and 1.5 or 1)*(self.boosting_down and 0.5 or 1)*self.turn_rate_multiplier*self.rv*dt end
    self.v = math.min(self.v + self.a*dt, self.max_v*self.mvspd_multiplier.value)
    self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r)

    -- Paused
    if self.paused then self.vx, self.vy = 0, 0 end
    if input:pressed('left') or input:pressed('right') or input:pressed('up') or input:pressed('down') then self.paused = false end

    -- Move
    self.shape:move(self.vx*dt, self.vy*dt)
    self.x, self.y = self.shape:center()
end

function Player:draw()
    if self.invisible then return end

    pushRotate(self.x, self.y, self.r)
    love.graphics.setColor(default_color)
    for _, vertice_group in ipairs(self.polygons) do
        local points = fn.map(vertice_group, function(k, v) if k % 2 == 1 then return self.x + v + random(-1, 1) else return self.y + v + random(-1, 1) end end)
        love.graphics.polygon('line', points)
    end

    if self.protective_barrier > 0 then
        for i = 1, self.protective_barrier do
            love.graphics.circle('line', self.x - self.w/2, self.y, 2*self.w + i*4 + random(-1, 1))
        end
    end
    love.graphics.pop()
end

function Player:destroy()
    Player.super.destroy(self)
end

function Player:cycle()
    self.area:addGameObject('CycleEffect', self.x, self.y, {parent = self})
    self:onCycle()
end

function Player:shoot()
    if self.paused then return end

    local d = 1.2*self.w
    self.area:addGameObject('ShootEffect', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {parent = self, d = d})

    if self.attack == 'Neutral' then
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), {r = self.r, attack = self.attack})

    elseif self.attack == 'Double' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r + math.pi/12), self.y + 1.5*d*math.sin(self.r + math.pi/12), {r = self.r + math.pi/12, attack = self.attack})
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi/12), self.y + 1.5*d*math.sin(self.r - math.pi/12), {r = self.r - math.pi/12, attack = self.attack})

    elseif self.attack == 'Triple' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), {r = self.r, attack = self.attack})
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r + math.pi/12), self.y + 1.5*d*math.sin(self.r + math.pi/12), {r = self.r + math.pi/12, attack = self.attack})
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi/12), self.y + 1.5*d*math.sin(self.r - math.pi/12), {r = self.r - math.pi/12, attack = self.attack})

    elseif self.attack == 'Rapid' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), {r = self.r, attack = self.attack})

    elseif self.attack == 'Spread' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        local random_angle = random(-math.pi/8, math.pi/8)
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r + random_angle), self.y + 1.5*d*math.sin(self.r + random_angle), {r = self.r + random_angle, attack = self.attack})

    elseif self.attack == 'Back' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), {r = self.r, attack = self.attack})
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi), self.y + 1.5*d*math.sin(self.r - math.pi), {r = self.r - math.pi, attack = self.attack})

    elseif self.attack == 'Side' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), {r = self.r, attack = self.attack})
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi/2), self.y + 1.5*d*math.sin(self.r - math.pi/2), {r = self.r - math.pi/2, attack = self.attack})
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r + math.pi/2), self.y + 1.5*d*math.sin(self.r + math.pi/2), {r = self.r + math.pi/2, attack = self.attack})

    elseif self.attack == 'Homing' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), {r = self.r, attack = self.attack})
        if self.double_homing then self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), {r = self.r, attack = self.attack}) end

    elseif self.attack == 'Blast' then
        playGameShoot2()
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        for i = 1, 12+self.additional_blast_projectile do
            local random_angle = random(-math.pi/6, math.pi/6)
            self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r + random_angle), self.y + 1.5*d*math.sin(self.r + random_angle), 
            {r = self.r + random_angle, attack = self.attack, v = random(500, 600)})
        end
        camera:shake(2, 60, 0.2)

    elseif self.attack == 'Spin' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), {r = self.r, attack = self.attack})

    elseif self.attack == 'Bounce' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), {r = self.r, attack = self.attack, bounce = 4 + self.additional_bounce})

    elseif self.attack == 'Lightning' then
        local x1, y1 = self.x + d*math.cos(self.r), self.y + d*math.sin(self.r)
        local cx, cy = x1 + 24*math.cos(self.r), y1 + 24*math.sin(self.r)
        local enemy_amount_to_attack = 1 + self.additional_lightning_bolt

        -- Find closest enemy
        local nearby_enemies = self.area:getAllGameObjectsThat(function(e)
            for _, enemy in ipairs(enemies) do
                if self.lightning_targets_projectiles then
                    if (e:is(_G[enemy]) or e:is(EnemyProjectile)) and (distance(e.x, e.y, cx, cy) < 64*self.lightning_trigger_distance_multiplier) then
                        return true
                    end
                else
                    if e:is(_G[enemy]) and (distance(e.x, e.y, cx, cy) < 64*self.lightning_trigger_distance_multiplier) then
                        return true
                    end
                end
            end
        end)
        table.sort(nearby_enemies, function(a, b) return distance(a.x, a.y, cx, cy) < distance(b.x, b.y, cx, cy) end)
        local closest_enemies = fn.first(nearby_enemies, enemy_amount_to_attack)

        -- Attack closest enemies
        for i, closest_enemy in ipairs(closest_enemies) do
            self.timer:after((i-1)*0.05, function()
                if closest_enemy then
                    playGameLightning()
                    if not closest_enemy:is(EnemyProjectile) then self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier end
                    closest_enemy:hit()
                    if closest_enemy.dead then self:onKill(closest_enemy) end
                    local x2, y2 = closest_enemy.x, closest_enemy.y
                    self.area:addGameObject('LightningLine', 0, 0, {x1 = x1, y1 = y1, x2 = x2, y2 = y2})
                    for i = 1, love.math.random(4, 8) do self.area.room.explode_particles:add(x1, y1, nil, nil, table.random({default_color, boost_color})) end
                    for i = 1, love.math.random(4, 8) do self.area.room.explode_particles:add(x2, y2, nil, nil, table.random({default_color, boost_color})) end
                end
            end)
        end

    elseif self.attack == 'Flame' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        local random_angle = random(-math.pi/16, math.pi/16)
        self.area:addGameObject('Projectile', self.x + 2*d*math.cos(self.r + random_angle), self.y + 2*d*math.sin(self.r + random_angle), {r = self.r + random_angle, attack = self.attack, s = 2})

    elseif self.attack == '2Split' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 2*d*math.cos(self.r), self.y + 2*d*math.sin(self.r), {r = self.r, attack = self.attack})

    elseif self.attack == '4Split' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 2*d*math.cos(self.r), self.y + 2*d*math.sin(self.r), {r = self.r, attack = self.attack, s = 3})

    elseif self.attack == 'Explode' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 2*d*math.cos(self.r), self.y + 2*d*math.sin(self.r), {r = self.r, attack = self.attack, s = 3})

    elseif self.attack == 'Laser' then
        playGameLaser()

        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        local x1 = self.x + d*math.cos(self.r)
        local y1 = self.y + d*math.sin(self.r)
        local x2 = self.x + 1024*math.cos(self.r)
        local y2 = self.y + 1024*math.sin(self.r)

        self.area:addGameObject('ProjectileDeathEffect', x1, y1, {w = 6*self.laser_width_multiplier, attack = self.attack, color = hp_color, r = self.r + math.pi/4})
        local wm = 1*self.laser_width_multiplier
        local x1n, y1n, x2n, y2n = x1 + wm*16*math.cos(self.r - math.pi/2), y1 + wm*16*math.sin(self.r - math.pi/2), x1 + wm*16*math.cos(self.r + math.pi/2), y1 + wm*16*math.sin(self.r + math.pi/2)
        local x3n, y3n, x4n, y4n = x2 + wm*16*math.cos(self.r - math.pi/2), y2 + wm*16*math.sin(self.r - math.pi/2), x2 + wm*16*math.cos(self.r + math.pi/2), y2 + wm*16*math.sin(self.r + math.pi/2)
        self.area:addGameObject('LaserLine', 0, 0, {x1 = x1, y1 = y1, x2 = x2, y2 = y2, angle = self.r, wm = wm})
        local objects = self.area:queryPolygonArea({x1n, y1n, x2n, y2n, x3n, y3n, x4n, y4n}, {'EnemyProjectile', unpack(enemies)})
        for _, object in ipairs(objects) do 
            object:hit(1000) 
            if object.dead then self:onKill(object) end
        end

        camera:shake(4, 60, 0.25)
    end

    if self.chances.attack_twice_chance:next() then
        self.timer:after(self.shoot_cooldown/2, function() 
            -- self.area:addGameObject('InfoText', self.x, self.y, {text = 'Double Attack!'})
            self:shoot() 
        end)
    end

    if self.chances.attack_from_sides_chance:next() then
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi/2), self.y + 1.5*d*math.sin(self.r - math.pi/2), {r = self.r - math.pi/2, attack = self.attack})
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r + math.pi/2), self.y + 1.5*d*math.sin(self.r + math.pi/2), {r = self.r + math.pi/2, attack = self.attack})
    end

    if self.chances.attack_from_back_chance:next() then
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi), self.y + 1.5*d*math.sin(self.r - math.pi), {r = self.r - math.pi, attack = self.attack})
    end

    if self.ammo <= 0 then 
        self:setAttack('Neutral')
        self.ammo = self.max_ammo

        if self.change_attack_when_no_ammo then
            self:setRandomAttack()
        end

        if self.protective_barrier_when_no_ammo then
            self.protective_barrier = self.protective_barrier + math.floor(self.max_ammo/50)
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Protective Barrier!', color = default_color})
        end
    end

    if self.infinite_ammo then
        self.ammo = self.max_ammo
    end
end

function Player:explode()
    local w = 64*self.area_multiplier
    self.area:addGameObject('ShockwaveDisplacement', self.x, self.y)

    local c = {-1, 1}
    local d = {}
    for _, i in ipairs(c) do
        for _, j in ipairs(c) do
            table.insert(d, {i, j})
        end
    end
    for _, c in ipairs(d) do self.timer:after(random(0.1, 0.2), function() self.area:addGameObject('Explosion', self.x + c[1]*w/2, self.y + c[2]*w/2, {color = hp_color, w = w}) end) end

    local c = {-2, -1, 1, 2}
    local d = {}
    for _, i in ipairs(c) do
        for _, j in ipairs(c) do
            if math.abs(i) == 2 or math.abs(j) == 2 then
                table.insert(d, {i, j})
            end
        end
    end
    for _, c in ipairs(d) do self.timer:after(random(0.2, 0.3), function() self.area:addGameObject('Explosion', self.x + c[1]*w/2, self.y + c[2]*w/2, {color = hp_color, w = w}) end) end

    if self.lesser_increased_self_explosion_size and self.greater_increased_self_explosion_size then
        local c = {-3, -2, -1, 1, 2, 3}
        local d = {}
        for _, i in ipairs(c) do
            for _, j in ipairs(c) do
                if math.abs(i) == 3 or math.abs(j) == 3 then
                    table.insert(d, {i, j})
                end
            end
        end
        for _, c in ipairs(d) do self.timer:after(random(0.3, 0.4), function() self.area:addGameObject('Explosion', self.x + c[1]*w/2, self.y + c[2]*w/2, {color = hp_color, w = w}) end) end

        local c = {-4, -3, -2, -1, 1, 2, 3, 4}
        local d = {}
        for _, i in ipairs(c) do
            for _, j in ipairs(c) do
                if math.abs(i) == 4 or math.abs(j) == 4 then
                    table.insert(d, {i, j})
                end
            end
        end
        for _, c in ipairs(d) do self.timer:after(random(0.4, 0.5), function() self.area:addGameObject('Explosion', self.x + c[1]*w/2, self.y + c[2]*w/2, {color = hp_color, w = w}) end) end

    elseif self.lesser_increased_self_explosion_size and not self.greater_increased_self_explosion_size then
        local c = {-3, -2, -1, 1, 2, 3}
        local d = {}
        for _, i in ipairs(c) do
            for _, j in ipairs(c) do
                if math.abs(i) == 3 or math.abs(j) == 3 then
                    table.insert(d, {i, j})
                end
            end
        end
        for _, c in ipairs(d) do self.timer:after(random(0.3, 0.4), function() self.area:addGameObject('Explosion', self.x + c[1]*w/2, self.y + c[2]*w/2, {color = hp_color, w = w}) end) end
    end
end

function Player:setAttack(attack)
    self.attack = attack
    self.shoot_cooldown = attacks[attack].cooldown
    self.ammo = self.max_ammo

    if self.gain_stat_boost_on_attack_change then self:grantRandomBuff() end
end

function Player:setRandomAttack()
    local all_attacks = fn.keys(attacks)
    repeat self.attack = all_attacks[love.math.random(1, #all_attacks)] until self.attack ~= 'Neutral'
    self.shoot_cooldown = attacks[self.attack].cooldown
    self.ammo = self.max_ammo

    if self.gain_stat_boost_on_attack_change then self:grantRandomBuff() end
end

function Player:grantRandomBuff()
    local buff = table.random({'ASPD', 'MVSPD', 'Cycle', 'PSPD'})

    if buff == 'ASPD' then
        self.aspd_boosting = true
        self.timer:after(4*self.stat_boost_duration_multiplier, function() self.aspd_boosting = false end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'ASPD Boost!', color = ammo_color})

    elseif buff == 'MVPSD' then
        self.mvspd_boosting = true
        self.timer:after(4*self.stat_boost_duration_multiplier, function() self.mvspd_boosting = false end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'MVSPD Boost!'})

    elseif buff == 'Cycle' then
        self.cycle_boosting = true
        self.timer:after(4*self.stat_boost_duration_multiplier, function() self.cycle_boosting = false end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Cycle Boost!'})

    elseif buff == 'PSPD' then
        self.pspd_boosting = true
        self.timer:after(4*self.stat_boost_duration_multiplier, function() self.pspd_boosting = false end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'PSPD Boost!'})
    end
end

function Player:hit(damage, hit_type)
    if self.invincible then return end
    hit_type = hit_type or 'Enemy'
    damage = damage or 10

    if self.absorb_hits then
        if hit_type == 'Projectile' then
            if self.boost > 25 then
                self:removeBoost(25)
                camera:shake(1, 60, 0.2)
                flash(1)
                self.area:addGameObject('InfoText', self.x, self.y, {text = 'Projectile Absorbed!', color = boost_color})
                return
            end
        elseif hit_type == 'Enemy' then
            if self.boost > 50 then
                self:removeBoost(50)
                camera:shake(2, 60, 0.2)
                flash(2)
                self.invincible = true
                self.timer:after('invincibility', 1*self.invulnerability_time_multiplier, function() self.invincible = false end)
                for i = 1, math.floor(25*self.invulnerability_time_multiplier) do self.timer:after((i-1)*0.04, function() self.invisible = not self.invisible end) end
                self.timer:after((math.floor(25*self.invulnerability_time_multiplier)+1)*0.04, function() self.invisible = false end)
                self.area:addGameObject('InfoText', self.x, self.y, {text = 'Hit Absorbed!', color = boost_color})
                return
            end
        end
    end

    if self.protective_barrier > 0 then
        self.protective_barrier = self.protective_barrier - 1
        camera:shake(1, 60, 0.2)
        flash(1)
        return
    end

    if self.energy_shield then
        damage = damage*2
        self.timer:after('energy_shield_recharge_cooldown', self.energy_shield_recharge_cooldown/self.energy_shield_recharge_cooldown_multiplier, function()
            self.timer:every('energy_shield_recharge_amount', 0.25, function()
                self:addHP(self.energy_shield_recharge_amount*self.energy_shield_recharge_amount_multiplier)
            end)
        end)
    end

    for i = 1, love.math.random(4, 8) do self.area.room.explode_particles:add(self.x, self.y) end
    self:removeHP(damage)
    playGameHurt()

    if damage >= 30 then
        self.invincible = true
        self.timer:after('invincibility', 2*self.invulnerability_time_multiplier, function() self.invincible = false end)
        for i = 1, math.floor(50*self.invulnerability_time_multiplier) do self.timer:after((i-1)*0.04, function() self.invisible = not self.invisible end) end
        self.timer:after((math.floor(50*self.invulnerability_time_multiplier)+1)*0.04, function() self.invisible = false end)

        camera:shake(6, 60, 0.2)
        flash(3)
        slow(0.25/self.invulnerability_time_multiplier, 1.0)
        current_room:rgbShift()
    else
        camera:shake(3, 60, 0.1)
        flash(2)
        slow(0.75/self.invulnerability_time_multiplier, 0.5)
        current_room:rgbShift()
    end
end

function Player:bounce(bx, by)
    
end

function Player:die()
    self.dead = true 
    flash(4)
    camera:shake(6, 60, 0.4)
    slow(0.15/self.invulnerability_time_multiplier, 1.5)
    for i = 1, love.math.random(8, 12) do self.area.room.explode_particles:add(self.x, self.y) end

    if self.gain_sp_on_death then
        self:addSP(3)
        self.area:addGameObject('InfoText', self.x, self.y, {text = '+3 SP', color = skill_point_color})
    end

    current_room:finish()
end

function Player:addAmmo(amount)
    if self.ammo_gives_boost then self.boost = math.min(self.boost + 2, self.max_boost)
    else self.ammo = math.min(self.ammo + amount + self.ammo_gain, self.max_ammo) end

    current_room.score = current_room.score + 50
end

function Player:addBoost(amount)
    self.boost = math.min(self.boost + amount, self.max_boost)
    current_room.score = current_room.score + 150   
end

function Player:removeBoost(amount)
    self.boost = self.boost - (amount or 1)
    if self.boost < 0 then self.boost = 0 end
end

function Player:addSP(amount)
    local multiplier = 1
    if loop <= 1 then multiplier = 2 end

    if self.chances.gain_double_sp_chance:next() then
        skill_points = skill_points + multiplier*2*amount
        current_room.score = current_room.score + 500
        self.area:addGameObject('InfoText', self.x, self.y, {text = '+1 SP', color = skill_point_color})
    else
        skill_points = skill_points + multiplier*amount
        current_room.score = current_room.score + 250
    end
end

function Player:addHP(amount)
    self.hp = math.min(self.hp + amount, self.max_hp)
end

function Player:removeHP(amount)
    self.hp = self.hp - (amount or 5)
    if self.hp <= 0 then
        self.hp = 0
        self:die()
    end
end

function Player:onItemPickup()
    if self.item_restores_hp then
        self:addHP(math.floor(self.max_hp/4))
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'RESTORED 25 HP!', color = hp_color})
    end

    if self.chances.launch_homing_projectile_on_item_pickup_chance:next() and not self.cant_launch_homing_projectiles then
        local d = 1.2*self.w
        for i = 1, 1+self.additional_homing_projectile do
            self.area:addGameObject('Projectile', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {r = self.r, attack = 'Homing', damage_multiplier = 2})
        end
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
    end

    if self.chances.regain_hp_on_item_pickup_chance:next() then
        self:addHP(math.floor(self.max_hp/4))
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Regain!', color = hp_color})
    end

    if self.chances.spawn_haste_area_on_item_pickup_chance:next() then
        self.area:addGameObject('HasteArea', self.x, self.y)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Haste Area!'})
    end
end

function Player:onSPPickup()
    if self.chances.regain_hp_on_sp_pickup_chance:next() then
        self:addHP(math.floor(self.max_hp/4))
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Regain!', color = hp_color})
    end

    if self.chances.spawn_haste_area_on_sp_pickup_chance:next() then
        self.area:addGameObject('HasteArea', self.x, self.y)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Haste Area!'})
    end
end

function Player:onHPPickup()
    if self.chances.spawn_haste_area_on_hp_pickup_chance:next() then
        self.area:addGameObject('HasteArea', self.x, self.y)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Haste Area!'})
    end

    if self.convert_hp_to_sp_if_hp_full then
        if self.hp >= self.max_hp then
            self:addSP(3)
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP -> SP!'})
        end
    end

    if self.refill_ammo_if_hp_full then
        if self.hp >= self.max_hp then
            self.ammo = self.max_ammo
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Ammo Refill!'})
        end
    end

    if self.refill_boost_if_hp_full then
        if self.hp >= self.max_hp then
            self.boost = self.max_boost
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Boost Refill!'})
        end
    end
end

function Player:onAmmoPickup()
end

function Player:onCycle()
    if self.cant_trigger_on_cycle_events then return end

    if self.chances.spawn_sp_on_cycle_chance:next() then
        self.area:addGameObject('SkillPoint')
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'SP Spawn!', color = skill_point_color})
    end

    if self.chances.spawn_hp_on_cycle_chance:next() then
        self.area:addGameObject('HP')
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Spawn!', color = hp_color})
    end

    if self.chances.regain_hp_on_cycle_chance:next() then
        self:addHP(math.floor(self.max_hp/4))
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Regain!', color = hp_color})
    end

    if self.chances.regain_full_ammo_on_cycle_chance:next() then
        self:addAmmo(self.max_ammo)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Full Ammo Regain!', color = ammo_color})
    end

    if self.chances.change_attack_on_cycle_chance:next() then
        self:setRandomAttack()
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Random Attack!'})
    end

    if self.chances.spawn_haste_area_on_cycle_chance:next() then
        self.area:addGameObject('HasteArea', self.x, self.y)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Haste Area!'})
    end

    if self.chances.barrage_on_cycle_chance:next() and not self.cant_barrage then
        self:barrage()
    end

    if self.chances.launch_homing_projectile_on_cycle_chance:next() and not self.cant_launch_homing_projectiles then
        local d = 1.2*self.w
        for i = 1, 1+self.additional_homing_projectile do
            self.area:addGameObject('Projectile', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {r = self.r, attack = 'Homing', damage_multiplier = 2})
        end
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
    end

    if self.chances.gain_mvspd_boost_on_cycle_chance:next() then
        self.mvspd_boosting = true
        self.timer:after(4*self.stat_boost_duration_multiplier, function() self.mvspd_boosting = false end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'MVSPD Boost!'})
    end

    if self.chances.gain_pspd_boost_on_cycle_chance:next() then
        self.pspd_boosting = true
        self.timer:after(4*self.stat_boost_duration_multiplier, function() self.pspd_boosting = false end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'PSPD Boost!'})
    end

    if self.chances.gain_pspd_inhibit_on_cycle_chance:next() then
        self.pspd_inhibiting = true
        self.timer:after(4*self.stat_boost_duration_multiplier, function() self.pspd_inhibiting = false end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'PSPD Inhibit!'})
    end

    if self.chances.self_explode_on_cycle_chance:next() then
        self:explode()
    end
end

function Player:onKill(enemy)
    if self.rampage then
        self.rampage_counter = self.rampage_counter + 1
        self.rampage_timer = 0

        if self.rampage_counter == 15 then
            -- Barrage
            self:barrage()

        elseif self.rampage_counter == 30 then
            -- Launch 8 Homing Projectiles
            local d = 1.2*self.w
            for i = 1, 8 do
                self.area:addGameObject('Projectile', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {r = self.r, attack = 'Homing', damage_multiplier = 2})
            end
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})

        elseif self.rampage_counter == 45 then
            -- 2 Barrage Novas
            for j = 1, 2 do
                self.timer:after((j-1)*1, function()
                    self:barrage(true)
                end)
            end
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Barrage Nova!!!'})

        elseif self.rampage_counter == 70 then
            -- +5 Protective Barrier
            self.protective_barrier = self.protective_barrier + 5

        elseif self.rampage_counter == 100 then
            -- +2 SP
            self:addSP(1)
            self.area:addGameObject('InfoText', self.x, self.y, {text = '+1 SP', color = skill_point_color})

        elseif self.rampage_counter == 130 then
            -- 5 Barrage Novas
            for j = 1, 5 do
                self.timer:after((j-1)*1, function()
                    self:barrage(true)
                end)
            end
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Barrage Nova!!!'})

        elseif self.rampage_counter == 170 then
            local ammos = self.area:getAllGameObjectsThat(function(e) return e:is(Ammo) end)
            local n = math.floor(#ammos/5)
            for i = 1, n do
                local ammo = table.remove(ammos, love.math.random(1, #ammos))
                if ammo then
                    ammo:die()
                    local d = 1.2*self.w
                    self.area:addGameObject('Projectile', ammo.x - d*math.cos(self.r), ammo.y - d*math.sin(self.r),
                    {r = self.r, rv = table.random({random(-12*math.pi, -10*math.pi), random(10*math.pi, 12*math.pi)}), mine = true, attack = self.attack})
                end
            end

        elseif self.rampage_counter == 200 then
            -- +2 SP
            self:addSP(2)
            self.area:addGameObject('InfoText', self.x, self.y, {text = '+2 SP', color = skill_point_color})

        elseif self.rampage_counter == 240 then
            -- Launch 24 homing projectiles
            local d = 1.2*self.w
            for i = 1, 24 do
                self.area:addGameObject('Projectile', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {r = self.r, attack = 'Homing', damage_multiplier = 2})
            end
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})

        elseif self.rampage_counter == 280 then
            -- Cast lightning attack on all enemies
            local d = 1.2*self.w
            local x1, y1 = self.x + d*math.cos(self.r), self.y + d*math.sin(self.r)
            local cx, cy = x1 + 24*math.cos(self.r), y1 + 24*math.sin(self.r)
            local enemies = self.area:getAllGameObjectsThat(function(e)
                for _, enemy in ipairs(enemies) do
                    if e:is(_G[enemy]) then
                        return true
                    end
                end
            end)
            for i, enemy in ipairs(enemies) do
                self.timer:after((i-1)*0.05, function()
                    if enemy then
                        enemy:hit()
                        local x2, y2 = enemy.x, enemy.y
                        self.area:addGameObject('LightningLine', 0, 0, {x1 = x1, y1 = y1, x2 = x2, y2 = y2})
                        for i = 1, love.math.random(4, 8) do self.area.room.explode_particles:add(x1, y1, nil, nil, table.random({default_color, boost_color})) end
                        for i = 1, love.math.random(4, 8) do self.area.room.explode_particles:add(x2, y2, nil, nil, table.random({default_color, boost_color})) end
                    end
                end)
            end

        elseif self.rampage_counter == 330 then
            -- +2 SP
            self:addSP(2)
            self.area:addGameObject('InfoText', self.x, self.y, {text = '+2 SP', color = skill_point_color})

        elseif self.rampage_counter == 380 then
            -- 20 Barrage Novas
            for j = 1, 20 do
                self.timer:after((j-1)*1, function()
                    self:barrage(true)
                end)
            end
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Barrage Nova!!!'})

        elseif self.rampage_counter == 440 then
            -- +10 Protective Barrier
            self.protective_barrier = self.protective_barrier + 10

        elseif self.rampage_counter == 500 then
            -- +4 SP
            self:addSP(4)
            self.area:addGameObject('InfoText', self.x, self.y, {text = '+4 SP', color = skill_point_color})
        end
    end

    if self.chances.barrage_on_kill_chance:next() and not self.cant_barrage then
        self:barrage()
    end

    if self.chances.gain_aspd_boost_on_kill_chance:next() then
        self.aspd_boosting = true
        self.timer:after(4*self.stat_boost_duration_multiplier, function() self.aspd_boosting = false end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'ASPD Boost!', color = ammo_color})
    end

    if self.chances.regain_ammo_on_kill_chance:next() then
        self:addAmmo(20)
    end

    if self.chances.launch_homing_projectile_on_kill_chance:next() and not self.cant_launch_homing_projectiles then
        local d = 1.2*self.w
        for i = 1, 1+self.additional_homing_projectile do
            self.area:addGameObject('Projectile', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {r = self.r, attack = 'Homing', damage_multiplier = 2})
        end
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
    end

    if self.chances.regain_boost_on_kill_chance:next() then
        self:addBoost(math.floor(self.max_boost/4))
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Boost Regain!', color = boost_color})
    end

    if self.chances.spawn_boost_on_kill_chance:next() then
        self.area:addGameObject('Boost')
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Boost Spawn!', color = boost_color})
    end

    if self.chances.drop_double_ammo_chance:next() then
        self.area:addGameObject('Ammo', enemy.x, enemy.y)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Double Ammo!', color = ammo_color})
    end
end

function Player:onBoostStart()
    self.timer:every('launch_homing_projectile_while_boosting_chance', 0.2, function()
        if self.chances.launch_homing_projectile_while_boosting_chance:next() and not self.cant_launch_homing_projectiles then
            local d = 1.2*self.w
            for i = 1, 1+self.additional_homing_projectile do
                self.area:addGameObject('Projectile', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {r = self.r, attack = 'Homing', damage_multiplier = 2})
            end
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
        end
    end)

    if self.increased_luck_while_boosting then 
        self.luck_boosting = true 
        self.luck_multiplier = self.luck_multiplier*2
        self:generateChances()
    end

    if self.increased_cycle_speed_while_boosting then
        self.cycle_boosting = true
    end

    if self.invulnerability_while_boosting then
        self.invincible = true
        self.timer:every('invulnerability_while_boosting', 0.04, function() self.invisible = not self.invisible end)
    end
end

function Player:onBoostEnd()
    self.timer:cancel('launch_homing_projectile_while_boosting_chance')

    if self.increased_luck_while_boosting then 
        self.luck_boosting = false 
        self.luck_multiplier = self.luck_multiplier/2
        self:generateChances()
    end

    if self.increased_cycle_speed_while_boosting then
        self.cycle_boosting = false
    end

    if self.invulnerability_while_boosting then
        self.invincible = false
        self.invisible = false
        self.timer:cancel('invulnerability_while_boosting')
    end
end

function Player:insertSapper(id)
    if not self.sappers[id] then
        local sap_type = table.random({'ASPD', 'PSPD', 'MVSPD', 'Cycle'})
        self.sappers[id] = sap_type
        if sap_type == 'ASPD' then self.area:addGameObject('InfoText', self.x, self.y, {text = 'ASPD Decrease!'})
        elseif sap_type == 'PSPD' then self.area:addGameObject('InfoText', self.x, self.y, {text = 'PSPD Decrease!'})
        elseif sap_type == 'MVSPD' then self.area:addGameObject('InfoText', self.x, self.y, {text = 'MVSPD Decrease!'})
        elseif sap_type == 'Cycle' then self.area:addGameObject('InfoText', self.x, self.y, {text = 'Cycle Decrease!'}) end
    end
end

function Player:removeSapper(id)
    self.sappers[id] = nil
end

function Player:barrage(barrage_nova)
    if self.barrage_timer < self.barrage_cooldown then return end
    self.barrage_timer = 0

    for i = 1, 8+self.additional_barrage_projectile do
        self.timer:after((i-1)*0.05, function()
            local random_angle = random(-math.pi/8, math.pi/8)
            if self.barrage_nova or barrage_nova then random_angle = random(0, 2*math.pi) end
            local d = 2.2*self.w
            self.area:addGameObject('Projectile', self.x + d*math.cos(self.r + random_angle), self.y + d*math.sin(self.r + random_angle), 
            {r = self.r + random_angle, attack = self.attack, damage_multiplier = 0.5})
        end)
    end
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Barrage!!!'})
end

function Player:setStats()
    -- Conversions
    if self.mvspd_to_hp > 0 then
        if self.mvspd_multiplier.value < 1 then
            self.flat_hp = self.flat_hp + self.mvspd_multiplier.value*self.mvspd_to_hp
        end
    end

    -- Basic stats
    self.max_hp = (self.max_hp + self.flat_hp)*self.hp_multiplier
    self.hp = self.max_hp
    self.max_ammo = (self.max_ammo + self.flat_ammo)*self.ammo_multiplier
    self.ammo = self.max_ammo
    self.max_boost = (self.max_boost + self.flat_boost)*self.boost_multiplier
    self.boost = self.max_boost

    -- Start with attack
    local starting_attacks = {
        self.start_with_double and 'Double', self.start_with_triple and 'Triple', self.start_with_rapid and 'Rapid', self.start_with_spread and 'Spread', self.start_with_back and 'Back',
        self.start_with_side and 'Side', self.start_with_homing and 'Homing', self.start_with_blast and 'Blast', self.start_with_spin and 'Spin', self.start_with_lightning and 'Lightning',
        self.start_with_flame and 'Flame', self.start_with_2split and '2Split', self.start_with_4split and '4Split', self.start_with_explode and 'Explode', self.start_with_laser and 'Laser',
    }
    starting_attacks = fn.select(starting_attacks, function(k, v) return v end)
    if #starting_attacks > 0 then self:setAttack(table.random(starting_attacks)) end

    -- Passives
    if self.energy_shield then
        self.invulnerability_time_multiplier = self.invulnerability_time_multiplier/2
    end

    if self.no_boost then
        self.max_boost = 0
        self.boost = self.max_boost
    end

    if self.half_ammo then
        self.max_ammo = math.ceil(self.max_ammo/2)
        self.ammo = self.max_ammo
    end

    if self.half_hp then
        self.max_hp = math.ceil(self.max_hp/2)
        self.hp = self.max_hp
    end

    if self.projectile_waviness_multiplier > 1 then self.wavy_projectiles = true end
    if self.pspd_multiplier.value < 0 then self.pspd_multiplier.base = 0 end
end

function Player:setClass(class)
    local classes = {}
    classes[class] = true

    if classes.cycler then
        self.luck_multiplier = self.luck_multiplier + 0.25
        self.cycle_multiplier = Stat(self.cycle_multiplier.value + 0.25)
    end

    if classes.tanker then
        self.max_hp = math.floor(self.max_hp*1.25)
        self.hp = self.max_hp
        self.max_ammo = math.floor(self.max_ammo*1.25)
        self.ammo = self.max_ammo
    end

    if classes.gunner then
        self.aspd_multiplier = Stat(self.aspd_multiplier.value + 0.15)
        self.pspd_multiplier = Stat(self.pspd_multiplier.value + 0.25)
    end

    if classes.runner then
        self.mvspd_multiplier = Stat(self.mvspd_multiplier.value + 0.25)
        self.max_boost = math.floor(self.max_boost*1.25)
        self.boost = self.max_boost
    end

    if classes.swapper then
        self.gain_stat_boost_on_attack_change = true
        self.max_hp = math.floor(self.max_hp*0.90)
        self.hp = self.max_hp
        self.max_ammo = math.floor(self.max_ammo*0.90)
        self.ammo = self.max_ammo
        self.mvspd_multiplier = Stat(self.mvspd_multiplier.value - 0.1)
        self.pspd_multiplier = Stat(self.pspd_multiplier.value - 0.1)
    end

    if classes.barrager then
        self.barrage_on_kill_chance = self.barrage_on_kill_chance + 5
        self.barrage_on_cycle_chance = self.barrage_on_cycle_chance + 10
        self.additional_barrage_projectile = self.additional_barrage_projectile + 2
        self.cant_launch_homing_projectiles = true
        self.aspd_multiplier = Stat(self.aspd_multiplier.value - 0.25)
    end

    if classes.seeker then
        self.launch_homing_projectile_on_kill_chance = self.launch_homing_projectile_on_kill_chance + 10
        self.launch_homing_projectile_on_cycle_chance = self.launch_homing_projectile_on_cycle_chance + 5
        self.additional_homing_projectile = self.additional_homing_projectile + 1
        self.cant_barrage = true
        self.aspd_multiplier = Stat(self.aspd_multiplier.value - 0.25)
    end

    if classes.shielder then
        self.shield_projectile_chance = self.shield_projectile_chance + 25
        self.projectile_duration_multiplier = self.projectile_duration_multiplier + 0.25
        self.shield_projectile_damage_multiplier = 0.75
    end

    if classes.regeneer then
        self.item_restores_hp = true
        self.mvspd_multiplier = Stat(self.mvspd_multiplier.value - 0.25)
    end

    if classes.recycler then
        self.protective_barrier_when_no_ammo = true
        self.ammo_consumption_multiplier = self.ammo_consumption_multiplier + 0.5
    end

    if classes.buster then
        self.projectile_size_multiplier = self.projectile_size_multiplier + 0.5
        self.projectile_duration_multiplier = self.projectile_duration_multiplier + 0.25
        self.max_hp = math.floor(self.max_hp*0.85)
        self.hp = self.max_hp
        self.aspd_multiplier = Stat(self.aspd_multiplier.value - 0.15)
    end

    if classes.buffer then
        self.stat_boost_duration_multiplier = self.stat_boost_duration_multiplier + 0.5
        self.max_boost = math.floor(self.max_boost*0.80)
        self.boost = self.max_boost
    end

    if classes.berserker then
        self.rampage = true
        self.luck_multiplier = self.luck_multiplier - 0.25
    end

    if classes.absorber then
        self.absorb_hits = true
    end

    if classes.turner then

    end

    if classes.driver then
        self.invulnerability_time_multiplier = self.invulnerability_time_multiplier + 0.3
        self.boost_recharge_rate_multiplier = self.boost_recharge_rate_multiplier + 0.3
        self.size_multiplier = self.size_multiplier + 0.3
    end

    if classes.processor then
        self.cycle_multiplier = Stat(self.cycle_multiplier.value + 0.5)
        self.max_hp = math.floor(self.max_hp*0.75)
        self.hp = self.max_hp
        self.sp_spawn_chance_multiplier = self.sp_spawn_chance_multiplier - 0.5
    end

    if classes.gambler then
        self.luck_multiplier = self.luck_multiplier + 0.5
        self.cant_trigger_on_cycle_events = true
    end

    if classes.panzer then
        self.max_hp = math.floor(self.max_hp*1.5)
        self.hp = self.max_hp
        self.size_multiplier = self.size_multiplier + 0.5
        self.mvspd_multiplier = Stat(self.mvspd_multiplier.value - 0.25)
    end

    if classes.reserver then
        self.max_ammo = math.floor(self.max_ammo*1.5)
        self.ammo = self.max_ammo
        self.aspd_multiplier = Stat(self.aspd_multiplier.value - 0.25)
        self.change_attack_when_no_ammo = true
    end

    if classes.repeater then
        self.aspd_multiplier = Stat(self.aspd_multiplier.value + 0.5)
        self.damage_multiplier = 0.75
    end

    if classes.launcher then
        self.pspd_multiplier = Stat(self.pspd_multiplier.value + 0.75)
        self.projectile_duration_multiplier = self.projectile_duration_multiplier + 0.25
        self.max_hp = math.floor(self.max_hp*0.8)
        self.hp = self.max_hp
        self.max_ammo = math.floor(self.max_ammo*0.8)
        self.ammo = self.max_ammo
    end

    if classes.deployer then
        self.mvspd_multiplier = Stat(self.mvspd_multiplier.value + 0.25)
        self.size_multiplier = self.size_multiplier - 0.25
        self.drop_mines_chance = self.drop_mines_chance + 15
    end

    if classes.booster then
        self.max_boost = math.floor(self.max_boost*1.5)
        self.boost = self.max_boost
        self.luck_multiplier = self.luck_multiplier - 0.25
        self.max_ammo = math.floor(self.max_ammo*0.75)
        self.ammo = self.max_ammo
    end

    if classes.piercer then
        self.projectile_pierce = self.projectile_pierce + 2
        self.max_hp = math.floor(self.max_hp*0.85)
        self.hp = self.max_hp
        self.max_ammo = math.floor(self.max_ammo*0.85)
        self.ammo = self.max_ammo
        self.max_boost = math.floor(self.max_boost*0.85)
        self.boost = self.max_boost
        self.aspd_multiplier = Stat(self.aspd_multiplier.value - 0.15)
        self.mvspd_multiplier = Stat(self.mvspd_multiplier.value - 0.15)
    end

    if classes.dasher then

    end

    if classes.engineer then
        self.max_ammo = math.floor(self.max_ammo*0.5)
        self.ammo = self.max_ammo
        self.area:addGameObject('Drone', self.x, self.y, {rd = -math.pi/2, player = self})
        self.area:addGameObject('Drone', self.x, self.y, {rd = math.pi/2, player = self})
    end

    if classes.threader then
        self.cycle_timer_2 = 0
        self.cycle_cooldown_2 = 5
        self.cycle_timer_3 = 0
        self.cycle_cooldown_3 = 5
        self.cycle_timer_4 = 0
        self.cycle_cooldown_4 = 5
    end
end

function Player:setClasses()
    if fn.any(classes, 'Gunner') then self.gunner = true end
    if fn.any(classes, 'Runner') then self.runner = true end
    if fn.any(classes, 'Cycler') then self.cycler = true end
    if fn.any(classes, 'Tanker') then self.tanker = true end
    if fn.any(classes, 'Swapper') then self.swapper = true end
    if fn.any(classes, 'Barrager') then self.barrager = true end
    if fn.any(classes, 'Seeker') then self.seeker = true end
    if fn.any(classes, 'Shielder') then self.shielder = true end
    if fn.any(classes, 'Regeneer') then self.regeneer = true end
    if fn.any(classes, 'Recycler') then self.recycler = true end
    if fn.any(classes, 'Buster') then self.buster = true end
    if fn.any(classes, 'Buffer') then self.buffer = true end
    if fn.any(classes, 'Berserker') then self.berserker = true end
    if fn.any(classes, 'Absorber') then self.absorber = true end
    if fn.any(classes, 'Turner') then self.turner = true end
    if fn.any(classes, 'Driver') then self.driver = true end
    if fn.any(classes, 'Processor') then self.processor = true end
    if fn.any(classes, 'Panzer') then self.panzer = true end
    if fn.any(classes, 'Reserver') then self.reserver = true end
    if fn.any(classes, 'Gambler') then self.gambler = true end
    if fn.any(classes, 'Repeater') then self.repeater = true end
    if fn.any(classes, 'Launcher') then self.launcher = true end
    if fn.any(classes, 'Deployer') then self.deployer = true end
    if fn.any(classes, 'Booster') then self.booster = true end
    if fn.any(classes, 'Discharger') then self.discharger = true end
    if fn.any(classes, 'Hoamer') then self.hoamer = true end
    if fn.any(classes, 'Splitter') then self.splitter = true end
    if fn.any(classes, 'Spinner') then self.spinner = true end
    if fn.any(classes, 'Bouncer') then self.bouncer = true end
    if fn.any(classes, 'Blaster') then self.blaster = true end
    if fn.any(classes, 'Raider') then self.raider = true end
    if fn.any(classes, 'Waver') then self.waver = true end
    if fn.any(classes, 'Bomber') then self.bomber = true end
    if fn.any(classes, 'Zoomer') then self.zoomer = true end
    if fn.any(classes, 'Racer') then self.racer = true end
    if fn.any(classes, 'Miner') then self.miner = true end
    if fn.any(classes, 'Piercer') then self.piercer = true end
    if fn.any(classes, 'Dasher') then self.dasher = true end
    if fn.any(classes, 'Engineer') then self.engineer = true end
    if fn.any(classes, 'Threader') then self.threader = true end

    if self.cycler then
        self.luck_multiplier = self.luck_multiplier + 0.25
        self.cycle_multiplier = Stat(self.cycle_multiplier.value + 0.25)
    end

    if self.tanker then
        self.max_hp = math.floor(self.max_hp*1.25)
        self.hp = self.max_hp
        self.max_ammo = math.floor(self.max_ammo*1.25)
        self.ammo = self.max_ammo
    end

    if self.gunner then
        self.aspd_multiplier = Stat(self.aspd_multiplier.value + 0.15)
        self.pspd_multiplier = Stat(self.pspd_multiplier.value + 0.25)
    end

    if self.runner then
        self.mvspd_multiplier = Stat(self.mvspd_multiplier.value + 0.25)
        self.max_boost = math.floor(self.max_boost*1.25)
        self.boost = self.max_boost
    end

    if self.swapper then
        self.gain_stat_boost_on_attack_change = true
        self.max_hp = math.floor(self.max_hp*0.90)
        self.hp = self.max_hp
        self.max_ammo = math.floor(self.max_ammo*0.90)
        self.ammo = self.max_ammo
        self.mvspd_multiplier = Stat(self.mvspd_multiplier.value - 0.1)
        self.pspd_multiplier = Stat(self.pspd_multiplier.value - 0.1)
    end

    if self.barrager then
        self.barrage_on_kill_chance = self.barrage_on_kill_chance + 5
        self.barrage_on_cycle_chance = self.barrage_on_cycle_chance + 10
        self.additional_barrage_projectile = self.additional_barrage_projectile + 2
        self.cant_launch_homing_projectiles = true
        self.aspd_multiplier = Stat(self.aspd_multiplier.value - 0.25)
    end

    if self.seeker then
        self.launch_homing_projectile_on_kill_chance = self.launch_homing_projectile_on_kill_chance + 10
        self.launch_homing_projectile_on_cycle_chance = self.launch_homing_projectile_on_cycle_chance + 5
        self.additional_homing_projectile = self.additional_homing_projectile + 1
        self.cant_barrage = true
        self.aspd_multiplier = Stat(self.aspd_multiplier.value - 0.25)
    end

    if self.shielder then
        self.shield_projectile_chance = self.shield_projectile_chance + 25
        self.projectile_duration_multiplier = self.projectile_duration_multiplier + 0.25
        self.shield_projectile_damage_multiplier = 0.75
    end

    if self.regeneer then
        self.item_restores_hp = true
        self.mvspd_multiplier = Stat(self.mvspd_multiplier.value - 0.15)
    end

    if self.recycler then
        self.protective_barrier_when_no_ammo = true
        self.ammo_consumption_multiplier = self.ammo_consumption_multiplier + 0.5
    end

    if self.buster then
        self.projectile_size_multiplier = self.projectile_size_multiplier + 0.5
        self.projectile_duration_multiplier = self.projectile_duration_multiplier + 0.25
        self.max_hp = math.floor(self.max_hp*0.85)
        self.hp = self.max_hp
        self.aspd_multiplier = Stat(self.aspd_multiplier.value - 0.15)
    end

    if self.buffer then
        self.stat_boost_duration_multiplier = self.stat_boost_duration_multiplier + 0.5
        self.max_boost = math.floor(self.max_boost*0.80)
        self.boost = self.max_boost
    end

    if self.berserker then
        self.rampage = true
        self.luck_multiplier = self.luck_multiplier - 0.25
    end

    if self.absorber then
        self.absorb_hits = true
    end

    if self.turner then

    end

    if self.driver then
        self.invulnerability_time_multiplier = self.invulnerability_time_multiplier + 0.3
        self.boost_recharge_rate_multiplier = self.boost_recharge_rate_multiplier + 0.3
        self.size_multiplier = self.size_multiplier + 0.3
    end

    if self.processor then
        self.cycle_multiplier = Stat(self.cycle_multiplier.value + 0.5)
        self.max_hp = math.floor(self.max_hp*0.75)
        self.hp = self.max_hp
        self.sp_spawn_chance_multiplier = self.sp_spawn_chance_multiplier - 0.5
    end

    if self.gambler then
        self.luck_multiplier = self.luck_multiplier + 0.5
        self.cant_trigger_on_cycle_events = true
    end

    if self.panzer then
        self.max_hp = math.floor(self.max_hp*1.5)
        self.hp = self.max_hp
        self.size_multiplier = self.size_multiplier + 0.5
        self.mvspd_multiplier = Stat(self.mvspd_multiplier.value - 0.25)
    end

    if self.reserver then
        self.max_ammo = math.floor(self.max_ammo*1.5)
        self.ammo = self.max_ammo
        self.aspd_multiplier = Stat(self.aspd_multiplier.value - 0.25)
        self.change_attack_when_no_ammo = true
    end

    if self.repeater then
        self.aspd_multiplier = Stat(self.aspd_multiplier.value + 0.5)
        self.damage_multiplier = 0.75
    end

    if self.launcher then
        self.pspd_multiplier = Stat(self.pspd_multiplier.value + 0.75)
        self.projectile_duration_multiplier = self.projectile_duration_multiplier + 0.25
        self.max_hp = math.floor(self.max_hp*0.8)
        self.hp = self.max_hp
        self.max_ammo = math.floor(self.max_ammo*0.8)
        self.ammo = self.max_ammo
    end

    if self.deployer then
        self.mvspd_multiplier = Stat(self.mvspd_multiplier.value + 0.25)
        self.size_multiplier = self.size_multiplier - 0.25
        self.drop_mines_chance = self.drop_mines_chance + 25
    end

    if self.booster then
        self.max_boost = math.floor(self.max_boost*1.5)
        self.boost = self.max_boost
        self.luck_multiplier = self.luck_multiplier - 0.25
        self.max_ammo = math.floor(self.max_ammo*0.75)
        self.ammo = self.max_ammo
    end

    if self.discharger then
        self.lightning_targets_projectiles = true
        self.additional_lightning_bolt = self.additional_lightning_bolt + 2
        self.lightning_trigger_distance_multiplier = self.lightning_trigger_distance_multiplier + 0.5
    end

    if self.hoamer then
        self.homing_speed_multiplier = self.homing_speed_multiplier + 0.5
        self.double_homing = true
        self.attack_twice_chance = self.attack_twice_chance + 10
    end

    if self.splitter then
        self.split_projectiles_split_chance = self.split_projectiles_split_chance + 15
        self.pspd_multiplier = Stat(self.pspd_multiplier.value + 0.25)
    end

    if self.spinner then
        self.projectile_duration_multiplier = self.projectile_duration_multiplier + 0.25
        self.spin_projectile_on_expiration_chance = self.spin_projectile_on_expiration_chance + 50
    end

    if self.bouncer then
        self.additional_bounce = self.additional_bounce + 4
        self.pspd_multiplier = Stat(self.pspd_multiplier.value - 0.5)
    end

    if self.blaster then
        self.additional_blast_projectile = self.additional_blast_projectile + 8
        self.blast_shield = true
    end

    if self.raider then
        self.sp_spawn_chance_multiplier = self.sp_spawn_chance_multiplier + 1
    end

    if self.waver then
        self.projectile_waviness_multiplier = self.projectile_waviness_multiplier + 0.5
        self.projectile_angle_change_frequency_multiplier = self.projectile_angle_change_frequency_multiplier + 0.5
    end

    if self.bomber then
        self.area_multiplier = self.area_multiplier + 0.25
        self.attack_twice_chance = self.attack_twice_chance + 0.25
    end

    if self.zoomer then
        self.mvspd_multiplier = Stat(self.mvspd_multiplier.value + 0.30)
        self.size_multiplier = self.size_multiplier - 0.30
    end

    if self.racer then
        self.ammo_gives_boost = true
        self.max_ammo = math.floor(self.max_ammo*0.5)
        self.ammo = self.max_ammo
    end

    if self.miner then
        self.resource_spawn_rate_multiplier = self.resource_spawn_rate_multiplier + 0.5
        self.item_spawn_rate_multiplier = self.item_spawn_rate_multiplier + 0.25
    end

    if self.piercer then
        self.projectile_pierce = self.projectile_pierce + 2
        self.max_hp = math.floor(self.max_hp*0.85)
        self.hp = self.max_hp
        self.max_ammo = math.floor(self.max_ammo*0.85)
        self.ammo = self.max_ammo
        self.max_boost = math.floor(self.max_boost*0.85)
        self.boost = self.max_boost
        self.aspd_multiplier = Stat(self.aspd_multiplier.value - 0.15)
        self.mvspd_multiplier = Stat(self.mvspd_multiplier.value - 0.15)
    end

    if self.dasher then

    end

    if self.engineer then
        self.max_ammo = math.floor(self.max_ammo*0.5)
        self.ammo = self.max_ammo
        self.area:addGameObject('Drone', self.x, self.y, {rd = -math.pi/2, player = self})
        self.area:addGameObject('Drone', self.x, self.y, {rd = math.pi/2, player = self})
    end

    if self.threader then
        self.cycle_timer_2 = 0
        self.cycle_cooldown_2 = 5
        self.cycle_timer_3 = 0
        self.cycle_cooldown_3 = 5
        self.cycle_timer_4 = 0
        self.cycle_cooldown_4 = 5
    end
end

function Player:setShip()
    if self.ship == 'Fighter' then

    elseif self.ship == 'Crusader' then
        self.max_boost = 80
        self.boost = self.max_boost
        self.boost_effectiveness_multiplier = 2
        self.mvspd_multiplier = Stat(0.6)
        self.turn_rate_multiplier = 0.5
        self.aspd_multiplier = Stat(0.65)
        self.pspd_multiplier = Stat(1.5)
        self.max_hp = 150
        self.hp = self.max_hp
        self.size_multiplier = 1.5

    elseif self.ship == 'Rogue' then
        self.max_boost = 120
        self.boost = self.max_boost
        self.boost_recharge_rate_multiplier = 1
        self.mvspd_multiplier = Stat(1.3)
        self.max_ammo = 120
        self.ammo = self.max_ammo
        self.aspd_multiplier = Stat(1.25)
        self.max_hp = 80
        self.hp = self.max_hp
        self.invulnerability_time_multiplier = 0.5
        self.size_multiplier = 0.9

    elseif self.ship == 'Bit Hunter' then
        self.mvspd_multiplier = Stat(0.9)
        self.turn_rate_multiplier = 0.8
        self.max_ammo = 80
        self.ammo = self.max_ammo
        self.aspd_multiplier = Stat(0.8)
        self.pspd_multiplier = Stat(0.9)
        self.invulnerability_time_multiplier = 1.5
        self.size_multiplier = 1.1
        self.luck_multiplier = 1.5
        self.resource_spawn_rate_multiplier = 1.5
        self.item_spawn_rate_multiplier = 1.5
        self.cycle_multiplier = Stat(1.25)

    elseif self.ship == 'Sentinel' then
        self.energy_shield = true

    elseif self.ship == 'Striker' then
        self.max_ammo = 120
        self.ammo = self.max_ammo
        self.aspd_multiplier = Stat(2)
        self.pspd_multiplier = Stat(1.25)
        self.max_hp = 50
        self.hp = self.max_hp
        self.additional_barrage_projectile = 8
        self.barrage_nova = true
        self.barrage_on_kill_chance = 10
        self.barrage_on_cycle_chance = 10

    elseif self.ship == 'Nuclear' then
        self.max_boost = 80
        self.boost= self.max_boost
        self.turn_rate_multiplier = 0.8
        self.max_ammo = 80
        self.ammo = self.max_ammo
        self.aspd_multiplier = Stat(0.85)
        self.max_hp = 80
        self.hp = self.max_hp
        self.invulnerability_time_multiplier = 2
        self.luck_multiplier = 1.5
        self.resource_spawn_rate_multiplier = 1.5
        self.item_spawn_rate_multiplier = 1.5
        self.cycle_multiplier = Stat(1.5)
        self.self_explode_on_cycle_chance = 25

    elseif self.ship == 'Cycler' then
        self.cycle_multiplier = Stat(2)

    elseif self.ship == 'Wisp' then
        self.max_boost = 50
        self.boost = self.max_boost
        self.mvspd_multiplier = Stat(0.5)
        self.turn_rate_multiplier = 0.5
        self.aspd_multiplier = Stat(0.65)
        self.pspd_multiplier = Stat(0.5)
        self.max_hp = 50
        self.hp = self.max_hp
        self.size_multiplier = 0.75
        self.resource_spawn_rate_multiplier = 1.5
        self.item_spawn_rate_multiplier = 1.5
        self.shield_projectile_chance = 100
        self.projectile_duration_multiplier = 1.5
    end
end

function Player:generateChances()
	self.chances = {}
  	for k, v in pairs(self) do
    	if k:find('_chance') and type(v) == 'number' then
            if k:find('_on_kill') and v > 0 then
                self.chances[k] = chanceList({true, math.ceil(self.luck_multiplier*(v+self.added_chance_to_all_on_kill_events))}, 
                {false, 100-math.ceil(self.luck_multiplier*(v+self.added_chance_to_all_on_kill_events))})
            else
                if k:find('sp') and v > 0 and self.raider then
                    self.chances[k] = chanceList({true, math.ceil(1.5*self.luck_multiplier*v)}, {false, 100-math.ceil(1.5*self.luck_multiplier*v)})
                else
                    self.chances[k] = chanceList({true, math.ceil(self.luck_multiplier*v)}, {false, 100-math.ceil(self.luck_multiplier*v)})
                end
            end
      	end
    end
end


function Player:shipVisuals()
    if self.ship == 'Fighter' then
        self.polygons[1] = {
            self.w, 0,
            self.w/2, -self.w/2,
            -self.w/2, -self.w/2,
            -self.w, 0,
            -self.w/2, self.w/2,
            self.w/2, self.w/2,
        }

        self.polygons[2] = {
            self.w/2, -self.w/2,
            0, -self.w,
            -self.w - self.w/2, -self.w,
            -3*self.w/4, -self.w/4,
            -self.w/2, -self.w/2,
        }

        self.polygons[3] = {
            self.w/2, self.w/2,
            -self.w/2, self.w/2,
            -3*self.w/4, self.w/4,
            -self.w - self.w/2, self.w,
            0, self.w,
        }

    elseif self.ship == 'Crusader' then
        self.polygons[1] = {
            self.w, 0,
            self.w/2, self.w/2,
            -self.w/4, self.w/2,
            -self.w/2, self.w/4,
            -self.w/2, -self.w/4,
            -self.w/4, -self.w/2,
            self.w/2, -self.w/2,
        }

        self.polygons[2] = {
            self.w/2, self.w/2,
            self.w/2, self.w,
            -self.w/2, self.w,
            -self.w, self.w/2,
            -self.w, 0,
            -self.w/2, 0,
            -self.w/2, self.w/4,
            -self.w/4, self.w/2,
        }

        self.polygons[3] = {
            self.w/2, -self.w/2,
            self.w/2, -self.w,
            -self.w/2, -self.w,
            -self.w, -self.w/2,
            -self.w, 0,
            -self.w/2, 0,
            -self.w/2, -self.w/4,
            -self.w/4, -self.w/2,
        }

    elseif self.ship == 'Rogue' then
        self.polygons[1] = {
            self.w, 0,
            0, -self.w/2,
            -self.w, 0,
            0, self.w/2,
        }

        self.polygons[2] = {
            self.w/2, -self.w/4,
            self.w/4, -3*self.w/4,
            -self.w - self.w/2, -2*self.w,
            -self.w/2, -self.w/4,
            0, -self.w/2,
        }

        self.polygons[3] = {
            self.w/2, self.w/4,
            0, self.w/2,
            -self.w/2, self.w/4,
            -self.w - self.w/2, 2*self.w,
            self.w/4, 3*self.w/4,
        }

    elseif self.ship == 'Bit Hunter' then
        self.polygons[1] = {
            self.w, 0,
            self.w/2, -self.w/2,
            -self.w, -self.w/2,
            -self.w/2, 0,
            -self.w, self.w/2,
            self.w/2, self.w/2,
        }

    elseif self.ship == 'Sentinel' then
        self.polygons[1] = {
            self.w, 0,
            0, -self.w,
            -3*self.w/4, -3*self.w/4,
            -self.w, 0,
            -3*self.w/4, 3*self.w/4,
            0, self.w,
        }

    elseif self.ship == 'Striker' then
        self.polygons[1] = {
            self.w, 0,
            self.w/2, -self.w/2,
            -self.w/2, -self.w/2,
            -self.w, 0,
            -self.w/2, self.w/2,
            self.w/2, self.w/2,
        }

        self.polygons[2] = {
            0, self.w/2,
            -self.w/4, self.w,
            0, self.w + self.w/2,
            self.w, self.w,
            0, 2*self.w,
            -self.w/2, self.w + self.w/2,
            -self.w, 0,
            -self.w/2, self.w/2,
        }

        self.polygons[3] = {
            0, -self.w/2,
            -self.w/4, -self.w,
            0, -self.w - self.w/2,
            self.w, -self.w,
            0, -2*self.w,
            -self.w/2, -self.w - self.w/2,
            -self.w, 0,
            -self.w/2, -self.w/2,
        }

    elseif self.ship == 'Nuclear' then
        self.polygons[1] = {
            self.w, -self.w/4,
            self.w, self.w/4,
            self.w - self.w/4, self.w/2,
            -self.w + self.w/4, self.w/2,
            -self.w, self.w/4,
            -self.w, -self.w/4,
            -self.w + self.w/4, -self.w/2,
            self.w - self.w/4, -self.w/2,
        }

    elseif self.ship == 'Cycler' then
        self.polygons[1] = {
            self.w, 0,
            0, self.w,
            -self.w, 0,
            0, -self.w,
        }

    elseif self.ship == 'Wisp' then
        self.polygons[1] = {
            self.w, -self.w/4,
            self.w, self.w/4,
            self.w/4, self.w,
            -self.w/4, self.w,
            -self.w, self.w/4,
            -self.w, -self.w/4,
            -self.w/4, -self.w,
            self.w/4, -self.w,
        }
    end

end

function Player:boostTrails()
    self.trail_color = skill_point_color 
    self.timer:every(0.01, function() 
        if self.ship == 'Fighter' then
            self.area:addGameObject('TrailParticle', 
            self.x - 1.0*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r - math.pi/2), 
            self.y - 1.0*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r - math.pi/2), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25), color = self.trail_color}) 
            self.area:addGameObject('TrailParticle', 
            self.x - 1.0*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r + math.pi/2), 
            self.y - 1.0*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r + math.pi/2), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25), color = self.trail_color}) 

        elseif self.ship == 'Crusader' then
            self.area:addGameObject('TrailParticle', 
            self.x - 1.2*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r - math.pi/2), 
            self.y - 1.2*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r - math.pi/2), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25), color = self.trail_color}) 
            self.area:addGameObject('TrailParticle', 
            self.x - 1.2*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r + math.pi/2), 
            self.y - 1.2*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r + math.pi/2), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25), color = self.trail_color}) 

        elseif self.ship == 'Bit Hunter' then
            self.area:addGameObject('TrailParticle', 
            self.x - 0.8*self.w*math.cos(self.r), self.y - 0.8*self.w*math.sin(self.r), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.1, 0.2), color = self.trail_color}) 

        elseif self.ship == 'Rogue' then
            self.area:addGameObject('TrailParticle', 
            self.x - 0.7*self.w*math.cos(self.r) + 0.4*self.w*math.cos(self.r - math.pi/2), 
            self.y - 0.7*self.w*math.sin(self.r) + 0.4*self.w*math.sin(self.r - math.pi/2), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25), color = self.trail_color}) 
            self.area:addGameObject('TrailParticle', 
            self.x - 0.7*self.w*math.cos(self.r) + 0.4*self.w*math.cos(self.r + math.pi/2), 
            self.y - 0.7*self.w*math.sin(self.r) + 0.4*self.w*math.sin(self.r + math.pi/2), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25), color = self.trail_color}) 

        elseif self.ship == 'Sentinel' then
            self.area:addGameObject('TrailParticle', 
            self.x - 1.0*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r - math.pi/2), 
            self.y - 1.0*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r - math.pi/2), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25), color = self.trail_color}) 
            self.area:addGameObject('TrailParticle', 
            self.x - 1.0*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r + math.pi/2), 
            self.y - 1.0*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r + math.pi/2), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25), color = self.trail_color}) 

        elseif self.ship == 'Striker' then
            self.area:addGameObject('TrailParticle', 
            self.x - 1.0*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r - math.pi/2), 
            self.y - 1.0*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r - math.pi/2), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25), color = self.trail_color}) 
            self.area:addGameObject('TrailParticle', 
            self.x - 1.0*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r + math.pi/2), 
            self.y - 1.0*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r + math.pi/2), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25), color = self.trail_color}) 

        elseif self.ship == 'Nuclear' then
            self.area:addGameObject('TrailParticle', 
            self.x - 1*self.w*math.cos(self.r), self.y - 1*self.w*math.sin(self.r), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.1, 0.2), color = self.trail_color}) 

        elseif self.ship == 'Cycler' then
            self.area:addGameObject('TrailParticle', 
            self.x - 1*self.w*math.cos(self.r), self.y - 1*self.w*math.sin(self.r), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.1, 0.2), color = self.trail_color}) 

            self.area:addGameObject('TrailParticle', 
            self.x - 0.8*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r - math.pi/2), 
            self.y - 0.8*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r - math.pi/2), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25), color = self.trail_color}) 

            self.area:addGameObject('TrailParticle', 
            self.x - 0.8*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r + math.pi/2), 
            self.y - 0.8*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r + math.pi/2), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25), color = self.trail_color}) 

        elseif self.ship == 'Wisp' then
            self.area:addGameObject('TrailParticle', 
            self.x - 1*self.w*math.cos(self.r), self.y - 1*self.w*math.sin(self.r), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.1, 0.15), color = self.trail_color}) 
        end
    end)
end
