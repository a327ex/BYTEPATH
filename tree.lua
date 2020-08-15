function treeToPlayer(player)
    local approved_list = {
        'increased_cycle_speed_while_boosting', 'invulnerability_while_boosting', 'increased_luck_while_boosting', 'projectile_ninety_degree_change', 'projectile_random_degree_change', 'wavy_projectiles', 
        'fast_slow', 'slow_fast', 'energy_shield', 'barrage_nova', 'projectiles_explode_on_expiration', 'lesser_increased_self_explosion_size', 'greater_increased_self_explosion_size', 
        'projectiles_explosions', 'change_attack_periodically', 'gain_sp_on_death', 'convert_hp_to_sp_if_hp_full', 'no_boost', 'half_ammo', 'half_hp', 'deals_damage_while_invulnerable', 
        'refill_ammo_if_hp_full', 'refill_boost_if_hp_full', 'only_spawn_boost', 'only_spawn_attack', 'no_ammo_drop', 'infinite_ammo', 'fixed_spin_direction', 'start_with_double', 'start_with_triple', 
        'start_with_rapid', 'start_with_spread', 'start_with_back', 'start_with_side', 'start_with_homing', 'start_with_blast', 'start_with_spin', 'start_with_lightning', 'start_with_flame', 
        'start_with_2split', 'start_with_4split', 'start_with_explode', 'start_with_laser', 'start_with_bounce'
    }

    local all_attributes = {}
    local positives = {}
    local negatives = {}
    for _, index in ipairs(bought_node_indexes) do
        if tree[index] then
            local stats = tree[index].stats
            for i = 1, #stats, 3 do
                local attribute, value = stats[i+1], stats[i+2]
                if not player[attribute] and not fn.any(approved_list, attribute) then error('No attribute "' .. attribute .. '"') end
                if not positives[attribute] then positives[attribute] = 0 end
                if not negatives[attribute] then negatives[attribute] = 0 end
                if type(player[attribute]) == 'number' then
                    if value > 0 then positives[attribute] = positives[attribute] + value
                    else negatives[attribute] = negatives[attribute] + value end
                    player[attribute] = player[attribute] + value
                elseif type(player[attribute]) == 'boolean' then
                    player[attribute] = value
                elseif player[attribute]:is(Stat) then
                    if value > 0 then positives[attribute] = positives[attribute] + value
                    else negatives[attribute] = negatives[attribute] + value end
                    local v = player[attribute].value
                    player[attribute] = Stat(v + value)
                end
                if not fn.any(all_attributes, attribute) then table.insert(all_attributes, attribute) end
            end
        end
    end

    for _, attribute in ipairs(all_attributes) do
        if type(player[attribute]) == 'number' or type(player[attribute]) == 'boolean' then
            print(attribute, player[attribute], positives[attribute], negatives[attribute])
        else print(attribute, player[attribute].value, positives[attribute], negatives[attribute]) end
    end
end

local s = 12
tree = {}

types = {
    ['HP'] = {'HP', red}, ['ASPD'] = {'S', green}, ['Luck'] = {'L', pink}, ['Homing'] = {'H', yellow}, 
    ['Conversion'] = {'C', pink}, ['Cycle'] = {'C', white}, ['Attack'] = {'A', orange}, ['Enemy'] = {'E', red},
    ['Resource'] = {'R', green}, ['PSPD'] = {'P', green}, ['Barrage'] = {'B', yellow}, ['Kill'] = {'K', gray}, 
    ['ES'] = {'ES', white}, ['Buff'] = {'B', purple}, ['MVSPD'] = {'M', dark}, ['Proj'] = {'P', bluegreen}, 
    ['Turn Rate'] = {'T', brown}, ['Boost'] = {'B', blue}, ['Size'] = {'S', blue}, ['Invuln'] = {'I', white}, 
    ['SP'] = {'SP', yellow}, ['Special'] = {'X', white}, ['Area'] = {'A', red}, ['Ammo'] = {'A', green}, ['Item'] = {'I', white},
}

tree[1] = {x = 30, y = 90, types = {}, stats = {}, links = {2, 3, 5, 4}, size = 3}
tree[2] = {x = 30, y = 30, types = {'HP'}, stats = {'6% Increased HP', 'hp_multiplier', 0.06}, links = {1, 6, 12}, size = 2}
tree[3] = {x = -30, y = 90, types = {'ASPD'}, stats = {'10% Increased Attack Speed', 'aspd_multiplier', 0.10}, links = {1, 93, 99}, size = 2}
tree[4] = {x = 90, y = 90, types = {'Luck'}, stats = {'10% Increased Luck', 'luck_multiplier', 0.10}, links = {1, 258, 261}, size = 2}
tree[5] = {x = 30, y = 150, types = {'MVSPD'}, stats = {'10% Increased Movement Speed', 'mvspd_multiplier', 0.10}, links = {1, 183, 186}, size = 2}
tree[6] = {x = -6, y = -6, types = {'Ammo'}, stats = {'4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {2, 7}, size = 1}
tree[7] = {x = -30, y = -30, types = {'Ammo'}, stats = {'8% Increased Ammo', 'ammo_multiplier', 0.04}, links = {6, 8, 71}, size = 1}
tree[8] = {x = -6, y = -54, types = {'Ammo'}, stats = {'4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {7, 15}, size = 1}
tree[12] = {x = 66, y = -6, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {13, 2}, size = 1}
tree[13] = {x = 90, y = -30, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {14, 12, 88}, size = 1}
tree[14] = {x = 66, y = -54, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {15, 13}, size = 1}
tree[15] = {x = 30, y = -90, types = {'Ammo', 'HP'}, stats = {'+10 Max Ammo', 'flat_ammo', 10, '+10 Max HP', 'flat_hp', 10}, links = {8, 14, 18, 30, 16, 17}, size = 2}
tree[16] = {x = -90, y = -90, types = {'Ammo'}, stats = {'4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {15, 46}, size = 1}
tree[17] = {x = 150, y = -90, types = {'Ammo'}, stats = {'4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {15, 59}, size = 1}
tree[18] = {x = -30, y = -150, types = {'Ammo'}, stats = {'+0.5 Ammo Gain', 'ammo_gain', 0.5}, links = {15, 19, 21}, size = 1}
tree[19] = {x = -6, y = -174, types = {'Ammo'}, stats = {'+0.5 Ammo Gain', 'ammo_gain', 0.5, '+5 Max Ammo', 'flat_ammo', 5}, links = {18, 20}, size = 1}
tree[20] = {x = -30, y = -198, types = {'Ammo'}, stats = {'+0.5 Ammo Gain', 'ammo_gain', 0.5, '6% Increased Ammo', 'ammo_multiplier', 0.06}, links = {19, 22, 21}, size = 1}
tree[21] = {x = -54, y = -174, types = {'Ammo'}, stats = {'+0.5 Ammo Gain', 'ammo_gain', 0.5, '4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {18, 20}, size = 1}
tree[22] = {x = -30, y = -234, types = {'Ammo'}, stats = {'8% Increased Ammo', 'ammo_multiplier', 0.08}, links = {20, 28, 23}, size = 1}
tree[23] = {x = -66, y = -270, types = {'Homing', 'Item'}, stats = {'8% Added Chance to Launch Homing Projectile on Item Pickup', 'launch_homing_projectile_on_item_pickup_chance', 8}, links = {22, 24}, size = 1}
tree[24] = {x = -66, y = -306, types = {'Homing', 'Item'}, stats = {'12% Added Chance to Launch Homing Projectile on Item Pickup', 'launch_homing_projectile_on_item_pickup_chance', 12}, links = {23, 25}, size = 1}
tree[25] = {x = -66, y = -342, types = {'Homing', 'Item'}, stats = {'20% Added Chance to Launch Homing Projectile on Item Pickup', 'launch_homing_projectile_on_item_pickup_chance', 20}, links = {24, 29}, size = 1}
tree[26] = {x = 6, y = -342, types = {'HP', 'Item'}, stats = {'12% Added Chance to Regain HP on Item Pickup', 'regain_hp_on_item_pickup_chance', 12}, links = {27, 29}, size = 1}
tree[27] = {x = 6, y = -306, types = {'HP', 'Item'}, stats = {'4% Added Chance to Regain HP on Item Pickup', 'regain_hp_on_item_pickup_chance', 4}, links = {28, 26}, size = 1}
tree[28] = {x = 6, y = -270, types = {'HP', 'Item'}, stats = {'4% Added Chance to Regain HP on Item Pickup', 'regain_hp_on_item_pickup_chance', 4}, links = {22, 27}, size = 1}
tree[29] = {x = -30, y = -378, types = {'ASPD', 'Item'}, stats = {'20% Added Chance to Spawn Haste Area on Item Pickup', 'spawn_haste_area_on_item_pickup_chance', 20}, links = {26, 25, 49, 43}, size = 1}
tree[30] = {x = 90, y = -150, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {15, 31, 32, 33}, size = 1}
tree[31] = {x = 54, y = -186, types = {'HP'}, stats = {'10% Increased Chance to Spawn HP', 'hp_spawn_chance_multiplier', 0.10}, links = {30, 34}, size = 1}
tree[32] = {x = 90, y = -186, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {30, 39}, size = 1}
tree[33] = {x = 126, y = -186, types = {'HP', 'Cycle'}, stats = {'1% Added Chance to Spawn HP on Cycle', 'spawn_hp_on_cycle_chance', 1}, links = {30, 37}, size = 1}
tree[34] = {x = 54, y = -222, types = {'HP'}, stats = {'20% Increased Chance to Spawn HP', 'hp_spawn_chance_multiplier', 0.20}, links = {31, 35}, size = 1}
tree[35] = {x = 54, y = -258, types = {'HP'}, stats = {'10% Increased Chance to Spawn HP', 'hp_spawn_chance_multiplier', 0.10}, links = {34, 41}, size = 1}
tree[37] = {x = 126, y = -222, types = {'HP', 'Cycle'}, stats = {'2% Added Chance to Spawn HP on Cycle', 'spawn_hp_on_cycle_chance', 2}, links = {33, 38}, size = 1}
tree[38] = {x = 126, y = -258, types = {'HP', 'Cycle'}, stats = {'1% Added Chance to Spawn HP on Cycle', 'spawn_hp_on_cycle_chance', 1}, links = {37, 41}, size = 1}
tree[39] = {x = 90, y = -222, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {32, 40}, size = 1}
tree[40] = {x = 90, y = -258, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {39, 41}, size = 1}
tree[41] = {x = 90, y = -294, types = {'HP', 'Cycle'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04, '10% Increased Chance to Spawn HP', 'hp_spawn_chance_multiplier', 0.10, 
'2% Added Chance to Spawn HP on Cycle', 'spawn_hp_on_cycle_chance', 2, '2% Added Chance to Regain HP on Cycle', 'regain_hp_on_cycle_chance', 2}, links = {35, 42, 40, 38}, size = 2}
tree[42] = {x = 90, y = -378, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 2}, links = {41, 43, 64, 65}, size = 1}
tree[43] = {x = 30, y = -438, types = {'ASPD', 'HP'}, stats = {'20% Added Chance to Spawn Haste Area Area on HP Pickup', 'spawn_haste_area_on_hp_pickup_chance', 20}, links = {29, 42, 44}, size = 2}
tree[44] = {x = 54, y = -462, types = {'ASPD'}, stats = {'3% Increased Attack Speed', 'aspd_multiplier', 0.03}, links = {43, 45}, size = 1}
tree[45] = {x = 30, y = -486, types = {'ASPD'}, stats = {'3% Increased Attack Speed', 'aspd_multiplier', 0.03}, links = {44, 77, 350}, size = 1}
tree[46] = {x = -126, y = -126, types = {'Ammo'}, stats = {'4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {16, 47}, size = 1}
tree[47] = {x = -126, y = -210, types = {'Ammo'}, stats = {'4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {46, 48, 56}, size = 1}
tree[48] = {x = -126, y = -294, types = {'Ammo'}, stats = {'4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {47, 49, 53}, size = 1}
tree[49] = {x = -126, y = -378, types = {'Ammo'}, stats = {'4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {48, 29, 50}, size = 1}
tree[50] = {x = -102, y = -402, types = {'Attack'}, stats = {'4% Added Chance to Attack Twice', 'attack_twice_chance', 4}, links = {49, 51}, size = 1}
tree[51] = {x = -126, y = -426, types = {'Attack'}, stats = {'4% Added Chance to Attack Twice', 'attack_twice_chance', 4}, links = {50, 52}, size = 1}
tree[52] = {x = -102, y = -450, types = {'Attack'}, stats = {'12% Added Chance to Attack Twice', 'attack_twice_chance', 12}, links = {51}, size = 1}
tree[53] = {x = -150, y = -270, types = {'Ammo'}, stats = {'5% Added Chance to Drop Double Ammo', 'drop_double_ammo_chance', 5}, links = {48, 54}, size = 1}
tree[54] = {x = -174, y = -294, types = {'Ammo'}, stats = {'10% Added Chance to Drop Double Ammo', 'drop_double_ammo_chance', 10}, links = {53, 55}, size = 1}
tree[55] = {x = -150, y = -318, types = {'Ammo'}, stats = {'15% Added Chance to Drop Double Ammo', 'drop_double_ammo_chance', 15}, links = {54}, size = 1}
tree[56] = {x = -150, y = -186, types = {'Ammo', 'Kill'}, stats = {'8% Added Chance to Regain Ammo on Kill', 'regain_ammo_on_kill_chance', 8}, links = {47, 57}, size = 1}
tree[57] = {x = -174, y = -210, types = {'Ammo', 'Kill'}, stats = {'8% Added Chance to Regain Ammo on Kill', 'regain_ammo_on_kill_chance', 8}, links = {56, 58}, size = 1}
tree[58] = {x = -150, y = -234, types = {'Ammo', 'Kill'}, stats = {'16% Added Chance to Regain Ammo on Kill', 'regain_ammo_on_kill_chance', 16}, links = {57}, size = 1}
tree[59] = {x = 186, y = -126, types = {'Ammo'}, stats = {'4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {17, 60}, size = 1}
tree[60] = {x = 186, y = -258, types = {'Ammo'}, stats = {'4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {59, 61, 64}, size = 1}
tree[61] = {x = 210, y = -234, types = {'Ammo'}, stats = {'8% Increased Ammo', 'ammo_multiplier', 0.08}, links = {60, 62}, size = 1}
tree[62] = {x = 234, y = -258, types = {'Ammo'}, stats = {'8% Increased Ammo', 'ammo_multiplier', 0.08}, links = {61, 63}, size = 1}
tree[63] = {x = 210, y = -282, types = {'Ammo', 'Cycle'}, stats = {'4% Added Chance to Regain Full Ammo on Cycle', 'regain_full_ammo_on_cycle_chance', 4, '16% Increased Ammo', 'ammo_multiplier', 0.16}, links = {62}, size = 1}
tree[64] = {x = 186, y = -378, types = {'Ammo'}, stats = {'4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {60, 42, 80, 83}, size = 1}
tree[65] = {x = 114, y = -402, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {42, 66}, size = 1}
tree[66] = {x = 138, y = -426, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {65, 67}, size = 1}
tree[67] = {x = 162, y = -450, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {66, 68}, size = 1}
tree[68] = {x = 138, y = -474, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {67, 69, 78}, size = 1}
tree[69] = {x = 114, y = -450, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {68, 70}, size = 1}
tree[70] = {x = 90, y = -426, types = {'HP'}, stats = {'8% Increased HP', 'hp_multiplier', 0.08, '20% Decreased Movement Speed', 'mvspd_multiplier', -0.20}, links = {69}, size = 2}
tree[71] = {x = -90, y = -30, types = {'Conversion', 'Ammo', 'ASPD'}, stats = {'30% of Increases in Ammo Added as Attack Speed', 'ammo_to_aspd', 30}, links = {7, 72, 94}, size = 3}
tree[72] = {x = -138, y = -78, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {71, 73}, size = 1}
tree[73] = {x = -174, y = -114, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {72, 74}, size = 1}
tree[74] = {x = -210, y = -150, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {73, 75}, size = 1}
tree[75] = {x = -246, y = -186, types = {'Item'}, stats = {'20% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.20}, links = {74, 76, 104}, size = 2}
tree[76] = {x = -246, y = -378, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {75, 79, 352, 364}, size = 1}
tree[77] = {x = 30, y = -522, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {79, 78, 45, 406}, size = 1}
tree[78] = {x = 138, y = -522, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {77, 87, 68, 428}, size = 1}
tree[79] = {x = -102, y = -522, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {76, 77, 405, 408, 419}, size = 1}
tree[80] = {x = 210, y = -402, types = {'HP', 'Cycle'}, stats = {'1% Added Chance to Regain HP on Cycle', 'regain_hp_on_cycle_chance', 1}, links = {64, 81}, size = 1}
tree[81] = {x = 246, y = -402, types = {'HP', 'Cycle'}, stats = {'1% Added Chance to Regain HP on Cycle', 'regain_hp_on_cycle_chance', 1}, links = {80, 82}, size = 1}
tree[82] = {x = 282, y = -402, types = {'HP', 'Cycle'}, stats = {'1% Added Chance to Regain HP on Cycle', 'regain_hp_on_cycle_chance', 1}, links = {81, 86}, size = 1}
tree[83] = {x = 210, y = -354, types = {'HP'}, stats = {'2% Added Chance to Spawn Double HP', 'spawn_double_hp_chance', 2}, links = {84, 64}, size = 1}
tree[84] = {x = 246, y = -354, types = {'HP'}, stats = {'2% Added Chance to Spawn Double HP', 'spawn_double_hp_chance', 2}, links = {85, 83}, size = 1}
tree[85] = {x = 282, y = -354, types = {'HP'}, stats = {'2% Added Chance to Spawn Double HP', 'spawn_double_hp_chance', 2}, links = {86, 84}, size = 1}
tree[86] = {x = 306, y = -378, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {87, 92, 82, 85, 478}, size = 1}
tree[87] = {x = 306, y = -522, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {78, 86, 437, 440, 457, 451, 454}, size = 1}
tree[88] = {x = 150, y = -30, types = {'Conversion', 'HP', 'SP'}, stats = {'HP is converted to SP if HP is full', 'convert_hp_to_sp_if_hp_full', true}, links = {89, 13, 262}, size = 3}
tree[89] = {x = 198, y = -78, types = {'Resource'}, stats = {'4% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.04}, links = {90, 88}, size = 1}
tree[90] = {x = 234, y = -114, types = {'Resource'}, stats = {'4% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.04}, links = {91, 89}, size = 1}
tree[91] = {x = 270, y = -150, types = {'Resource'}, stats = {'4% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.04}, links = {92, 90}, size = 1}
tree[92] = {x = 306, y = -186, types = {'Item'}, stats = {'20% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.20}, links = {86, 91, 295}, size = 2}
tree[93] = {x = -66, y = 54, types = {'ASPD'}, stats = {'3% Increased Attack Speed', 'aspd_multiplier', 0.03}, links = {3, 94}, size = 1}
tree[94] = {x = -90, y = 30, types = {'ASPD'}, stats = {'3% Increased Attack Speed', 'aspd_multiplier', 0.03}, links = {93, 95, 71}, size = 1}
tree[95] = {x = -114, y = 54, types = {'ASPD'}, stats = {'3% Increased Attack Speed', 'aspd_multiplier', 0.03}, links = {94, 96}, size = 1}
tree[96] = {x = -150, y = 90, types = {'ASPD', 'PSPD'}, stats = {'6% Increased Attack Speed', 'aspd_multiplier', 0.06, '5% Increased Projectile Speed', 'pspd_multiplier', 0.05}, links = {95, 97, 109, 100, 137, 157}, size = 2}
tree[97] = {x = -114, y = 126, types = {'PSPD'}, stats = {'3% Increased Projectile Speed', 'pspd_multiplier', 0.03}, links = {96, 98}, size = 1}
tree[98] = {x = -90, y = 150, types = {'PSPD'}, stats = {'4% Increased Projectile Speed', 'pspd_multiplier', 0.04}, links = {97, 99, 190}, size = 1}
tree[99] = {x = -66, y = 126, types = {'PSPD'}, stats = {'3% Increased Projectile Speed', 'pspd_multiplier', 0.03}, links = {98, 3}, size = 1}
tree[100] = {x = -150, y = -30, types = {'ASPD'}, stats = {'2% Increased Attack Speed', 'aspd_multiplier', 0.02}, links = {96, 102}, size = 1}
tree[102] = {x = -186, y = -66, types = {'ASPD'}, stats = {'2% Increased Attack Speed', 'aspd_multiplier', 0.02}, links = {100, 103}, size = 1}
tree[103] = {x = -390, y = -66, types = {'ASPD'}, stats = {'2% Increased Attack Speed', 'aspd_multiplier', 0.02}, links = {102, 106, 117}, size = 1}
tree[104] = {x = -390, y = -186, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {107, 75, 105, 353}, size = 1}
tree[105] = {x = -498, y = -186, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {104, 136, 380}, size = 1}
tree[106] = {x = -366, y = -90, types = {'Barrage', 'Kill'}, stats = {'1% Added Chance to Barrage on Kill', 'barrage_on_kill_chance', 1}, links = {103, 107}, size = 1}
tree[107] = {x = -390, y = -114, types = {'Barrage', 'Kill'}, stats = {'1% Added Chance to Barrage on Kill', 'barrage_on_kill_chance', 1}, links = {106, 108, 104}, size = 1}
tree[108] = {x = -366, y = -138, types = {'Barrage', 'Kill'}, stats = {'3% Added Chance to Barrage on Kill', 'barrage_on_kill_chance', 3}, links = {107}, size = 1}
tree[109] = {x = -210, y = 30, types = {'ASPD'}, stats = {'5% Increased Attack Speed', 'aspd_multiplier', 0.05}, links = {96, 110, 111}, size = 1}
tree[110] = {x = -246, y = -6, types = {'ASPD'}, stats = {'5% Increased Attack Speed', 'aspd_multiplier', 0.05}, links = {109, 116}, size = 1}
tree[111] = {x = -246, y = 66, types = {'PSPD'}, stats = {'5% Increased Projectile Speed', 'pspd_multiplier', 0.05}, links = {112, 109}, size = 1}
tree[112] = {x = -282, y = 66, types = {'PSPD'}, stats = {'10% Increased Projectile Speed', 'pspd_multiplier', 0.10}, links = {113, 111}, size = 1}
tree[113] = {x = -318, y = 66, types = {'PSPD'}, stats = {'5% Increased Projectile Speed', 'pspd_multiplier', 0.05}, links = {114, 112}, size = 1}
tree[114] = {x = -354, y = 30, types = {'PSPD'}, stats = {'5% Increased Projectile Speed', 'pspd_multiplier', 0.05}, links = {115, 117, 113, 118}, size = 1}
tree[115] = {x = -318, y = -6, types = {'ASPD'}, stats = {'5% Increased Attack Speed', 'aspd_multiplier', 0.05}, links = {116, 114}, size = 1}
tree[116] = {x = -282, y = -6, types = {'ASPD'}, stats = {'10% Increased Attack Speed', 'aspd_multiplier', 0.10}, links = {110, 115}, size = 1}
tree[117] = {x = -390, y = -6, types = {'ASPD', 'Cycle'}, stats = {'10% Added Chance to Spawn Haste Area Area on Cycle', 'spawn_haste_area_on_cycle_chance', 10}, links = {114, 103, 130, 119, 123}, size = 1}
tree[118] = {x = -390, y = 66, types = {'ASPD'}, stats = {'2% Increased Attack Speed', 'aspd_multiplier', 0.02}, links = {114, 128, 149, 140}, size = 1}
tree[119] = {x = -438, y = -6, types = {'PSPD', 'Buff', 'Cycle'}, stats = {'10% Added Chance to Gain Projectile Speed Boost on Cycle', 'gain_pspd_boost_on_cycle_chance', 10}, links = {117, 120}, size = 1}
tree[120] = {x = -474, y = -6, types = {'PSPD'}, stats = {'5% Increased Projectile Speed', 'pspd_multiplier', 0.05}, links = {119, 121}, size = 1}
tree[121] = {x = -510, y = -6, types = {'PSPD'}, stats = {'5% Increased Projectile Speed', 'pspd_multiplier', 0.05}, links = {120, 122}, size = 1}
tree[122] = {x = -546, y = -6, types = {'PSPD'}, stats = {'10% Increased Projectile Speed', 'pspd_multiplier', 0.10}, links = {121, 127}, size = 1}
tree[123] = {x = -438, y = 42, types = {'PSPD', 'Buff', 'Cycle'}, stats = {'10% Added Chance to Gain Projectile Speed Inhibit on Cycle', 'gain_pspd_inhibit_on_cycle_chance', 10}, links = {124, 117}, size = 1}
tree[124] = {x = -474, y = 42, types = {'PSPD'}, stats = {'5% Decreased Projectile Speed', 'pspd_multiplier', -0.05}, links = {125, 123}, size = 1}
tree[125] = {x = -510, y = 42, types = {'PSPD'}, stats = {'5% Decreased Projectile Speed', 'pspd_multiplier', -0.05}, links = {126, 124}, size = 1}
tree[126] = {x = -546, y = 42, types = {'PSPD'}, stats = {'10% Decreased Projectile Speed', 'pspd_multiplier', -0.10}, links = {127, 125}, size = 1}
tree[127] = {x = -570, y = 18, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {122, 126, 136, 150, 367, 694}, size = 1}
tree[128] = {x = -426, y = 102, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {118, 129}, size = 1}
tree[129] = {x = -462, y = 102, types = {'HP'}, stats = {'6% Increased HP', 'hp_multiplier', 0.06}, links = {128, 687, 698}, size = 1}
tree[130] = {x = -438, y = -54, types = {'ASPD'}, stats = {'4% Increased Attack Speed', 'aspd_multiplier', 0.04}, links = {117, 131}, size = 1}
tree[131] = {x = -474, y = -54, types = {'ASPD'}, stats = {'6% Increased Attack Speed', 'aspd_multiplier', 0.06}, links = {130, 132}, size = 1}
tree[132] = {x = -510, y = -54, types = {'ASPD'}, stats = {'6% Increased Attack Speed', 'aspd_multiplier', 0.06}, links = {131, 133}, size = 1}
tree[133] = {x = -510, y = -90, types = {'ASPD'}, stats = {'6% Increased Attack Speed', 'aspd_multiplier', 0.06}, links = {132, 134}, size = 1}
tree[134] = {x = -474, y = -90, types = {'ASPD'}, stats = {'6% Increased Attack Speed', 'aspd_multiplier', 0.06}, links = {133, 135}, size = 1}
tree[135] = {x = -438, y = -90, types = {'ASPD', 'MVSPD', 'HP'}, stats = {'12% Increased Attack Speed', 'aspd_multiplier', 0.12, '10% Decreased Movement Speed', 'mvspd_multiplier', -0.10, 
'-15 Max HP', 'flat_hp', -15}, links = {134}, size = 2}
tree[136] = {x = -570, y = -114, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {105, 127, 363}, size = 1}
tree[137] = {x = -234, y = 174, types = {'ASPD', 'Buff', 'Kill'}, stats = {'5% Added Chance to Gain Attack Speed Boost on Kill', 'gain_aspd_boost_on_kill_chance', 5}, links = {96, 141, 145, 138}, size = 1}
tree[138] = {x = -270, y = 138, types = {'ASPD'}, stats = {'5% Increased Attack Speed', 'aspd_multiplier', 0.05}, links = {137, 139}, size = 1}
tree[139] = {x = -306, y = 102, types = {'ASPD'}, stats = {'10% Increased Attack Speed', 'aspd_multiplier', 0.10}, links = {138, 140}, size = 1}
tree[140] = {x = -354, y = 102, types = {'ASPD'}, stats = {'5% Increased Attack Speed', 'aspd_multiplier', 0.05}, links = {139, 118}, size = 1}
tree[141] = {x = -270, y = 210, types = {'PSPD'}, stats = {'5% Decreased Projectile Speed', 'pspd_multiplier', -0.05}, links = {137, 142}, size = 1}
tree[142] = {x = -306, y = 246, types = {'PSPD', 'Proj'}, stats = {'10% Decreased Projectile Speed', 'pspd_multiplier', -0.10, '10% Increased Projectile Size', 'projectile_size_multiplier', 0.10}, links = {141, 143}, size = 1}
tree[143] = {x = -354, y = 246, types = {'PSPD'}, stats = {'5% Decreased Projectile Speed', 'pspd_multiplier', -0.05}, links = {142, 144}, size = 1}
tree[144] = {x = -462, y = 246, types = {'ASPD', 'Proj', 'Attack', 'Cycle'}, stats = {'10% Decreased Attack Speed', 'aspd_multiplier', -0.10, '10% Increased Projectile Size', 'projectile_size_multiplier', 0.10, '4% Added Chance to Change Attack on Cycle', 'change_attack_on_cycle_chance', 4}, links = {143, 149, 150, 159}, size = 2}
tree[145] = {x = -306, y = 174, types = {'Proj', 'Proj'}, stats = {'20% Increased Projectile Size', 'projectile_size_multiplier', 0.20, 
'8% Added Chance to Shoot Shield Projectiles', 'shield_projectile_chance', 8}, links = {146, 137, 148}, size = 2}
tree[146] = {x = -330, y = 150, types = {'PSPD', 'Buff', 'Cycle'}, stats = {'10% Added Chance to Gain Projectile Speed Boost on Cycle', 'gain_pspd_boost_on_cycle_chance', 10}, links = {147, 145}, size = 1}
tree[147] = {x = -354, y = 174, types = {'Homing', 'Kill'}, stats = {'5% Added Chance to Launch Homing Projectile on Kill', 'launch_homing_projectile_on_kill_chance', 5}, links = {149, 146, 148}, size = 1}
tree[148] = {x = -330, y = 198, types = {'PSPD', 'Buff', 'Cycle'}, stats = {'10% Added Chance to Gain Projectile Speed Inhibit on Cycle', 'gain_pspd_inhibit_on_cycle_chance', 10}, links = {147, 145}, size = 1}
tree[149] = {x = -390, y = 174, types = {'ASPD'}, stats = {'2% Increased Attack Speed', 'aspd_multiplier', 0.02}, links = {144, 118, 147}, size = 1}
tree[150] = {x = -570, y = 246, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {144, 127, 181, 510, 684, 688}, size = 1}
tree[157] = {x = -150, y = 210, types = {'PSPD'}, stats = {'2% Increased Projectile Speed', 'pspd_multiplier', 0.02}, links = {158, 96}, size = 1}
tree[158] = {x = -246, y = 306, types = {'PSPD'}, stats = {'2% Increased Projectile Speed', 'pspd_multiplier', 0.02}, links = {160, 157, 161, 162}, size = 1}
tree[159] = {x = -462, y = 306, types = {'PSPD'}, stats = {'2% Increased Projectile Speed', 'pspd_multiplier', 0.02}, links = {144, 160, 170, 171}, size = 1}
tree[160] = {x = -354, y = 306, types = {'PSPD'}, stats = {'2% Increased Projectile Speed', 'pspd_multiplier', 0.02}, links = {159, 158, 167}, size = 1}
tree[161] = {x = -282, y = 342, types = {'Proj'}, stats = {'Projectiles Change Direction Randomly', 'projectile_random_degree_change', true}, links = {158, 163}, size = 2}
tree[162] = {x = -210, y = 342, types = {'Proj'}, stats = {'Projectiles Change Direction by 90 Degrees', 'projectile_ninety_degree_change', true}, links = {158, 163}, size = 2}
tree[163] = {x = -246, y = 378, types = {'Proj'}, stats = {'10% Increased Angle Change Frequency', 'projectile_angle_change_frequency_multiplier', 0.10}, links = {161, 164, 162}, size = 1}
tree[164] = {x = -222, y = 402, types = {'Proj'}, stats = {'10% Increased Angle Change Frequency', 'projectile_angle_change_frequency_multiplier', 0.10}, links = {163, 165}, size = 1}
tree[165] = {x = -246, y = 426, types = {'Proj'}, stats = {'10% Increased Angle Change Frequency', 'projectile_angle_change_frequency_multiplier', 0.10}, links = {164, 166}, size = 1}
tree[166] = {x = -270, y = 402, types = {'Proj'}, stats = {'20% Increased Angle Change Frequency', 'projectile_angle_change_frequency_multiplier', 0.20}, links = {165}, size = 1}
tree[167] = {x = -330, y = 330, types = {'Proj'}, stats = {'5% Added Projectile Waviness', 'projectile_waviness_multiplier', 0.05}, links = {160, 168}, size = 1}
tree[168] = {x = -354, y = 354, types = {'Proj'}, stats = {'10% Added Projectile Waviness', 'projectile_waviness_multiplier', 0.10}, links = {167, 169, 182}, size = 1}
tree[169] = {x = -378, y = 330, types = {'Proj'}, stats = {'15% Added Projectile Waviness', 'projectile_waviness_multiplier', 0.15}, links = {168}, size = 1}
tree[170] = {x = -426, y = 342, types = {'Proj'}, stats = {'Projectile Start Fast and Become Slow', 'fast_slow', true}, links = {159, 172}, size = 2}
tree[171] = {x = -498, y = 342, types = {'Proj'}, stats = {'Projectile Start Slow and Become Fast', 'slow_fast', true}, links = {159, 172}, size = 2}
tree[172] = {x = -462, y = 378, types = {'Proj'}, stats = {'10% Increased Projectile Acceleration', 'projectile_acceleration_multiplier', 0.10, 
'10% Increased Projectile Deceleration', 'projectile_deceleration_multiplier', 0.10}, links = {170, 173, 171, 177}, size = 1}
tree[173] = {x = -438, y = 402, types = {'Proj'}, stats = {'10% Increased Projectile Deceleration', 'projectile_deceleration_multiplier', 0.10}, links = {172, 174}, size = 1}
tree[174] = {x = -414, y = 378, types = {'Proj'}, stats = {'10% Increased Projectile Deceleration', 'projectile_deceleration_multiplier', 0.10}, links = {173, 175}, size = 1}
tree[175] = {x = -390, y = 402, types = {'Proj'}, stats = {'10% Increased Projectile Deceleration', 'projectile_deceleration_multiplier', 0.10}, links = {174, 176}, size = 1}
tree[176] = {x = -414, y = 426, types = {'Proj'}, stats = {'20% Increased Projectile Deceleration', 'projectile_deceleration_multiplier', 0.20}, links = {175}, size = 1}
tree[177] = {x = -486, y = 402, types = {'Proj'}, stats = {'10% Increased Projectile Acceleration', 'projectile_acceleration_multiplier', 0.10}, links = {172, 178}, size = 1}
tree[178] = {x = -510, y = 378, types = {'Proj'}, stats = {'10% Increased Projectile Acceleration', 'projectile_acceleration_multiplier', 0.10}, links = {177, 179}, size = 1}
tree[179] = {x = -534, y = 402, types = {'Proj'}, stats = {'10% Increased Projectile Acceleration', 'projectile_acceleration_multiplier', 0.10}, links = {178, 180}, size = 1}
tree[180] = {x = -510, y = 426, types = {'Proj'}, stats = {'20% Increased Projectile Acceleration', 'projectile_acceleration_multiplier', 0.20}, links = {179}, size = 1}
tree[181] = {x = -570, y = 486, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {150, 182, 512, 667, 676}, size = 1}
tree[182] = {x = -354, y = 486, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {181, 168, 195, 508, 657}, size = 1}
tree[183] = {x = -6, y = 186, types = {'MVSPD'}, stats = {'3% Increased Movement Speed', 'mvspd_multiplier', 0.03}, links = {5, 184}, size = 1}
tree[184] = {x = -30, y = 210, types = {'MVSPD'}, stats = {'3% Increased Movement Speed', 'mvspd_multiplier', 0.03}, links = {183, 185, 190}, size = 1}
tree[185] = {x = -6, y = 234, types = {'MVSPD'}, stats = {'3% Increased Movement Speed', 'mvspd_multiplier', 0.03}, links = {184, 189}, size = 1}
tree[186] = {x = 66, y = 186, types = {'Boost'}, stats = {'4% Increased Boost', 'boost_multiplier', 0.04}, links = {187, 5}, size = 1}
tree[187] = {x = 90, y = 210, types = {'Boost'}, stats = {'8% Increased Boost', 'boost_multiplier', 0.08}, links = {188, 186, 265}, size = 1}
tree[188] = {x = 66, y = 234, types = {'Boost'}, stats = {'4% Increased Boost', 'boost_multiplier', 0.04}, links = {189, 187}, size = 1}
tree[189] = {x = 30, y = 270, types = {'Boost', 'MVSPD'}, stats = {'+10 Max Boost', 'flat_boost', 10, '6% Increased Movement Speed', 'mvspd_multiplier', 0.06}, links = {185, 188, 196, 207, 225}, size = 2}
tree[190] = {x = -90, y = 210, types = {'Conversion', 'MVSPD', 'PSPD'}, stats = {'30% of Increases in Movement Speed Added as Projectile Speed', 'mvspd_to_pspd', 30}, links = {184, 191, 98}, size = 3}
tree[191] = {x = -90, y = 270, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {190, 192}, size = 1}
tree[192] = {x = -90, y = 306, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {191, 193}, size = 1}
tree[193] = {x = -114, y = 330, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {192, 194}, size = 1}
tree[194] = {x = -150, y = 366, types = {'Item'}, stats = {'20% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.20}, links = {193, 195}, size = 2}
tree[195] = {x = -150, y = 486, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {194, 206, 182, 230, 648}, size = 1}
tree[196] = {x = -30, y = 330, types = {'MVSPD'}, stats = {'6% Increased Movement Speed', 'mvspd_multiplier', 0.06}, links = {189, 197, 199}, size = 1}
tree[197] = {x = -54, y = 354, types = {'MVSPD'}, stats = {'4% Increased Movement Speed', 'mvspd_multiplier', 0.04}, links = {196, 198, 200}, size = 1}
tree[198] = {x = -30, y = 378, types = {'MVSPD'}, stats = {'4% Increased Movement Speed', 'mvspd_multiplier', 0.04}, links = {197, 199, 203}, size = 1}
tree[199] = {x = -6, y = 354, types = {'Boost', 'Kill'}, stats = {'4% Added Chance to Regain Boost on Kill', 'regain_boost_on_kill_chance', 4}, links = {198, 196}, size = 1}
tree[200] = {x = -90, y = 390, types = {'Turn Rate'}, stats = {'4% Decreased Turn Rate', 'turn_rate_multiplier', -0.04}, links = {197, 201}, size = 1}
tree[201] = {x = -66, y = 414, types = {'Turn Rate'}, stats = {'4% Decreased Turn Rate', 'turn_rate_multiplier', -0.04}, links = {200, 202}, size = 1}
tree[202] = {x = -42, y = 438, types = {'Turn Rate'}, stats = {'8% Decreased Turn Rate', 'turn_rate_multiplier', -0.08}, links = {201, 206}, size = 1}
tree[203] = {x = -6, y = 402, types = {'Turn Rate'}, stats = {'10% Increased Turn Rate', 'turn_rate_multiplier', 0.10}, links = {198, 204, 224}, size = 1}
tree[204] = {x = 18, y = 426, types = {'MVSPD', 'Turn Rate'}, stats = {'4% Increased Movement Speed', 'mvspd_multiplier', 0.04, '4% Increased Turn Rate', 'turn_rate_multiplier', 0.04}, links = {203, 205}, size = 1}
tree[205] = {x = 42, y = 450, types = {'MVSPD', 'Turn Rate'}, stats = {'8% Increased Movement Speed', 'mvspd_multiplier', 0.08, '8% Increased Turn Rate', 'turn_rate_multiplier', 0.08}, links = {204, 206}, size = 1}
tree[206] = {x = 6, y = 486, types = {'MVSPD', 'Turn Rate'}, stats = {'4% Increased Movement Speed', 'mvspd_multiplier', 0.04, '4% Increased Turn Rate', 'turn_rate_multiplier', 0.04}, links = {202, 195, 205, 222}, size = 1}
tree[207] = {x = 90, y = 330, types = {'Boost'}, stats = {'4% Increased Boost', 'boost_multiplier', 0.04}, links = {189, 209, 208}, size = 1}
tree[208] = {x = 66, y = 354, types = {'Boost', 'Kill'}, stats = {'4% Added Chance to Spawn Boost on Kill', 'spawn_boost_on_kill_chance', 4}, links = {210, 207}, size = 1}
tree[209] = {x = 114, y = 354, types = {'Boost'}, stats = {'4% Increased Boost', 'boost_multiplier', 0.04}, links = {207, 210}, size = 1}
tree[210] = {x = 90, y = 378, types = {'Boost'}, stats = {'3% Increased Boost', 'boost_multiplier', 0.03}, links = {209, 208, 211}, size = 1}
tree[211] = {x = 126, y = 414, types = {'Boost', 'Size'}, stats = {'10% Increased Boost Effectiveness', 'boost_effectiveness_multiplier', 0.10, '20% Increased Size', 'size_multiplier', 0.20}, links = {210, 213, 212, 214}, size = 1}
tree[212] = {x = 90, y = 450, types = {'MVSPD', 'Buff', 'Cycle'}, stats = {'1% Added Chance to Gain Movement Speed Boost on Cycle', 'gain_mvspd_boost_on_cycle_chance', 1}, links = {211, 215, 224}, size = 1}
tree[213] = {x = 126, y = 450, types = {'MVSPD'}, stats = {'8% Decreased Movement Speed', 'mvspd_multiplier', -0.08}, links = {211, 217}, size = 1}
tree[214] = {x = 162, y = 450, types = {'Homing', 'Boost'}, stats = {'2% Added Chance to Launch Homing Projectile while Boosting', 'launch_homing_projectile_while_boosting_chance', 2}, links = {211, 220}, size = 1}
tree[215] = {x = 90, y = 486, types = {'MVSPD', 'Boost', 'Cycle'}, stats = {'3% Added Chance to Gain Movement Speed Boost on Cycle', 'gain_mvspd_boost_on_cycle_chance', 3}, links = {212, 216}, size = 1}
tree[216] = {x = 90, y = 522, types = {'MVSPD', 'Boost', 'Cycle'}, stats = {'1% Added Chance to Gain Movement Speed Boost on Cycle', 'gain_mvspd_boost_on_cycle_chance', 1}, links = {215, 221}, size = 1}
tree[217] = {x = 126, y = 486, types = {'MVSPD'}, stats = {'16% Decreased Movement Speed', 'mvspd_multiplier', -0.16}, links = {213, 218}, size = 1}
tree[218] = {x = 126, y = 522, types = {'MVSPD'}, stats = {'8% Decreased Movement Speed', 'mvspd_multiplier', -0.08}, links = {217, 221}, size = 1}
tree[219] = {x = 162, y = 522, types = {'Homing', 'Boost'}, stats = {'2% Added Chance to Launch Homing Projectile while Boosting', 'launch_homing_projectile_while_boosting_chance', 2}, links = {220, 221}, size = 1}
tree[220] = {x = 162, y = 486, types = {'Homing', 'Boost'}, stats = {'4% Added Chance to Launch Homing Projectile while Boosting', 'launch_homing_projectile_while_boosting_chance', 4}, links = {214, 219}, size = 1}
tree[221] = {x = 126, y = 558, types = {'Conversion', 'MVSPD', 'HP'}, stats = {'30% of Decreases in Movement Speed Added as HP', 'mvspd_to_hp', 30, '20% Decreased Turn Rate', 'turn_rate_multiplier', -0.20, 
'20% Decreased Attack Speed', 'aspd_multiplier', -0.20}, links = {218, 216, 219, 228}, size = 2}
tree[222] = {x = 42, y = 522, types = {'MVSPD', 'Turn Rate'}, stats = {'4% Increased Movement Speed', 'mvspd_multiplier', 0.04, '4% Increased Turn Rate', 'turn_rate_multiplier', 0.04}, links = {206, 223}, size = 1}
tree[223] = {x = 42, y = 558, types = {'Conversion', 'MVSPD', 'ASPD', 'HP'}, stats = {'30% of Increases in Movement Speed Added as Attack Speed', 'mvspd_to_aspd', 30, '-25 Max HP', 'flat_hp', -25}, links = {222, 227}, size = 2}
tree[224] = {x = 42, y = 402, types = {'MVSPD'}, stats = {'2% Increased Movement Speed', 'mvspd_multiplier', 0.02}, links = {203, 212}, size = 1}
tree[225] = {x = 150, y = 270, types = {'Boost'}, stats = {'2% Increased Boost', 'boost_multiplier', 0.02}, links = {226, 189}, size = 1}
tree[226] = {x = 222, y = 342, types = {'Boost'}, stats = {'2% Increased Boost', 'boost_multiplier', 0.02}, links = {241, 225, 251}, size = 1}
tree[227] = {x = 42, y = 630, types = {'Boost'}, stats = {'2% Increased Boost', 'boost_multiplier', 0.02}, links = {223, 236, 228}, size = 1}
tree[228] = {x = 126, y = 630, types = {'Special'}, stats = {'5% Added Chance to Drop Mines Periodically', 'drop_mines_chance', 5, '10% Increased Size', 'size_multiplier', 0.10}, links = {227, 229, 231, 221}, size = 1}
tree[229] = {x = 222, y = 630, types = {'Boost'}, stats = {'2% Increased Boost', 'boost_multiplier', 0.02}, links = {228, 242}, size = 1}
tree[230] = {x = -78, y = 558, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {195, 235, 642}, size = 1}
tree[231] = {x = 102, y = 654, types = {'Proj'}, stats = {'5% Increased Projectile Size', 'projectile_size_multiplier', 0.05}, links = {228, 232}, size = 1}
tree[232] = {x = 126, y = 678, types = {'Proj'}, stats = {'5% Increased Projectile Size', 'projectile_size_multiplier', 0.05}, links = {231, 233, 234}, size = 1}
tree[233] = {x = 150, y = 654, types = {'Proj'}, stats = {'10% Increased Projectile Size', 'projectile_size_multiplier', 0.10}, links = {232}, size = 1}
tree[234] = {x = 126, y = 714, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {235, 232, 246}, size = 1}
tree[235] = {x = -78, y = 714, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {230, 234, 507, 632}, size = 1}
tree[236] = {x = 18, y = 654, types = {'Boost'}, stats = {'2% Increased Boost', 'boost_multiplier', 0.02}, links = {227, 237}, size = 1}
tree[237] = {x = -6, y = 678, types = {'Boost'}, stats = {'4% Increased Boost', 'boost_multiplier', 0.04}, links = {236, 238}, size = 1}
tree[238] = {x = -30, y = 654, types = {'Boost'}, stats = {'4% Increased Boost', 'boost_multiplier', 0.04}, links = {237, 239}, size = 1}
tree[239] = {x = -6, y = 630, types = {'Boost'}, stats = {'4% Increased Boost', 'boost_multiplier', 0.04}, links = {238, 240}, size = 1}
tree[240] = {x = -6, y = 594, types = {'Ammo', 'Boost'}, stats = {'+10 Max Ammo', 'flat_ammo', 10, '8% Increased Boost', 'boost_multiplier', 0.08}, links = {239}, size = 1}
tree[241] = {x = 222, y = 426, types = {'Boost'}, stats = {'2% Increased Boost', 'boost_multiplier', 0.02}, links = {242, 226, 247}, size = 1}
tree[242] = {x = 222, y = 522, types = {'Boost'}, stats = {'2% Increased Boost', 'boost_multiplier', 0.02}, links = {229, 241, 243}, size = 1}
tree[243] = {x = 246, y = 498, types = {'Boost'}, stats = {'8% Increased Chance to Spawn Boost', 'boost_spawn_chance_multiplier', 0.08}, links = {242, 244}, size = 1}
tree[244] = {x = 270, y = 522, types = {'Boost'}, stats = {'8% Increased Chance to Spawn Boost', 'boost_spawn_chance_multiplier', 0.08}, links = {246, 243, 245}, size = 1}
tree[245] = {x = 246, y = 546, types = {'Boost'}, stats = {'16% Increased Chance to Spawn Boost', 'boost_spawn_chance_multiplier', 0.16}, links = {244}, size = 1}
tree[246] = {x = 270, y = 714, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {234, 244, 257, 630}, size = 1}
tree[247] = {x = 246, y = 450, types = {'Boost'}, stats = {'10% Increased Boost Recharge Rate', 'boost_recharge_rate_multiplier', 0.10}, links = {241, 248}, size = 1}
tree[248] = {x = 270, y = 426, types = {'Boost'}, stats = {'10% Increased Boost Recharge Rate', 'boost_recharge_rate_multiplier', 0.10}, links = {247, 249}, size = 1}
tree[249] = {x = 294, y = 402, types = {'Boost'}, stats = {'10% Increased Boost Recharge Rate', 'boost_recharge_rate_multiplier', 0.10}, links = {248, 250}, size = 1}
tree[250] = {x = 318, y = 426, types = {'Boost'}, stats = {'20% Increased Boost Recharge Rate', 'boost_recharge_rate_multiplier', 0.20}, links = {249, 256}, size = 1}
tree[251] = {x = 246, y = 318, types = {'Boost'}, stats = {'8% Increased Boost Effectiveness', 'boost_effectiveness_multiplier', 0.08}, links = {226, 252}, size = 1}
tree[252] = {x = 270, y = 342, types = {'Boost'}, stats = {'8% Increased Boost Effectiveness', 'boost_effectiveness_multiplier', 0.08}, links = {251, 253}, size = 1}
tree[253] = {x = 246, y = 366, types = {'Boost'}, stats = {'16% Increased Boost Effectiveness', 'boost_effectiveness_multiplier', 0.16}, links = {252}, size = 1}
tree[256] = {x = 366, y = 426, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {257, 250, 310, 500, 591}, size = 1}
tree[257] = {x = 366, y = 618, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {256, 246, 501, 594, 604, 700}, size = 1}
tree[258] = {x = 126, y = 126, types = {'Luck'}, stats = {'5% Increased Luck', 'luck_multiplier', 0.05}, links = {4, 259}, size = 1}
tree[259] = {x = 150, y = 150, types = {'Luck'}, stats = {'5% Increased Luck', 'luck_multiplier', 0.05}, links = {258, 260, 265}, size = 1}
tree[260] = {x = 174, y = 126, types = {'Luck'}, stats = {'5% Increased Luck', 'luck_multiplier', 0.05}, links = {259, 264}, size = 1}
tree[261] = {x = 126, y = 54, types = {'SP'}, stats = {'5% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.05}, links = {262, 4}, size = 1}
tree[262] = {x = 150, y = 30, types = {'SP'}, stats = {'5% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.05}, links = {263, 261, 88}, size = 1}
tree[263] = {x = 174, y = 54, types = {'SP'}, stats = {'5% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.05}, links = {264, 262}, size = 1}
tree[264] = {x = 210, y = 90, types = {'SP', 'Luck'}, stats = {'10% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.10, 
'10% Increased Luck', 'luck_multiplier', 0.10}, links = {260, 263, 267,  266, 283, 300, 902}, size = 2}
tree[902] = {x = 282, y = 90, types = {'Attack', 'Cycle'}, stats = {'4% Added Chance to Change Attack on Cycle', 'change_attack_on_cycle_chance', 4}, links = {264, 271}, size = 1}
tree[265] = {x = 150, y = 210, types = {'Luck', 'Boost'}, stats = {'100% Increased Luck while Boosting', 'increased_luck_while_boosting', true}, links = {187, 259, 305}, size = 3}
tree[266] = {x = 282, y = 162, types = {'Homing', 'Kill'}, stats = {'2% Added Chance to Launch Homing Projectile on Kill', 'launch_homing_projectile_on_kill_chance', 2}, links = {264, 268}, size = 1}
tree[267] = {x = 282, y = 18, types = {'SP'}, stats = {'2% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.02}, links = {264, 274, 276}, size = 1}
tree[268] = {x = 342, y = 162, types = {'Homing', 'Kill'}, stats = {'1% Added Chance to Launch Homing Projectile on Kill', 'launch_homing_projectile_on_kill_chance', 1}, links = {266, 269}, size = 1}
tree[269] = {x = 402, y = 162, types = {'Homing', 'Kill'}, stats = {'2% Added Chance to Launch Homing Projectile on Kill', 'launch_homing_projectile_on_kill_chance', 2}, links = {268, 270}, size = 1}
tree[270] = {x = 462, y = 162, types = {'Homing', 'Kill'}, stats = {'1% Added Chance to Launch Homing Projectile on Kill', 'launch_homing_projectile_on_kill_chance', 1}, links = {269, 281}, size = 1}
tree[271] = {x = 342, y = 90, types = {'Attack', 'Cycle'}, stats = {'4% Added Chance to Change Attack on Cycle', 'change_attack_on_cycle_chance', 4}, links = {902, 272}, size = 1}
tree[272] = {x = 402, y = 90, types = {'Attack', 'Cycle'}, stats = {'4% Added Chance to Change Attack on Cycle', 'change_attack_on_cycle_chance', 4}, links = {271, 273}, size = 1}
tree[273] = {x = 462, y = 90, types = {'Attack', 'Cycle'}, stats = {'4% Added Chance to Change Attack on Cycle', 'change_attack_on_cycle_chance', 4}, links = {272, 281}, size = 1}
tree[274] = {x = 306, y = -6, types = {'SP'}, stats = {'2% Added Chance to Gain Double SP', 'gain_double_sp_chance', 2}, links = {267, 275}, size = 1}
tree[275] = {x = 330, y = 18, types = {'SP'}, stats = {'4% Added Chance to Gain Double SP', 'gain_double_sp_chance', 4}, links = {274, 276, 277}, size = 1}
tree[276] = {x = 306, y = 42, types = {'SP'}, stats = {'2% Added Chance to Gain Double SP', 'gain_double_sp_chance', 2}, links = {275, 267}, size = 1}
tree[277] = {x = 402, y = 18, types = {'SP'}, stats = {'4% Added Chance to Spawn Double SP', 'spawn_double_sp_chance', 4}, links = {275, 278, 280}, size = 1}
tree[278] = {x = 426, y = -6, types = {'SP'}, stats = {'2% Added Chance to Spawn Double SP', 'spawn_double_sp_chance', 2}, links = {277, 279}, size = 1}
tree[279] = {x = 450, y = 18, types = {'SP'}, stats = {'2% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 2}, links = {278, 280, 282, 285}, size = 1}
tree[280] = {x = 426, y = 42, types = {'SP'}, stats = {'2% Added Chance to Spawn Double SP', 'spawn_double_sp_chance', 2}, links = {279, 277}, size = 1}
tree[281] = {x = 534, y = 90, types = {'Special'}, stats = {'5% Added Chance to All On Kill Events', 'added_chance_to_all_on_kill_events', 5}, links = {270, 273, 282, 304, 327}, size = 2}
tree[282] = {x = 534, y = 18, types = {'Luck'}, stats = {'2% Increased Luck', 'luck_multiplier', 0.02}, links = {279, 281, 330}, size = 1}
tree[283] = {x = 210, y = -30, types = {'SP'}, stats = {'2% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.02}, links = {264, 284}, size = 1}
tree[284] = {x = 246, y = -66, types = {'SP'}, stats = {'2% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.02}, links = {283, 287}, size = 1}
tree[285] = {x = 486, y = -18, types = {'ASPD', 'SP'}, stats = {'5% Added Chance to Spawn Haste Area Area on SP Pickup', 'spawn_haste_area_on_sp_pickup_chance', 5}, links = {286, 279, 296}, size = 1}
tree[286] = {x = 438, y = -66, types = {'SP'}, stats = {'2% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.02}, links = {287, 285, 288}, size = 1}
tree[287] = {x = 342, y = -66, types = {'SP'}, stats = {'2% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.02}, links = {284, 286, 291}, size = 1}
tree[288] = {x = 414, y = -90, types = {'Item'}, stats = {'5% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.05}, links = {286, 289}, size = 1}
tree[289] = {x = 438, y = -114, types = {'Item'}, stats = {'5% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.05}, links = {288, 290, 294}, size = 1}
tree[290] = {x = 462, y = -90, types = {'Item'}, stats = {'10% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.10}, links = {289}, size = 1}
tree[291] = {x = 318, y = -90, types = {'HP', 'SP'}, stats = {'1% Added Chance to Regain HP on SP Pickup', 'regain_hp_on_sp_pickup_chance', 1}, links = {287, 292}, size = 1}
tree[292] = {x = 342, y = -114, types = {'HP', 'SP'}, stats = {'1% Added Chance to Regain HP on SP Pickup', 'regain_hp_on_sp_pickup_chance', 1}, links = {291, 293, 294}, size = 1}
tree[293] = {x = 366, y = -90, types = {'HP', 'SP'}, stats = {'2% Added Chance to Regain HP on SP Pickup', 'regain_hp_on_sp_pickup_chance', 2}, links = {292}, size = 1}
tree[294] = {x = 390, y = -162, types = {'Item'}, stats = {'5% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.05}, links = {292, 295, 289}, size = 1}
tree[295] = {x = 390, y = -186, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {294, 92, 299}, size = 1}
tree[296] = {x = 510, y = -42, types = {'SP', 'Cycle'}, stats = {'2% Added Chance to Spawn SP on Cycle', 'spawn_sp_on_cycle_chance', 2}, links = {297, 285}, size = 1}
tree[297] = {x = 534, y = -18, types = {'SP', 'Cycle'}, stats = {'2% Added Chance to Spawn SP on Cycle', 'spawn_sp_on_cycle_chance', 2}, links = {298, 296}, size = 1}
tree[298] = {x = 558, y = -42, types = {'SP', 'Cycle'}, stats = {'4% Added Chance to Spawn SP on Cycle', 'spawn_sp_on_cycle_chance', 4}, links = {299, 297}, size = 1}
tree[299] = {x = 558, y = -186, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {295, 298, 328, 478, 535}, size = 1}
tree[300] = {x = 210, y = 210, types = {'Luck'}, stats = {'2% Increased Luck', 'luck_multiplier', 0.02}, links = {301, 264}, size = 1}
tree[301] = {x = 342, y = 210, types = {'Luck'}, stats = {'2% Increased Luck', 'luck_multiplier', 0.02}, links = {302, 300}, size = 1}
tree[302] = {x = 474, y = 210, types = {'Luck'}, stats = {'2% Increased Luck', 'luck_multiplier', 0.02}, links = {303, 301, 313}, size = 1}
tree[303] = {x = 558, y = 210, types = {'Luck'}, stats = {'2% Increased Luck', 'luck_multiplier', 0.02}, links = {304, 302, 316}, size = 1}
tree[304] = {x = 606, y = 162, types = {'Luck'}, stats = {'2% Increased Luck', 'luck_multiplier', 0.02}, links = {281, 304, 304, 303, 319}, size = 1}
tree[305] = {x = 198, y = 258, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {265, 306}, size = 1}
tree[306] = {x = 234, y = 258, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {305, 307}, size = 1}
tree[307] = {x = 270, y = 258, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {306, 308}, size = 1}
tree[308] = {x = 318, y = 258, types = {'Item'}, stats = {'20% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.20}, links = {307, 310}, size = 2}
tree[310] = {x = 366, y = 306, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {308, 256, 311}, size = 1}
tree[311] = {x = 474, y = 306, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {310, 314, 312, 583}, size = 1}
tree[312] = {x = 558, y = 306, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {311, 317, 325, 578}, size = 1}
tree[313] = {x = 450, y = 234, types = {'Barrage', 'Kill'}, stats = {'1% Added Chance to Barrage on Kill', 'barrage_on_kill_chance', 1}, links = {302, 314}, size = 1}
tree[314] = {x = 474, y = 258, types = {'Barrage', 'Kill'}, stats = {'1% Added Chance to Barrage on Kill', 'barrage_on_kill_chance', 1}, links = {313, 315, 311}, size = 1}
tree[315] = {x = 498, y = 234, types = {'Barrage', 'Kill'}, stats = {'2% Added Chance to Barrage on Kill', 'barrage_on_kill_chance', 2}, links = {314}, size = 1}
tree[316] = {x = 534, y = 234, types = {'ASPD', 'Buff', 'Kill'}, stats = {'2% Added Chance to Gain Attack Speed Boost on Kill', 'gain_aspd_boost_on_kill_chance', 2}, links = {303, 317}, size = 1}
tree[317] = {x = 558, y = 258, types = {'ASPD', 'Buff', 'Kill'}, stats = {'2% Added Chance to Gain Attack Speed Boost on Kill', 'gain_aspd_boost_on_kill_chance', 2}, links = {316, 318, 312}, size = 1}
tree[318] = {x = 582, y = 234, types = {'ASPD', 'Buff', 'Kill'}, stats = {'4% Added Chance to Gain Attack Speed Boost on Kill', 'gain_aspd_boost_on_kill_chance', 4}, links = {317}, size = 1}
tree[319] = {x = 630, y = 138, types = {'Luck'}, stats = {'4% Increased Luck', 'luck_multiplier', 0.04}, links = {304, 320}, size = 1}
tree[320] = {x = 654, y = 162, types = {'Luck'}, stats = {'4% Increased Luck', 'luck_multiplier', 0.04}, links = {319, 321}, size = 1}
tree[321] = {x = 630, y = 186, types = {'Luck'}, stats = {'6% Increased Luck', 'luck_multiplier', 0.06}, links = {320, 322}, size = 1}
tree[322] = {x = 654, y = 210, types = {'Luck'}, stats = {'4% Increased Luck', 'luck_multiplier', 0.04}, links = {321, 323}, size = 1}
tree[323] = {x = 678, y = 186, types = {'Luck'}, stats = {'4% Increased Luck', 'luck_multiplier', 0.04}, links = {322, 324}, size = 1}
tree[324] = {x = 678, y = 138, types = {'Luck', 'SP', 'MVSPD', 'ASPD', 'HP', 'Ammo'}, stats = {'8% Increased Luck', 'luck_multiplier', 0.08, 'Gain Extra SP on Death', 'gain_sp_on_death', true, '10% Decreased Movement Speed', 'mvspd_multiplier', -0.10, '10% Decreased Attack Speed', 'aspd_multiplier', -0.10, '-15 Max HP', 'flat_hp', -15, '-10 Max Ammo', 'flat_ammo', -10}, links = {323}, size = 2}
tree[325] = {x = 654, y = 306, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {312, 326, 575}, size = 1}
tree[326] = {x = 726, y = 234, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {325, 327, 497, 570, 571}, size = 1}
tree[327] = {x = 726, y = 90, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {326, 328, 281, 553}, size = 1}
tree[328] = {x = 726, y = -18, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {327, 299, 339, 552}, size = 1}
tree[330] = {x = 582, y = 18, types = {'SP'}, stats = {'5% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.05}, links = {282, 337}, size = 1}
tree[333] = {x = 618, y = 54, types = {'SP'}, stats = {'5% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.05}, links = {337, 338}, size = 1}
tree[334] = {x = 618, y = -18, types = {'SP'}, stats = {'5% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.05}, links = {337, 335}, size = 1}
tree[335] = {x = 654, y = -18, types = {'SP'}, stats = {'5% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.05}, links = {334}, size = 1}
tree[337] = {x = 618, y = 18, types = {'SP'}, stats = {'20% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.20}, links = {330, 339, 334, 333}, size = 2}
tree[338] = {x = 582, y = 54, types = {'SP'}, stats = {'5% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.05}, links = {333}, size = 1}
tree[339] = {x = 654, y = 54, types = {'Luck'}, stats = {'4% Increased Luck', 'luck_multiplier', 0.04}, links = {337, 328}, size = 1}
tree[350] = {x = 6, y = -462, types = {'ASPD', 'Buff', 'Kill'}, stats = {'6% Increased Attack Speed', 'aspd_multiplier', 0.06, '2% Added Chance to Gain Attack Speed Boost on Kill', 'gain_aspd_boost_on_kill_chance', 2}, links = {45}, size = 1}
tree[352] = {x = -318, y = -306, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {76, 353, 354, 397}, size = 1}
tree[353] = {x = -390, y = -306, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {352, 104, 358, 370, 369}, size = 1}
tree[354] = {x = -294, y = -282, types = {'Ammo'}, stats = {'2% Decreased Ammo Consumption', 'ammo_consumption_multiplier', -0.02}, links = {352, 355}, size = 1}
tree[355] = {x = -318, y = -258, types = {'Ammo'}, stats = {'2% Decreased Ammo Consumption', 'ammo_consumption_multiplier', -0.02}, links = {354, 356}, size = 1}
tree[356] = {x = -294, y = -234, types = {'Ammo'}, stats = {'2% Decreased Ammo Consumption', 'ammo_consumption_multiplier', -0.02}, links = {355, 357}, size = 1}
tree[357] = {x = -318, y = -210, types = {'Ammo'}, stats = {'4% Decreased Ammo Consumption', 'ammo_consumption_multiplier', -0.04}, links = {356}, size = 1}
tree[358] = {x = -438, y = -258, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {353, 360, 359}, size = 1}
tree[359] = {x = -498, y = -258, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {358, 363, 376}, size = 1}
tree[360] = {x = -414, y = -234, types = {'Proj'}, stats = {'2% Added Chance to Shoot Shield Projectiles', 'shield_projectile_chance', 2}, links = {358, 361}, size = 1}
tree[361] = {x = -438, y = -210, types = {'Proj'}, stats = {'2% Added Chance to Shoot Shield Projectiles', 'shield_projectile_chance', 2}, links = {360, 362}, size = 1}
tree[362] = {x = -462, y = -234, types = {'Proj'}, stats = {'4% Added Chance to Shoot Shield Projectiles', 'shield_projectile_chance', 4}, links = {361}, size = 1}
tree[363] = {x = -570, y = -186, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {359, 136, 379, 382, 400}, size = 1}
tree[364] = {x = -282, y = -414, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {365, 76, 404, 407}, size = 1}
tree[365] = {x = -498, y = -414, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {364, 368, 375, 404, 830}, size = 1}
tree[366] = {x = -726, y = -186, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {368, 367, 842}, size = 1}
tree[367] = {x = -726, y = 18, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {127, 366, 510, 693, 844, 843}, size = 1}
tree[368] = {x = -606, y = -306, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {365, 366, 379, 837}, size = 1}
tree[369] = {x = -390, y = -342, types = {'PSPD'}, stats = {'5% Decreased Projectile Speed', 'pspd_multiplier', -0.05}, links = {372, 353}, size = 1}
tree[370] = {x = -426, y = -306, types = {'PSPD'}, stats = {'5% Increased Projectile Speed', 'pspd_multiplier', 0.05}, links = {353, 371}, size = 1}
tree[371] = {x = -450, y = -330, types = {'PSPD'}, stats = {'5% Increased Projectile Speed', 'pspd_multiplier', 0.05}, links = {370, 374}, size = 1}
tree[372] = {x = -414, y = -366, types = {'PSPD'}, stats = {'5% Decreased Projectile Speed', 'pspd_multiplier', -0.05}, links = {373, 369}, size = 1}
tree[373] = {x = -438, y = -390, types = {'PSPD'}, stats = {'5% Decreased Projectile Speed', 'pspd_multiplier', -0.05}, links = {375, 372}, size = 1}
tree[374] = {x = -474, y = -354, types = {'PSPD'}, stats = {'5% Increased Projectile Speed', 'pspd_multiplier', 0.05}, links = {371, 375}, size = 1}
tree[375] = {x = -474, y = -390, types = {'Proj'}, stats = {'10% Increased Projectile Size', 'projectile_size_multiplier', 0.10}, links = {374, 365, 373}, size = 1}
tree[376] = {x = -498, y = -294, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {359, 377}, size = 1}
tree[377] = {x = -522, y = -318, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {376, 378}, size = 1}
tree[378] = {x = -546, y = -294, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {377, 379}, size = 1}
tree[379] = {x = -570, y = -270, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {378, 368, 363}, size = 1}
tree[380] = {x = -462, y = -150, types = {'Attack'}, stats = {'12% Added Chance to Spawn Back Attack', 'back_spawn_chance', 20, 
'12% Added Chance to Spawn Side Attack', 'side_spawn_chance', 20, 'Start With Back Attack', 'start_with_back', true, 'Start With Side Attack', 'start_with_side', true}, links = {105, 381}, size = 2}
tree[381] = {x = -426, y = -150, types = {'Attack'}, stats = {'6% Added Chance to Spawn Back Attack', 'back_spawn_chance', 10, '6% Added Chance to Spawn Side Attack', 'side_spawn_chance', 10}, links = {380}, size = 1}
tree[382] = {x = -654, y = -186, types = {'ASPD'}, stats = {'3% Increased Attack Speed', 'aspd_multiplier', 0.03}, links = {363, 394, 395, 396}, size = 1}
tree[387] = {x = -690, y = -114, types = {'PSPD'}, stats = {'4% Increased Projectile Speed', 'pspd_multiplier', 0.04}, links = {394, 390}, size = 1}
tree[388] = {x = -654, y = -114, types = {'ASPD'}, stats = {'4% Increased Attack Speed', 'aspd_multiplier', 0.04}, links = {395, 391}, size = 1}
tree[389] = {x = -618, y = -114, types = {'Barrage', 'Kill'}, stats = {'2% Added Chance to Barrage on Kill', 'barrage_on_kill_chance', 2}, links = {396, 392}, size = 1}
tree[390] = {x = -690, y = -78, types = {'PSPD'}, stats = {'3% Increased Projectile Speed', 'pspd_multiplier', 0.03}, links = {387, 393}, size = 1}
tree[391] = {x = -654, y = -78, types = {'ASPD'}, stats = {'3% Increased Attack Speed', 'aspd_multiplier', 0.03}, links = {388, 393}, size = 1}
tree[392] = {x = -618, y = -78, types = {'Barrage', 'Kill'}, stats = {'1% Added Chance to Barrage on Kill', 'barrage_on_kill_chance', 1}, links = {389, 393}, size = 1}
tree[393] = {x = -654, y = -42, types = {'PSPD', 'ASPD', 'Barrage', 'Kill'}, stats = {'10% Increased Projectile Speed', 'pspd_multiplier', 0.10, '10% Increased Attack Speed', 'aspd_multiplier', 0.10, 
'2% Added Chance to Barrage on Kill', 'barrage_on_kill_chance', 2}, links = {390, 391, 392, 402}, size = 2}
tree[394] = {x = -690, y = -150, types = {'PSPD'}, stats = {'3% Increased Projectile Speed', 'pspd_multiplier', 0.03}, links = {387, 382}, size = 1}
tree[395] = {x = -654, y = -150, types = {'ASPD'}, stats = {'3% Increased Attack Speed', 'aspd_multiplier', 0.03}, links = {388, 382}, size = 1}
tree[396] = {x = -618, y = -150, types = {'Barrage', 'Kill'}, stats = {'1% Added Chance to Barrage on Kill', 'barrage_on_kill_chance', 1}, links = {389, 382}, size = 1}
tree[397] = {x = -318, y = -342, types = {'Area'}, stats = {'5% Increased Area', 'area_multiplier', 0.05}, links = {352, 398}, size = 1}
tree[398] = {x = -342, y = -366, types = {'Area'}, stats = {'5% Increased Area', 'area_multiplier', 0.05}, links = {397, 399}, size = 1}
tree[399] = {x = -318, y = -390, types = {'Area', 'Special'}, stats = {'Lesser Increased Self Explosion Size', 'lesser_increased_self_explosion_size', true}, links = {398}, size = 2}
tree[400] = {x = -594, y = -210, types = {'Attack'}, stats = {'12% Added Chance to Spawn Spread Attack', 'spread_spawn_chance', 20}, links = {363, 401}, size = 1}
tree[401] = {x = -618, y = -234, types = {'Attack'}, stats = {'12% Added Chance to Spawn Spread Attack', 'spread_spawn_chance', 20, 'Start With Spread Attack', 'start_with_spread', true}, links = {400}, size = 2}
tree[402] = {x = -618, y = -6, types = {'ASPD'}, stats = {'3% Increased Attack Speed', 'aspd_multiplier', 0.03}, links = {393, 403}, size = 1}
tree[403] = {x = -594, y = -30, types = {'ASPD'}, stats = {'3% Increased Attack Speed', 'aspd_multiplier', 0.04}, links = {402}, size = 1}
tree[404] = {x = -390, y = -522, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {365, 364, 405, 410, 447, 826, 825}, size = 1}
tree[405] = {x = -246, y = -666, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {404, 79, 406, 409, 821}, size = 1}
tree[406] = {x = 30, y = -666, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {405, 77, 421, 436, 438, 818, 817}, size = 1}
tree[407] = {x = -246, y = -450, types = {'Attack'}, stats = {'6% Added Chance to Spawn Double Attack', 'double_spawn_chance', 10}, links = {410, 408, 364, 414, 418}, size = 1}
tree[408] = {x = -174, y = -522, types = {'Area'}, stats = {'5% Increased Area', 'area_multiplier', 0.05}, links = {409, 79, 407, 411, 418}, size = 1}
tree[409] = {x = -246, y = -594, types = {'Attack'}, stats = {'6% Added Chance to Spawn Explode Attack', 'explode_spawn_chance', 10}, links = {410, 408, 405, 412, 418}, size = 1}
tree[410] = {x = -318, y = -522, types = {'Area'}, stats = {'5% Increased Area', 'area_multiplier', 0.05}, links = {404, 409, 407, 413, 418}, size = 1}
tree[411] = {x = -174, y = -558, types = {'Area'}, stats = {'5% Increased Area', 'area_multiplier', 0.05}, links = {408, 416}, size = 1}
tree[412] = {x = -282, y = -594, types = {'Attack'}, stats = {'6% Added Chance to Spawn Explode Attack', 'explode_spawn_chance', 10}, links = {409, 417}, size = 1}
tree[413] = {x = -318, y = -486, types = {'Area'}, stats = {'5% Increased Area', 'area_multiplier', 0.05}, links = {410, 420}, size = 1}
tree[414] = {x = -210, y = -450, types = {'Attack'}, stats = {'6% Added Chance to Spawn Double Attack', 'double_spawn_chance', 10}, links = {407, 415}, size = 1}
tree[415] = {x = -186, y = -474, types = {'Attack'}, stats = {'12% Added Chance to Spawn Triple Attack', 'triple_spawn_chance', 20}, links = {414}, size = 1}
tree[416] = {x = -198, y = -582, types = {'Area'}, stats = {'10% Increased Area', 'area_multiplier', 0.10}, links = {411}, size = 1}
tree[417] = {x = -306, y = -570, types = {'Attack'}, stats = {'12% Added Chance to Spawn Lightning Attack', 'lightning_spawn_chance', 20, 'Start With Lightning Attack', 'start_with_lightning', true}, links = {412}, size = 2}
tree[418] = {x = -246, y = -522, types = {'Area', 'Special'}, stats = {'25% Increased Area', 'area_multiplier', 0.20, '[Requires Lesser Increased Self Explosion Size]', 'greater_increased_self_explosion_size', true, 'Greater Increased Self Explosion Size', 'greater_increased_self_explosion_size', true}, links = {409, 410, 407, 408}, size = 3}
tree[419] = {x = -102, y = -558, types = {'Ammo'}, stats = {'4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {422, 79}, size = 1}
tree[420] = {x = -294, y = -462, types = {'Area'}, stats = {'10% Increased Area', 'area_multiplier', 0.10}, links = {413}, size = 1}
tree[421] = {x = -6, y = -630, types = {'Ammo'}, stats = {'2% Decreased Ammo Consumption', 'ammo_consumption_multiplier', -0.02}, links = {422, 406, 425}, size = 1}
tree[422] = {x = -6, y = -558, types = {'Ammo'}, stats = {'4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {421, 419, 423}, size = 1}
tree[423] = {x = -42, y = -594, types = {'Ammo'}, stats = {'4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {422, 424}, size = 1}
tree[424] = {x = -102, y = -594, types = {'Ammo'}, stats = {'8% Increased Ammo', 'ammo_multiplier', 0.08, '+30 Max Ammo', 'flat_ammo', 30}, links = {423}, size = 2}
tree[425] = {x = -102, y = -630, types = {'Ammo'}, stats = {'2% Decreased Ammo Consumption', 'ammo_consumption_multiplier', -0.02}, links = {421, 426}, size = 1}
tree[426] = {x = -138, y = -630, types = {'Ammo'}, stats = {'2% Decreased Ammo Consumption', 'ammo_consumption_multiplier', -0.02}, links = {425, 427}, size = 1}
tree[427] = {x = -174, y = -630, types = {'Ammo'}, stats = {'4% Decreased Ammo Consumption', 'ammo_consumption_multiplier', -0.04}, links = {426}, size = 1}
tree[428] = {x = 162, y = -546, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {78, 429}, size = 1}
tree[429] = {x = 186, y = -570, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {428, 430}, size = 1}
tree[430] = {x = 162, y = -594, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {429, 431}, size = 1}
tree[431] = {x = 138, y = -618, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {430, 432, 436}, size = 1}
tree[432] = {x = 114, y = -594, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {431, 433}, size = 1}
tree[433] = {x = 90, y = -570, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {432, 434}, size = 1}
tree[434] = {x = 114, y = -546, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {433, 435}, size = 1}
tree[435] = {x = 138, y = -570, types = {'HP'}, stats = {'6% Increased HP', 'hp_multiplier', 0.08, '+30 Max HP', 'flat_hp', 30}, links = {434}, size = 2}
tree[436] = {x = 138, y = -666, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {406, 437, 431, 812, 814}, size = 1}
tree[437] = {x = 306, y = -666, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {436, 87, 443, 449, 804, 800}, size = 1}
tree[438] = {x = 54, y = -642, types = {'Attack'}, stats = {'6% Added Chance to Spawn Lightning Attack', 'lightning_spawn_chance', 10}, links = {406, 439}, size = 1}
tree[439] = {x = 78, y = -618, types = {'Attack'}, stats = {'6% Added Chance to Spawn Lightning Attack', 'lightning_spawn_chance', 10}, links = {438}, size = 1}
tree[440] = {x = 270, y = -558, types = {'ES'}, stats = {'4% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.04}, links = {87, 446, 441}, size = 1}
tree[441] = {x = 234, y = -558, types = {'ES'}, stats = {'4% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.04}, links = {445, 440}, size = 1}
tree[443] = {x = 270, y = -630, types = {'ES'}, stats = {'4% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.04}, links = {446, 437, 444}, size = 1}
tree[444] = {x = 234, y = -630, types = {'ES'}, stats = {'4% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.04}, links = {443, 445}, size = 1}
tree[445] = {x = 234, y = -594, types = {'ES'}, stats = {'4% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.04}, links = {444, 441}, size = 1}
tree[446] = {x = 270, y = -594, types = {'ES'}, stats = {'4% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.04}, links = {440, 443}, size = 1}
tree[447] = {x = -390, y = -486, types = {'Attack'}, stats = {'12% Added Chance to Spawn Rapid Attack', 'rapid_spawn_chance', 20}, links = {404, 448}, size = 1}
tree[448] = {x = -390, y = -450, types = {'Attack'}, stats = {'12% Added Chance to Spawn Rapid Attack', 'rapid_spawn_chance', 20, 'Start With Rapid Attack', 'start_with_rapid', true}, links = {447}, size = 2}
tree[449] = {x = 558, y = -666, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {437, 463, 795}, size = 1}
tree[451] = {x = 354, y = -570, types = {'HP', 'Cycle'}, stats = {'1% Added Chance to Spawn HP on Cycle', 'spawn_hp_on_cycle_chance', 1}, links = {87, 452, 464}, size = 1}
tree[452] = {x = 402, y = -570, types = {'Attack'}, stats = {'4% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.04}, links = {451, 453}, size = 1}
tree[453] = {x = 462, y = -570, types = {'Attack'}, stats = {'4% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.04}, links = {452, 460}, size = 1}
tree[454] = {x = 354, y = -522, types = {'Resource'}, stats = {'4% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.04}, links = {87, 455}, size = 1}
tree[455] = {x = 402, y = -522, types = {'Resource'}, stats = {'4% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.04}, links = {454, 456}, size = 1}
tree[456] = {x = 462, y = -522, types = {'Resource'}, stats = {'4% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.04}, links = {455, 461}, size = 1}
tree[457] = {x = 354, y = -474, types = {'HP', 'Cycle'}, stats = {'1% Added Chance to Regain HP on Cycle', 'regain_hp_on_cycle_chance', 1}, links = {87, 458, 471}, size = 1}
tree[458] = {x = 402, y = -474, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {457, 459}, size = 1}
tree[459] = {x = 462, y = -474, types = {'Item'}, stats = {'4% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.04}, links = {458, 462}, size = 1}
tree[460] = {x = 510, y = -570, types = {'HP'}, stats = {'4% Increased Chance to Spawn HP', 'hp_spawn_chance_multiplier', 0.04}, links = {453, 463, 467}, size = 1}
tree[461] = {x = 510, y = -522, types = {'Resource'}, stats = {'4% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.04}, links = {456, 463}, size = 1}
tree[462] = {x = 510, y = -474, types = {'HP', 'SP'}, stats = {'1% Added Chance to Regain HP on SP Pickup', 'regain_hp_on_sp_pickup_chance', 1}, links = {459, 463, 474}, size = 1}
tree[463] = {x = 558, y = -522, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {449, 462, 460, 461, 478, 493, 791}, size = 1}
tree[464] = {x = 378, y = -594, types = {'HP', 'Cycle'}, stats = {'2% Added Chance to Spawn HP on Cycle', 'spawn_hp_on_cycle_chance', 2}, links = {451, 465}, size = 1}
tree[465] = {x = 354, y = -618, types = {'HP', 'Cycle'}, stats = {'1% Added Chance to Spawn HP on Cycle', 'spawn_hp_on_cycle_chance', 1}, links = {464, 470}, size = 1}
tree[467] = {x = 486, y = -594, types = {'HP'}, stats = {'8% Increased Chance to Spawn HP', 'hp_spawn_chance_multiplier', 0.08}, links = {460, 468}, size = 1}
tree[468] = {x = 510, y = -618, types = {'HP'}, stats = {'4% Increased Chance to Spawn HP', 'hp_spawn_chance_multiplier', 0.04}, links = {467, 470}, size = 1}
tree[470] = {x = 438, y = -618, types = {'HP'}, stats = {'8% Increased Chance to Spawn HP', 'hp_spawn_chance_multiplier', 0.08, 
'2% Added Chance to Spawn HP on Cycle', 'spawn_hp_on_cycle_chance', 2}, links = {465, 468}, size = 2}
tree[471] = {x = 378, y = -450, types = {'HP', 'Cycle'}, stats = {'2% Added Chance to Regain HP on Cycle', 'regain_hp_on_cycle_chance', 2}, links = {457, 472}, size = 1}
tree[472] = {x = 354, y = -426, types = {'HP', 'Cycle'}, stats = {'1% Added Chance to Regain HP on Cycle', 'regain_hp_on_cycle_chance', 1}, links = {471, 477}, size = 1}
tree[474] = {x = 486, y = -450, types = {'HP', 'SP'}, stats = {'2% Added Chance to Regain HP on SP Pickup', 'regain_hp_on_sp_pickup_chance', 2}, links = {462, 475}, size = 1}
tree[475] = {x = 510, y = -426, types = {'HP', 'SP'}, stats = {'1% Added Chance to Regain HP on SP Pickup', 'regain_hp_on_sp_pickup_chance', 1}, links = {474, 477}, size = 1}
tree[477] = {x = 438, y = -426, types = {'HP', 'SP', 'Cycle'}, stats = {'2% Added Chance to Regain HP on SP Pickup', 'regain_hp_on_sp_pickup_chance', 2, 
'2% Added Chance to Regain HP on Cycle', 'regain_hp_on_cycle_chance', 2}, links = {472, 475}, size = 2}
tree[478] = {x = 558, y = -378, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {299, 86, 479, 463, 516, 519}, size = 1}
tree[479] = {x = 522, y = -342, types = {'Attack'}, stats = {'8% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.08}, links = {478, 480}, size = 1}
tree[480] = {x = 486, y = -306, types = {'Attack'}, stats = {'8% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.08}, links = {479, 482, 481}, size = 1}
tree[481] = {x = 462, y = -282, types = {'Item'}, stats = {'8% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.08}, links = {480, 485}, size = 1}
tree[482] = {x = 462, y = -330, types = {'Attack'}, stats = {'8% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.08}, links = {480, 483}, size = 1}
tree[483] = {x = 426, y = -330, types = {'Attack'}, stats = {'8% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.08}, links = {482, 484}, size = 1}
tree[484] = {x = 390, y = -330, types = {'Attack'}, stats = {'8% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.08}, links = {483, 487}, size = 1}
tree[485] = {x = 426, y = -282, types = {'Item'}, stats = {'8% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.08}, links = {481, 486}, size = 1}
tree[486] = {x = 390, y = -282, types = {'Item'}, stats = {'8% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.08}, links = {485, 487}, size = 1}
tree[487] = {x = 366, y = -306, types = {'Attack'}, stats = {'8% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.08}, links = {484, 488, 486}, size = 1}
tree[488] = {x = 330, y = -270, types = {'Attack'}, stats = {'6% Added Chance to Spawn Explode Attack', 'explode_spawn_chance', 10}, links = {487, 489}, size = 1}
tree[489] = {x = 366, y = -234, types = {'Attack'}, stats = {'6% Added Chance to Spawn Explode Attack', 'explode_spawn_chance', 10}, links = {488, 490}, size = 1}
tree[490] = {x = 402, y = -234, types = {'Area'}, stats = {'10% Increased Area', 'area_multiplier', 0.10}, links = {489, 491}, size = 1}
tree[491] = {x = 438, y = -234, types = {'Area'}, stats = {'10% Increased Area', 'area_multiplier', 0.10}, links = {490, 492}, size = 1}
tree[492] = {x = 486, y = -234, types = {'Special', 'Cycle', 'Area', 'Attack'}, stats = {'25% Added Chance to Explode on Cycle', 'self_explode_on_cycle_chance', 25, '12% Added Chance to Spawn Explode Attack', 'explode_spawn_chance', 20, '20% Increased Area', 'area_multiplier', 0.20, 'Start With Explode Attack', 'start_with_explode', true}, links = {491}, size = 3}
tree[493] = {x = 702, y = -378, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {463, 494, 523, 783}, size = 1}
tree[494] = {x = 726, y = -354, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {493, 495, 782}, size = 1}
tree[495] = {x = 894, y = -186, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {494, 496, 537, 904}, size = 1}
tree[496] = {x = 894, y = -18, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {495, 497, 552, 774}, size = 1}
tree[497] = {x = 894, y = 234, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {496, 498, 326, 568, 764}, size = 1}
tree[498] = {x = 822, y = 306, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {497, 499, 760, 761}, size = 1}
tree[499] = {x = 702, y = 426, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {498, 500, 582, 751}, size = 1}
tree[500] = {x = 534, y = 426, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {499, 256, 501, 588, 601, 739}, size = 1}
tree[501] = {x = 534, y = 618, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {500, 257, 502, 597, 734}, size = 1}
tree[502] = {x = 438, y = 714, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {501, 602, 612, 731}, size = 1}
tree[507] = {x = -150, y = 714, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {508, 235, 651}, size = 1}
tree[508] = {x = -354, y = 714, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {507, 182, 509, 514, 885}, size = 1}
tree[509] = {x = -570, y = 714, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {513, 508, 664, 875}, size = 1}
tree[510] = {x = -726, y = 246, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {367, 150, 511, 692, 847}, size = 1}
tree[511] = {x = -642, y = 330, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {510, 512, 680, 855}, size = 1}
tree[512] = {x = -642, y = 486, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {181, 511, 513, 866}, size = 1}
tree[513] = {x = -642, y = 642, types = {'Item'}, stats = {'2% Increased Item Spawn Rate', 'item_spawn_rate_multiplier', 0.02}, links = {512, 509, 870}, size = 1}
tree[514] = {x = -258, y = 810, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {508, 616}, size = 1}
tree[516] = {x = 582, y = -402, types = {'Luck'}, stats = {'5% Increased Luck', 'luck_multiplier', 0.05}, links = {478, 517}, size = 1}
tree[517] = {x = 606, y = -426, types = {'Luck'}, stats = {'5% Increased Luck', 'luck_multiplier', 0.05}, links = {516, 518, 524}, size = 1}
tree[518] = {x = 582, y = -450, types = {'Luck'}, stats = {'10% Increased Luck', 'luck_multiplier', 0.10}, links = {517}, size = 1}
tree[519] = {x = 582, y = -354, types = {'Attack'}, stats = {'8% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.08}, links = {478, 521}, size = 1}
tree[521] = {x = 630, y = -354, types = {'Attack'}, stats = {'8% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.08}, links = {519, 523, 525}, size = 1}
tree[523] = {x = 678, y = -354, types = {'Attack'}, stats = {'4% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.04}, links = {493, 521}, size = 1}
tree[524] = {x = 630, y = -402, types = {'Barrage', 'Special'}, stats = {'Barrage Nova', 'barrage_nova', true, '+2 Barrage Projectiles', 'additional_barrage_projectile', 2}, links = {517}, size = 2}
tree[525] = {x = 654, y = -330, types = {'Attack'}, stats = {'8% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.08}, links = {521, 526, 527, 528}, size = 1}
tree[526] = {x = 618, y = -294, types = {'Special', 'Cycle'}, stats = {'2% Added Chance to Explode on Cycle', 'self_explode_on_cycle_chance', 2}, links = {525, 529}, size = 1}
tree[527] = {x = 654, y = -294, types = {'ES'}, stats = {'8% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.08}, links = {525, 530}, size = 1}
tree[528] = {x = 690, y = -294, types = {'Attack'}, stats = {'8% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.08}, links = {525, 531}, size = 1}
tree[529] = {x = 618, y = -258, types = {'Special', 'Cycle'}, stats = {'2% Added Chance to Explode on Cycle', 'self_explode_on_cycle_chance', 2}, links = {526, 532}, size = 1}
tree[530] = {x = 654, y = -258, types = {'ES'}, stats = {'8% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.08}, links = {527, 533}, size = 1}
tree[531] = {x = 690, y = -258, types = {'Attack'}, stats = {'8% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.08}, links = {528, 534}, size = 1}
tree[532] = {x = 618, y = -222, types = {'Special', 'Cycle'}, stats = {'2% Added Chance to Explode on Cycle', 'self_explode_on_cycle_chance', 2}, links = {529, 535}, size = 1}
tree[533] = {x = 654, y = -222, types = {'ES'}, stats = {'8% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.08}, links = {530, 535}, size = 1}
tree[534] = {x = 690, y = -222, types = {'Attack'}, stats = {'8% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.08}, links = {531, 535}, size = 1}
tree[535] = {x = 654, y = -186, types = {'Resource'}, stats = {'4% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.04}, links = {532, 533, 534, 299, 536, 546}, size = 1}
tree[536] = {x = 738, y = -186, types = {'Resource'}, stats = {'4% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.04}, links = {535, 537, 541, 545}, size = 1}
tree[537] = {x = 810, y = -186, types = {'Resource'}, stats = {'4% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.04}, links = {536, 495, 538, 544}, size = 1}
tree[538] = {x = 834, y = -210, types = {'MVSPD'}, stats = {'8% Decreased Movement Speed', 'mvspd_multiplier', -0.08}, links = {537, 539}, size = 1}
tree[539] = {x = 810, y = -234, types = {'MVSPD'}, stats = {'8% Decreased Movement Speed', 'mvspd_multiplier', -0.08}, links = {538, 540}, size = 1}
tree[540] = {x = 786, y = -210, types = {'MVSPD'}, stats = {'16% Decreased Movement Speed', 'mvspd_multiplier', -0.16}, links = {539}, size = 1}
tree[541] = {x = 738, y = -222, types = {'ES'}, stats = {'8% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.08}, links = {536, 542}, size = 1}
tree[542] = {x = 762, y = -246, types = {'ES'}, stats = {'8% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.08}, links = {541, 543}, size = 1}
tree[543] = {x = 738, y = -270, types = {'ES'}, stats = {'16% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.16}, links = {542}, size = 1}
tree[544] = {x = 810, y = -150, types = {'Attack'}, stats = {'12% Added Chance to Spawn Blast Attack', 'blast_spawn_chance', 20, 'Start with Blast Attack', 'start_with_blast', true}, links = {537, 549}, size = 2}
tree[545] = {x = 738, y = -150, types = {'Attack'}, stats = {'12% Added Chance to Spawn Flame Attack', 'flame_spawn_chance', 20, 'Start With Flame Attack', 'start_with_flame', true}, links = {536, 548}, size = 2}
tree[546] = {x = 654, y = -150, types = {'Attack'}, stats = {'12% Added Chance to Spawn Spin Attack', 'spin_spawn_chance', 20}, links = {535, 547}, size = 1}
tree[547] = {x = 690, y = -114, types = {'Attack'}, stats = {'12% Added Chance to Spawn Spin Attack', 'spin_spawn_chance', 20}, links = {546, 550}, size = 1}
tree[548] = {x = 774, y = -114, types = {'Attack'}, stats = {'12% Added Chance to Spawn Flame Attack', 'flame_spawn_chance', 20}, links = {545, 551}, size = 1}
tree[549] = {x = 846, y = -114, types = {'Attack'}, stats = {'12% Added Chance to Spawn Blast Attack', 'blast_spawn_chance', 20}, links = {544, 551}, size = 1}
tree[550] = {x = 726, y = -78, types = {'Attack'}, stats = {'6% Added Chance to Spawn Spin Attack', 'spin_spawn_chance', 10}, links = {547, 551}, size = 1}
tree[551] = {x = 810, y = -78, types = {'Attack'}, stats = {'6% Added Chance to Spawn Flame Attack', 'flame_spawn_chance', 10, 
'6% Added Chance to Spawn Blast Attack', 'blast_spawn_chance', 10}, links = {548, 549, 550, 552}, size = 1}
tree[552] = {x = 810, y = -18, types = {'Resource'}, stats = {'2% Increased Resource Spawn Rate', 'resource_spawn_rate_multiplier', 0.02}, links = {551, 328, 496, 553, 556, 559}, size = 1}
tree[553] = {x = 810, y = 90, types = {'Cycle'}, stats = {'8% Increased Cycle Speed', 'cycle_multiplier', 0.08}, links = {552, 554, 327, 557, 560, 561}, size = 1}
tree[554] = {x = 774, y = 54, types = {'Homing', 'Cycle'}, stats = {'3% Added Chance to Launch Homing Projectile on Cycle', 'launch_homing_projectile_on_cycle_chance', 3}, links = {553, 556}, size = 1}
tree[556] = {x = 774, y = 18, types = {'Homing', 'Cycle'}, stats = {'3% Added Chance to Launch Homing Projectile on Cycle', 'launch_homing_projectile_on_cycle_chance', 3}, links = {552, 554}, size = 1}
tree[557] = {x = 846, y = 54, types = {'Barrage', 'Cycle'}, stats = {'3% Added Chance to Barrage on Cycle', 'barrage_on_cycle_chance', 3}, links = {553, 559}, size = 1}
tree[559] = {x = 846, y = 18, types = {'Barrage', 'Cycle'}, stats = {'3% Added Chance to Barrage on Cycle', 'barrage_on_cycle_chance', 3}, links = {552, 557}, size = 1}
tree[560] = {x = 786, y = 114, types = {'Cycle'}, stats = {'8% Increased Cycle Speed', 'cycle_multiplier', 0.08}, links = {553, 562, 580}, size = 1}
tree[561] = {x = 834, y = 114, types = {'Cycle'}, stats = {'8% Increased Cycle Speed', 'cycle_multiplier', 0.08}, links = {564, 553, 580}, size = 1}
tree[562] = {x = 762, y = 138, types = {'Cycle'}, stats = {'8% Increased Cycle Speed', 'cycle_multiplier', 0.08}, links = {560, 563}, size = 1}
tree[563] = {x = 786, y = 162, types = {'Cycle'}, stats = {'8% Increased Cycle Speed', 'cycle_multiplier', 0.08}, links = {562, 566, 580}, size = 1}
tree[564] = {x = 858, y = 138, types = {'Cycle'}, stats = {'8% Increased Cycle Speed', 'cycle_multiplier', 0.08}, links = {565, 561}, size = 1}
tree[565] = {x = 834, y = 162, types = {'Cycle'}, stats = {'8% Increased Cycle Speed', 'cycle_multiplier', 0.08}, links = {566, 564, 580}, size = 1}
tree[566] = {x = 810, y = 186, types = {'Cycle'}, stats = {'8% Increased Cycle Speed', 'cycle_multiplier', 0.08}, links = {563, 565, 567, 569}, size = 1}
tree[567] = {x = 834, y = 210, types = {'SP'}, stats = {'2% Added Chance to Gain Double SP', 'gain_double_sp_chance', 2}, links = {566, 568}, size = 1}
tree[568] = {x = 870, y = 210, types = {'SP'}, stats = {'2% Added Chance to Gain Double SP', 'gain_double_sp_chance', 2}, links = {567, 497}, size = 1}
tree[569] = {x = 786, y = 210, types = {'SP', 'Cycle'}, stats = {'2% Added Chance to Spawn SP on Cycle', 'spawn_sp_on_cycle_chance', 2}, links = {566, 570}, size = 1}
tree[570] = {x = 750, y = 210, types = {'SP', 'Cycle'}, stats = {'2% Added Chance to Spawn SP on Cycle', 'spawn_sp_on_cycle_chance', 2}, links = {569, 326}, size = 1}
tree[571] = {x = 750, y = 258, types = {'Cycle'}, stats = {'5% Increased Cycle Speed', 'cycle_multiplier', 0.05}, links = {326, 572}, size = 1}
tree[572] = {x = 726, y = 282, types = {'Cycle'}, stats = {'5% Increased Cycle Speed', 'cycle_multiplier', 0.05}, links = {571, 573}, size = 1}
tree[573] = {x = 750, y = 306, types = {'Cycle'}, stats = {'10% Increased Cycle Speed', 'cycle_multiplier', 0.10}, links = {572, 574}, size = 1}
tree[574] = {x = 774, y = 282, types = {'Cycle'}, stats = {'10% Increased Cycle Speed', 'cycle_multiplier', 0.10}, links = {573}, size = 1}
tree[575] = {x = 678, y = 330, types = {'PSPD'}, stats = {'10% Decreased Projectile Speed', 'pspd_multiplier', -0.10}, links = {325, 576, 582}, size = 1}
tree[576] = {x = 654, y = 354, types = {'PSPD'}, stats = {'10% Decreased Projectile Speed', 'pspd_multiplier', -0.10}, links = {575, 577}, size = 1}
tree[577] = {x = 630, y = 330, types = {'PSPD'}, stats = {'10% Decreased Projectile Speed', 'pspd_multiplier', -0.10}, links = {576}, size = 1}
tree[578] = {x = 582, y = 330, types = {'Cycle'}, stats = {'10% Increased Cycle Speed', 'cycle_multiplier', 0.10}, links = {312, 579}, size = 1}
tree[579] = {x = 558, y = 354, types = {'Cycle'}, stats = {'10% Increased Cycle Speed', 'cycle_multiplier', 0.10}, links = {578, 581}, size = 1}
tree[580] = {x = 810, y = 138, types = {'Homing', 'Barrage', 'ASPD', 'SP', 'Attack', 'Cycle'}, stats = {'+1 Homing Projectile', 'additional_homing_projectile', 1, '+2 Barrage Projectiles', 'additional_barrage_projectile', 2, '5% Added Chance to Spawn Haste Area on SP Pickup', 'spawn_haste_area_on_sp_pickup_chance', 5, '10% Added Chance to Change Attack on Cycle', 'change_attack_on_cycle_chance', 10}, 
links = {560, 561, 565, 563}, size = 2}
tree[581] = {x = 534, y = 330, types = {'Cycle'}, stats = {'10% Increased Cycle Speed', 'cycle_multiplier', 0.10}, links = {579}, size = 1}
tree[582] = {x = 702, y = 354, types = {'PSPD'}, stats = {'10% Decreased Projectile Speed', 'pspd_multiplier', -0.10}, links = {575, 499}, size = 1}
tree[583] = {x = 438, y = 342, types = {'Attack'}, stats = {'6% Added Chance to Spawn Bounce Attack', 'bounce_spawn_chance', 10}, links = {311, 584}, size = 1}
tree[584] = {x = 402, y = 342, types = {'Attack'}, stats = {'6% Added Chance to Spawn Bounce Attack', 'bounce_spawn_chance', 10}, links = {583, 585}, size = 1}
tree[585] = {x = 402, y = 378, types = {'Attack'}, stats = {'+1 Bounce to Bounce Projectiles', 'additional_bounce', 1}, links = {584, 586}, size = 1}
tree[586] = {x = 438, y = 378, types = {'Attack'}, stats = {'+1 Bounce to Bounce Projectiles', 'additional_bounce', 1}, links = {585, 587}, size = 1}
tree[587] = {x = 486, y = 378, types = {'Attack'}, stats = {'18% Added Chance to Spawn Bounce Attack', 'bounce_spawn_chance', 30, 'Start With Bounce Attack', 'start_with_bounce', true}, links = {586}, size = 2}
tree[588] = {x = 570, y = 390, types = {'ES'}, stats = {'8% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.08}, links = {500, 589}, size = 1}
tree[589] = {x = 606, y = 390, types = {'ES'}, stats = {'8% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.08}, links = {588, 590}, size = 1}
tree[590] = {x = 642, y = 390, types = {'ES'}, stats = {'8% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.08}, links = {589}, size = 1}
tree[591] = {x = 390, y = 450, types = {'Invuln'}, stats = {'4% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.04}, links = {256, 592}, size = 1}
tree[592] = {x = 414, y = 474, types = {'Invuln'}, stats = {'8% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.08}, links = {591, 593}, size = 1}
tree[593] = {x = 414, y = 522, types = {'Invuln'}, stats = {'8% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.08}, links = {592, 595, 901}, size = 1}
tree[594] = {x = 390, y = 594, types = {'Invuln'}, stats = {'4% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.04}, links = {595, 257}, size = 1}
tree[595] = {x = 414, y = 570, types = {'Invuln'}, stats = {'8% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.08}, links = {593, 594}, size = 1}
tree[597] = {x = 510, y = 594, types = {'Cycle'}, stats = {'4% Increased Cycle Speed', 'cycle_multiplier', 0.04}, links = {598, 501}, size = 1}
tree[598] = {x = 486, y = 570, types = {'Cycle'}, stats = {'8% Increased Cycle Speed', 'cycle_multiplier', 0.08}, links = {599, 597}, size = 1}
tree[599] = {x = 486, y = 522, types = {'Cycle'}, stats = {'8% Increased Cycle Speed', 'cycle_multiplier', 0.08}, links = {600, 598, 901}, size = 1}
tree[600] = {x = 486, y = 474, types = {'Cycle'}, stats = {'8% Increased Cycle Speed', 'cycle_multiplier', 0.08}, links = {601, 599}, size = 1}
tree[601] = {x = 510, y = 450, types = {'Cycle'}, stats = {'4% Increased Cycle Speed', 'cycle_multiplier', 0.04}, links = {500, 600}, size = 1}
tree[901] = {x = 450, y = 522, types = {'Invuln', 'Boost'}, stats = {'Invulnerability While Boosting', 'invulnerability_while_boosting', true}, links = {593, 599}, size = 3}
tree[602] = {x = 402, y = 714, types = {'MVSPD'}, stats = {'5% Increased Movement Speed', 'mvspd_multiplier', 0.05}, links = {502, 603, 606}, size = 1}
tree[603] = {x = 402, y = 666, types = {'Boost'}, stats = {'8% Increased Boost Recharge Rate', 'boost_recharge_rate_multiplier', 0.08}, links = {602, 604, 611}, size = 1}
tree[604] = {x = 366, y = 666, types = {'Boost'}, stats = {'8% Increased Boost Recharge Rate', 'boost_recharge_rate_multiplier', 0.08}, links = {603, 257}, size = 1}
tree[606] = {x = 366, y = 714, types = {'MVSPD'}, stats = {'5% Increased Movement Speed', 'mvspd_multiplier', 0.05}, links = {602, 610}, size = 1}
tree[607] = {x = 342, y = 738, types = {'Boost'}, stats = {'20% Increased Boost Effectiveness', 'boost_effectiveness_multiplier', 0.20}, links = {610, 608}, size = 1}
tree[608] = {x = 306, y = 774, types = {'Boost'}, stats = {'8% Increased Chance to Spawn Boost', 'boost_spawn_chance_multiplier', 0.08}, links = {607, 609}, size = 1}
tree[609] = {x = 282, y = 798, types = {'Boost'}, stats = {'+10 Max Boost', 'flat_boost', 10}, links = {608, 630}, size = 1}
tree[610] = {x = 318, y = 714, types = {'MVSPD'}, stats = {'5% Increased Movement Speed', 'mvspd_multiplier', 0.05}, links = {606, 607}, size = 1}
tree[611] = {x = 426, y = 642, types = {'Boost'}, stats = {'8% Increased Boost Recharge Rate', 'boost_recharge_rate_multiplier', 0.08}, links = {603}, size = 1}
tree[612] = {x = 270, y = 882, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {502, 701, 723, 905}, size = 1}
tree[905] = {x = 234, y = 846, types = {'Boost', 'HP'}, stats = {'Refills Boost if HP is Full on HP Pickup', 'refill_boost_if_hp_full', true}, links = {612}, size = 2}
tree[614] = {x = -78, y = 882, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {641, 703, 702, 712, 709}, size = 1}
tree[616] = {x = -258, y = 882, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {514, 703, 704}, size = 1}
tree[618] = {x = 150, y = 762, types = {'Boost', 'Kill'}, stats = {'1% Added Chance to Spawn Boost on Kill', 'spawn_boost_on_kill_chance', 1}, links = {630, 619}, size = 1}
tree[619] = {x = 102, y = 762, types = {'Boost', 'Kill'}, stats = {'2% Added Chance to Spawn Boost on Kill', 'spawn_boost_on_kill_chance', 2}, links = {618, 620}, size = 1}
tree[620] = {x = 54, y = 762, types = {'Boost', 'Kill'}, stats = {'2% Added Chance to Spawn Boost on Kill', 'spawn_boost_on_kill_chance', 2}, links = {619, 621}, size = 1}
tree[621] = {x = 6, y = 762, types = {'Boost', 'Kill'}, stats = {'1% Added Chance to Spawn Boost on Kill', 'spawn_boost_on_kill_chance', 1}, links = {620, 900}, size = 1}
tree[622] = {x = 150, y = 798, types = {'Boost', 'Kill'}, stats = {'1% Added Chance to Regain Boost on Kill', 'regain_boost_on_kill_chance', 1}, links = {630, 623}, size = 1}
tree[623] = {x = 102, y = 798, types = {'Boost', 'Kill'}, stats = {'2% Added Chance to Regain Boost on Kill', 'regain_boost_on_kill_chance', 2}, links = {622, 624}, size = 1}
tree[624] = {x = 54, y = 798, types = {'Boost', 'Kill'}, stats = {'2% Added Chance to Regain Boost on Kill', 'regain_boost_on_kill_chance', 2}, links = {623, 625}, size = 1}
tree[625] = {x = 6, y = 798, types = {'Boost', 'Kill'}, stats = {'1% Added Chance to Regain Boost on Kill', 'regain_boost_on_kill_chance', 1}, links = {624, 900}, size = 1}
tree[626] = {x = 150, y = 834, types = {'Barrage', 'Kill'}, stats = {'1% Added Chance to Barrage on Kill', 'barrage_on_kill_chance', 1}, links = {627, 630}, size = 1}
tree[627] = {x = 102, y = 834, types = {'Barrage', 'Kill'}, stats = {'2% Added Chance to Barrage on Kill', 'barrage_on_kill_chance', 2}, links = {628, 626}, size = 1}
tree[628] = {x = 54, y = 834, types = {'Barrage', 'Kill'}, stats = {'2% Added Chance to Barrage on Kill', 'barrage_on_kill_chance', 2}, links = {629, 627}, size = 1}
tree[629] = {x = 6, y = 834, types = {'Barrage', 'Kill'}, stats = {'1% Added Chance to Barrage on Kill', 'barrage_on_kill_chance', 1}, links = {628, 900}, size = 1}
tree[900] = {x = -30, y = 798, types = {'Boost', 'ASPD'}, stats = {'32% Increased Chance to Spawn Boost', 'boost_spawn_chance_multiplier', 0.32, '8% Decreased Attack Speed', 'aspd_multiplier', -0.08}, 
links = {631, 625, 621, 629}, size = 2}
tree[630] = {x = 186, y = 798, types = {'Boost', 'ASPD'}, stats = {'32% Increased Chance to Spawn Boost', 'boost_spawn_chance_multiplier', 0.32, 
'8% Decreased Attack Speed', 'aspd_multiplier', -0.08}, links = {609, 246, 618, 622, 626}, size = 2}
tree[631] = {x = -78, y = 798, types = {'Boost'}, stats = {'4% Increased Boost', 'boost_multiplier', 0.04}, links = {633, 636, 900}, size = 1}
tree[632] = {x = -78, y = 762, types = {'Turn Rate'}, stats = {'8% Decreased Turn Rate', 'turn_rate_multiplier', -0.08}, links = {633, 235}, size = 1}
tree[633] = {x = -114, y = 762, types = {'Turn Rate'}, stats = {'8% Decreased Turn Rate', 'turn_rate_multiplier', -0.08}, links = {631, 635, 632}, size = 1}
tree[634] = {x = -186, y = 762, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {639, 635}, size = 1}
tree[635] = {x = -150, y = 798, types = {'Turn Rate'}, stats = {'8% Decreased Turn Rate', 'turn_rate_multiplier', -0.08}, links = {633, 636, 638, 634}, size = 1}
tree[636] = {x = -114, y = 834, types = {'Boost'}, stats = {'4% Increased Boost', 'boost_multiplier', 0.04}, links = {631, 635, 641}, size = 1}
tree[638] = {x = -186, y = 834, types = {'Turn Rate', 'Size', 'Ammo'}, stats = {'24% Decreased Turn Rate', 'turn_rate_multiplier', -0.24, '10% Increased Size', 'size_multiplier', 0.10, 
'-15 Max Ammo', 'flat_ammo', -15, '20% Increased Ammo Consumption', 'ammo_consumption_multiplier', 0.20}, links = {635}, size = 2}
tree[639] = {x = -222, y = 762, types = {'HP'}, stats = {'8% Increased HP', 'hp_multiplier', 0.08, '8% Increased Movement Speed', 'mvspd_multiplier', 0.08}, links = {640, 634}, size = 2}
tree[640] = {x = -258, y = 762, types = {'HP'}, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {639}, size = 1}
tree[641] = {x = -78, y = 834, types = {'Boost'}, stats = {'4% Increased Boost', 'boost_multiplier', 0.04}, links = {636, 614}, size = 1}
tree[642] = {x = -102, y = 582, types = {'Turn Rate'}, stats = {'4% Increased Turn Rate', 'turn_rate_multiplier', 0.04}, links = {230, 643}, size = 1}
tree[643] = {x = -126, y = 606, types = {'Turn Rate'}, stats = {'4% Increased Turn Rate', 'turn_rate_multiplier', 0.04}, links = {642, 644}, size = 1}
tree[644] = {x = -150, y = 630, types = {'Turn Rate'}, stats = {'4% Increased Turn Rate', 'turn_rate_multiplier', 0.04}, links = {643, 645}, size = 1}
tree[645] = {x = -174, y = 606, types = {'Turn Rate'}, stats = {'4% Increased Turn Rate', 'turn_rate_multiplier', 0.04}, links = {644, 646}, size = 1}
tree[646] = {x = -150, y = 582, types = {'Turn Rate'}, stats = {'4% Increased Turn Rate', 'turn_rate_multiplier', 0.04}, links = {645, 647}, size = 1}
tree[647] = {x = -150, y = 534, types = {'Turn Rate', 'Size', 'Ammo'}, stats = {'16% Increased Turn Rate', 'turn_rate_multiplier', 0.16, '20% Decreased Size', 'size_multiplier', 0.20, 
'-15 Max Ammo', 'flat_ammo', -15, '20% Increased Ammo Consumption', 'ammo_consumption_multiplier', 0.20}, links = {646}, size = 2}
tree[648] = {x = -186, y = 522, types = {'Attack'}, stats = {'12% Added Chance to Spawn Homing Attack', 'homing_spawn_chance', 20}, links = {195, 649}, size = 1}
tree[649] = {x = -186, y = 558, types = {'Attack'}, stats = {'12% Added Chance to Spawn Homing Attack', 'homing_spawn_chance', 20, 'Start With Homing Attack', 'start_with_homing', true}, links = {648}, size = 2}
tree[651] = {x = -222, y = 642, types = {'MVSPD'}, stats = {'8% Increased Movement Speed', 'mvspd_multiplier', 0.08}, links = {507, 652, 656}, size = 1}
tree[652] = {x = -222, y = 606, types = {'MVSPD'}, stats = {'8% Increased Movement Speed', 'mvspd_multiplier', 0.08}, links = {651, 653}, size = 1}
tree[653] = {x = -258, y = 570, types = {'Boost'}, stats = {'4% Increased Boost', 'boost_multiplier', 0.04}, links = {652, 654, 658}, size = 1}
tree[654] = {x = -294, y = 606, types = {'Boost'}, stats = {'8% Increased Boost', 'boost_multiplier', 0.08}, links = {653, 655}, size = 1}
tree[655] = {x = -294, y = 642, types = {'Boost'}, stats = {'8% Increased Boost', 'boost_multiplier', 0.08}, links = {654, 656}, size = 1}
tree[656] = {x = -258, y = 678, types = {'Boost'}, stats = {'16% Increased Boost', 'boost_multiplier', 0.16}, links = {655, 651}, size = 1}
tree[657] = {x = -318, y = 522, types = {'Boost'}, stats = {'4% Increased Boost', 'boost_multiplier', 0.4}, links = {182, 658}, size = 1}
tree[658] = {x = -258, y = 522, types = {'Special', 'Ammo'}, stats = {'Half Ammo', 'half_ammo', true, '+100 Max Boost', 'flat_boost', 100}, links = {657, 653}, size = 3}
tree[659] = {x = -498, y = 642, types = {'Proj'}, stats = {'10% Increased Projectile Duration', 'projectile_duration_multiplier', 0.10}, links = {661, 660, 664}, size = 1}
tree[660] = {x = -450, y = 594, types = {'Proj'}, stats = {'10% Increased Projectile Duration', 'projectile_duration_multiplier', 0.10}, links = {662, 659}, size = 1}
tree[661] = {x = -522, y = 618, types = {'Buff'}, stats = {'10% Increased Stat Boost Duration', 'stat_boost_duration_multiplier', 0.10}, links = {663, 659}, size = 1}
tree[662] = {x = -498, y = 546, types = {'Buff', 'Proj'}, stats = {'20% Increased Stat Boost Duration', 'stat_boost_duration_multiplier', 0.20, 
'20% Increased Projectile Duration', 'projectile_duration_multiplier', 0.20}, links = {663, 660}, size = 2}
tree[663] = {x = -522, y = 570, types = {'Buff'}, stats = {'10% Increased Stat Boost Duration', 'stat_boost_duration_multiplier', 0.10}, links = {661, 662}, size = 1}
tree[664] = {x = -534, y = 678, types = {'ES'}, stats = {'10% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.10}, links = {509, 659, 665, 675}, size = 1}
tree[665] = {x = -570, y = 642, types = {'ES'}, stats = {'10% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.10}, links = {664, 666}, size = 1}
tree[666] = {x = -594, y = 618, types = {'ES'}, stats = {'10% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.10}, links = {665, 668}, size = 1}
tree[667] = {x = -570, y = 546, types = {'Proj'}, stats = {'10% Increased Projectile Duration', 'projectile_duration_multiplier', 0.10}, links = {668, 669, 181}, size = 1}
tree[668] = {x = -594, y = 570, types = {'Proj'}, stats = {'10% Increased Projectile Duration', 'projectile_duration_multiplier', 0.10}, links = {666, 667}, size = 1}
tree[669] = {x = -534, y = 510, types = {'Proj'}, stats = {'10% Increased Projectile Duration', 'projectile_duration_multiplier', 0.10}, links = {667}, size = 1}
tree[670] = {x = -462, y = 510, types = {'ES'}, stats = {'10% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.10}, links = {671}, size = 1}
tree[671] = {x = -426, y = 546, types = {'ES'}, stats = {'10% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.10}, links = {670, 672}, size = 1}
tree[672] = {x = -402, y = 570, types = {'ES'}, stats = {'10% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.10}, links = {671, 673}, size = 1}
tree[673] = {x = -402, y = 618, types = {'Cycle'}, stats = {'10% Increased Cycle Speed', 'cycle_multiplier', 0.10}, links = {672, 674}, size = 1}
tree[674] = {x = -426, y = 642, types = {'Cycle'}, stats = {'10% Increased Cycle Speed', 'cycle_multiplier', 0.10}, links = {673, 675}, size = 1}
tree[675] = {x = -462, y = 678, types = {'Cycle'}, stats = {'10% Increased Cycle Speed', 'cycle_multiplier', 0.10}, links = {674, 664}, size = 1}
tree[676] = {x = -606, y = 450, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {181, 677}, size = 1}
tree[677] = {x = -606, y = 414, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {676, 678}, size = 1}
tree[678] = {x = -606, y = 378, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {677, 679}, size = 1}
tree[679] = {x = -606, y = 342, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {678, 680}, size = 1}
tree[680] = {x = -606, y = 294, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {679, 511, 681}, size = 1}
tree[681] = {x = -630, y = 270, types = {'HP'}, stats = {'6% Increased HP', 'hp_multiplier', 0.06, '+10 Max HP', 'flat_hp', 10}, links = {680}, size = 2}
tree[684] = {x = -534, y = 210, types = {'Proj'}, stats = {'5% Added Projectile Waviness', 'projectile_waviness_multiplier', 0.05}, links = {150, 685}, size = 1}
tree[685] = {x = -534, y = 174, types = {'Proj'}, stats = {'5% Added Projectile Waviness', 'projectile_waviness_multiplier', 0.05}, links = {684, 686}, size = 1}
tree[686] = {x = -534, y = 138, types = {'Proj'}, stats = {'5% Added Projectile Waviness', 'projectile_waviness_multiplier', 0.05}, links = {685, 687}, size = 1}
tree[687] = {x = -534, y = 102, types = {'Proj'}, stats = {'5% Added Projectile Waviness', 'projectile_waviness_multiplier', 0.05}, links = {686, 129}, size = 1}
tree[688] = {x = -606, y = 210, types = {'Proj'}, stats = {'5% Increased Angle Change Frequency', 'projectile_angle_change_frequency_multiplier', 0.05}, links = {689, 150}, size = 1}
tree[689] = {x = -606, y = 174, types = {'Proj'}, stats = {'5% Increased Angle Change Frequency', 'projectile_angle_change_frequency_multiplier', 0.05}, links = {690, 688}, size = 1}
tree[690] = {x = -606, y = 138, types = {'Proj'}, stats = {'5% Increased Angle Change Frequency', 'projectile_angle_change_frequency_multiplier', 0.05}, links = {691, 689}, size = 1}
tree[691] = {x = -606, y = 102, types = {'Proj'}, stats = {'5% Increased Angle Change Frequency', 'projectile_angle_change_frequency_multiplier', 0.05}, links = {690}, size = 1}
tree[692] = {x = -690, y = 210, types = {'ASPD', 'SP'}, stats = {'1% Added Chance to Spawn Haste Area on SP Pickup', 'spawn_haste_area_on_sp_pickup_chance', 1}, links = {510, 695}, size = 1}
tree[693] = {x = -690, y = 54, types = {'Special', 'HP'}, stats = {'Refills Ammo if HP is Full on HP Pickup', 'refill_ammo_if_hp_full', true}, links = {367}, size = 2}
tree[694] = {x = -606, y = 54, types = {'Special', 'Proj'}, stats = {'Explosions Create Projectiles Instead', 'projectiles_explosions', true}, links = {127}, size = 3}
tree[695] = {x = -654, y = 174, types = {'ASPD', 'SP'}, stats = {'1% Added Chance to Spawn Haste Area on SP Pickup', 'spawn_haste_area_on_sp_pickup_chance', 1}, links = {692, 696}, size = 1}
tree[696] = {x = -654, y = 138, types = {'ASPD', 'SP'}, stats = {'1% Added Chance to Spawn Haste Area on SP Pickup', 'spawn_haste_area_on_sp_pickup_chance', 1}, links = {695, 697}, size = 1}
tree[697] = {x = -654, y = 102, types = {'ASPD', 'SP'}, stats = {'2% Added Chance to Spawn Haste Area on SP Pickup', 'spawn_haste_area_on_sp_pickup_chance', 2}, links = {696}, size = 1}
tree[698] = {x = -462, y = 138, types = {'Attack'}, stats = {'12% Added Chance to Spawn Back Attack', 'back_spawn_chance', 20}, links = {129, 699}, size = 1}
tree[699] = {x = -462, y = 174, types = {'Attack'}, stats = {'12% Added Chance to Spawn Back Attack', 'back_spawn_chance', 20}, links = {698}, size = 1}
tree[700] = {x = 330, y = 582, types = {'Special', 'Boost'}, stats = {'Only Spawn Boost', 'only_spawn_boost', true}, links = {257}, size = 2}
tree[701] = {x = 150, y = 882, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {702, 612, 724, 725}, size = 1}
tree[702] = {x = 42, y = 882, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {614, 716, 612}, size = 1}
tree[703] = {x = -186, y = 882, types = {'Invuln'}, stats = {'2% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.02}, links = {616, 614, 707, 705}, size = 1}
tree[704] = {x = -294, y = 918, types = {'Special', 'Ammo'}, stats = {'Half Ammo', 'half_ammo', true, '+50 Max HP', 'flat_hp', 50}, links = {616}, size = 3}
tree[705] = {x = -222, y = 918, types = {'Attack'}, stats = {'6% Added Chance to Spawn 2Split Attack', 'twosplit_spawn_chance', 10}, links = {706, 703}, size = 1}
tree[706] = {x = -222, y = 954, types = {'Attack'}, stats = {'6% Added Chance to Spawn 2Split Attack', 'twosplit_spawn_chance', 10}, links = {708, 705}, size = 1}
tree[707] = {x = -150, y = 918, types = {'Attack'}, stats = {'6% Added Chance to Spawn 4Split Attack', 'foursplit_spawn_chance', 10}, links = {703, 708}, size = 1}
tree[708] = {x = -186, y = 954, types = {'Attack'}, stats = {'6% Added Chance to Spawn 2Split Attack', 'twosplit_spawn_chance', 10, '6% Added Chance to Spawn 4Split Attack', 'foursplit_spawn_chance', 10, 
'Start With 2Split Attack', 'start_with_2split', true}, links = {707, 706}, size = 2}
tree[709] = {x = -54, y = 906, types = {'MVSPD', 'Buff', 'Cycle'}, stats = {'4% Added Chance to Gain Movement Speed Boost on Cycle', 'gain_mvspd_boost_on_cycle_chance', 4}, links = {614, 710}, size = 1}
tree[710] = {x = -54, y = 942, types = {'MVSPD', 'Buff', 'Cycle'}, stats = {'4% Added Chance to Gain Movement Speed Boost on Cycle', 'gain_mvspd_boost_on_cycle_chance', 4}, links = {709, 711}, size = 1}
tree[711] = {x = -54, y = 978, types = {'MVSPD', 'Buff', 'Cycle'}, stats = {'4% Added Chance to Gain Movement Speed Boost on Cycle', 'gain_mvspd_boost_on_cycle_chance', 4}, links = {710, 715}, size = 1}
tree[712] = {x = -102, y = 906, types = {'Proj'}, stats = {'8% Increased Projectile Size', 'projectile_size_multiplier', 0.08}, links = {713, 614}, size = 1}
tree[713] = {x = -102, y = 942, types = {'Proj'}, stats = {'8% Increased Projectile Size', 'projectile_size_multiplier', 0.08}, links = {714, 712}, size = 1}
tree[714] = {x = -102, y = 978, types = {'Proj'}, stats = {'8% Increased Projectile Size', 'projectile_size_multiplier', 0.08}, links = {715, 713}, size = 1}
tree[715] = {x = -78, y = 1002, types = {'Proj', 'MVSPD', 'Buff', 'Cycle'}, stats = {'16% Projectile Size', 'projectile_size_multiplier', 0.16, 
'6% Added Chance to Gain Movement Speed Boost on Cycle', 'gain_mvspd_boost_on_cycle_chance', 6}, links = {714, 711}, size = 2}
tree[716] = {x = 18, y = 906, types = {'Attack'}, stats = {'6% Added Chance to Spawn Laser Attack', 'laser_spawn_chance', 10}, links = {702, 717}, size = 1}
tree[717] = {x = 42, y = 930, types = {'Attack'}, stats = {'6% Added Chance to Spawn Laser Attack', 'laser_spawn_chance', 10}, links = {716, 718, 719}, size = 1}
tree[718] = {x = 66, y = 906, types = {'Attack', 'ASPD'}, stats = {'12% Added Chance to Spawn Laser Attack', 'laser_spawn_chance', 20, 'Start With Laser Attack', 'start_with_laser', true, 
'16% Decreased Attack Speed', 'aspd_multiplier', -0.16}, links = {717}, size = 2}
tree[719] = {x = 42, y = 966, types = {'Attack'}, stats = {'15% Increased Laser Width', 'laser_width_multiplier', 0.15, '6% Added Chance to Spawn Laser Attack', 'laser_spawn_chance', 10}, links = {717, 720}, size = 1}
tree[720] = {x = 18, y = 990, types = {'Attack'}, stats = {'15% Increased Laser Width', 'laser_width_multiplier', 0.15, '6% Added Chance to Spawn Laser Attack', 'laser_spawn_chance', 10}, links = {719, 721}, size = 1}
tree[721] = {x = 42, y = 1014, types = {'Attack'}, stats = {'15% Increased Laser Width', 'laser_width_multiplier', 0.15, '6% Added Chance to Spawn Laser Attack', 'laser_spawn_chance', 10}, links = {720, 722}, size = 1}
tree[722] = {x = 66, y = 990, types = {'Attack'}, stats = {'65% Increased Laser Width', 'laser_width_multiplier', 0.65}, links = {721}, size = 2}
tree[723] = {x = 306, y = 918, types = {'Special', 'HP', 'Boost'}, stats = {'Half HP', 'half_hp', true, '+100 Max Boost', 'flat_boost', 100}, links = {612, 728}, size = 3}
tree[724] = {x = 114, y = 918, types = {'Attack'}, stats = {'8% Added Chance for Split Projectiles to Split', 'split_projectiles_split_chance', 8}, links = {727, 701}, size = 1}
tree[725] = {x = 186, y = 918, types = {'Attack'}, stats = {'6% Added Chance to Spawn 2Split Attack', 'twosplit_spawn_chance', 10}, links = {701, 726}, size = 1}
tree[726] = {x = 186, y = 954, types = {'Attack'}, stats = {'6% Added Chance to Spawn 4Split Attack', 'foursplit_spawn_chance', 10}, links = {725, 727}, size = 1}
tree[727] = {x = 150, y = 954, types = {'Attack'}, stats = {'16% Added Chance for Split Projectiles to Split', 'split_projectiles_split_chance', 16, '6% Added Chance to Spawn 2Split Attack', 'twosplit_spawn_chance', 10, '6% Added Chance to Spawn 4Split Attack', 'foursplit_spawn_chance', 10, 'Start With 4Split Attack', 'start_with_4split', true}, links = {726, 724}, size = 2}
tree[728] = {x = 342, y = 954, types = {'Boost'}, stats = {'+30 Max Boost', 'flat_boost', 30}, links = {723, 729}, size = 1}
tree[729] = {x = 318, y = 978, types = {'Boost'}, stats = {'8% Increased Boost', 'boost_multiplier', 0.08}, links = {728, 730}, size = 1}
tree[730] = {x = 294, y = 1002, types = {'Boost'}, stats = {'8% Increased Boost', 'boost_multiplier', 0.08}, links = {729}, size = 1}
tree[731] = {x = 462, y = 738, types = {'Cycle'}, stats = {'10% Increased Cycle Speed', 'cycle_multiplier', 0.10}, links = {502, 732}, size = 1}
tree[732] = {x = 438, y = 762, types = {'Cycle'}, stats = {'10% Increased Cycle Speed', 'cycle_multiplier', 0.10}, links = {731, 733}, size = 1}
tree[733] = {x = 486, y = 810, types = {'Cycle', 'Boost', 'Ammo'}, stats = {'200% Increased Cycle Speed While Boosting', 'increased_cycle_speed_while_boosting', true, '50% Increased Ammo Consumption', 'ammo_consumption_multiplier', 0.50}, links = {732}, size = 3}
tree[734] = {x = 558, y = 642, types = {'SP'}, stats = {'8% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.08}, links = {501, 735, 738}, size = 1}
tree[735] = {x = 558, y = 678, types = {'SP'}, stats = {'2% Added Chance to Spawn SP on Cycle', 'spawn_sp_on_cycle_chance', 2}, links = {734, 736}, size = 1}
tree[736] = {x = 582, y = 702, types = {'SP'}, stats = {'2% Added Chance to Spawn SP on Cycle', 'spawn_sp_on_cycle_chance', 2}, links = {735, 737}, size = 1}
tree[737] = {x = 618, y = 666, types = {'SP', 'Cycle'}, stats = {'10% Increased Chance to Spawn SP', 'sp_spawn_chance_multiplier', 0.10, 
'4% Added Chance to Spawn SP on Cycle', 'spawn_sp_on_cycle_chance', 4, '4% Added Chance to Gain Double SP', 'gain_double_sp_chance', 4}, links = {736, 738}, size = 2}
tree[738] = {x = 594, y = 642, types = {'SP'}, stats = {'4% Added Chance to Gain Double SP', 'gain_double_sp_chance', 4}, links = {737, 734}, size = 1}
tree[739] = {x = 570, y = 462, types = {'PSPD'}, stats = {'8% Increased Projectile Speed', 'pspd_multiplier', 0.08}, links = {500, 741, 740}, size = 1}
tree[740] = {x = 618, y = 462, types = {'PSPD'}, stats = {'8% Increased Projectile Speed', 'pspd_multiplier', 0.08}, links = {743, 739}, size = 1}
tree[741] = {x = 570, y = 510, types = {'ASPD', 'SP'}, stats = {'5% Added Chance to Spawn Haste Area on SP Pickup', 'spawn_haste_area_on_sp_pickup_chance', 5}, links = {739, 742}, size = 1}
tree[742] = {x = 594, y = 534, types = {'ASPD', 'SP'}, stats = {'5% Added Chance to Spawn Haste Area on SP Pickup', 'spawn_haste_area_on_sp_pickup_chance', 5}, links = {741, 744}, size = 1}
tree[743] = {x = 642, y = 486, types = {'PSPD'}, stats = {'8% Increased Projectile Speed', 'pspd_multiplier', 0.08}, links = {744, 740}, size = 1}
tree[744] = {x = 642, y = 534, types = {'PSPD', 'ASPD', 'SP', 'Ammo'}, stats = {'16% Increased Projectile Speed', 'pspd_multiplier', 0.16, '10% Added Chance to Spawn Haste Area on SP Pickup', 'spawn_haste_area_on_sp_pickup_chance', 10, '10% Increased Ammo Consumption', 'ammo_consumption_multiplier', 0.10}, links = {742, 745, 743}, size = 2}
tree[745] = {x = 678, y = 570, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {744, 750, 746}, size = 1}
tree[746] = {x = 702, y = 546, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {747, 745}, size = 1}
tree[747] = {x = 726, y = 570, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {748, 746}, size = 1}
tree[748] = {x = 702, y = 594, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {749, 747}, size = 1}
tree[749] = {x = 678, y = 618, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {750, 748}, size = 1}
tree[750] = {x = 654, y = 594, types = {'HP'}, stats = {'2% Increased HP', 'hp_multiplier', 0.02}, links = {745, 749}, size = 1}
tree[751] = {x = 726, y = 450, types = {'Barrage', 'Cycle', 'Homing'}, stats = {'1% Added Chance to Barrage on Cycle', 'barrage_on_cycle_chance', 1, 
'1% Added Chance to Launch Homing Projectile on Cycle', 'launch_homing_projectile_on_cycle_chance', 1}, links = {499, 756, 752}, size = 1}
tree[752] = {x = 762, y = 450, types = {'Barrage', 'Cycle'}, stats = {'3% Added Chance to Barrage on Cycle', 'barrage_on_cycle_chance', 3}, links = {751, 753}, size = 1}
tree[753] = {x = 798, y = 450, types = {'Barrage', 'Cycle'}, stats = {'3% Added Chance to Barrage on Cycle', 'barrage_on_cycle_chance', 3}, links = {752, 754}, size = 1}
tree[754] = {x = 822, y = 474, types = {'Barrage', 'Cycle'}, stats = {'3% Added Chance to Barrage on Cycle', 'barrage_on_cycle_chance', 3}, links = {753, 755}, size = 1}
tree[755] = {x = 846, y = 498, types = {'Barrage', 'Cycle'}, stats = {'6% Added Chance to Barrage on Cycle', 'barrage_on_cycle_chance', 6, '+2 Barrage Projectiles', 'additional_barrage_projectile', 2}, links = {754}, size = 2}
tree[756] = {x = 726, y = 486, types = {'Homing', 'Cycle'}, stats = {'3% Added Chance to Launch Homing Projectile on Cycle', 'launch_homing_projectile_on_cycle_chance', 3}, links = {751, 757}, size = 1}
tree[757] = {x = 762, y = 486, types = {'Homing', 'Cycle'}, stats = {'3% Added Chance to Launch Homing Projectile on Cycle', 'launch_homing_projectile_on_cycle_chance', 3}, links = {756, 759}, size = 1}
tree[758] = {x = 810, y = 534, types = {'Homing', 'Cycle'}, stats = {'6% Added Chance to Launch Homing Projectile on Cycle', 'launch_homing_projectile_on_cycle_chance', 6, '+1 Homing Projectile', 'additional_homing_projectile', 1}, links = {759}, size = 2}
tree[759] = {x = 786, y = 510, types = {'Homing', 'Cycle'}, stats = {'3% Added Chance to Launch Homing Projectile on Cycle', 'launch_homing_projectile_on_cycle_chance', 3}, links = {757, 758}, size = 1}
tree[760] = {x = 822, y = 366, types = {'PSPD', 'Attack'}, stats = {'30% Decreased Projectile Speed', 'pspd_multiplier', -0.30, '+2 Bounce to Bounce Projectiles', 'additional_bounce', 2}, links = {498}, size = 3}
tree[761] = {x = 858, y = 306, types = {'Attack', 'Cycle'}, stats = {'4% Added Chance to Change Attack on Cycle', 'change_attack_on_cycle_chance', 4}, links = {498, 762}, size = 1}
tree[762] = {x = 882, y = 330, types = {'Attack', 'Cycle'}, stats = {'4% Added Chance to Change Attack on Cycle', 'change_attack_on_cycle_chance', 4}, links = {761, 763}, size = 1}
tree[763] = {x = 882, y = 366, types = {'Attack', 'Cycle'}, stats = {'12% Added Chance to Change Attack on Cycle', 'change_attack_on_cycle_chance', 12}, links = {762}, size = 2}
tree[764] = {x = 942, y = 234, types = {'Invuln', 'Attack'}, stats = {'4% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.04, '4% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.04}, links = {765, 768, 497}, size = 1}
tree[765] = {x = 966, y = 210, types = {'Invuln'}, stats = {'8% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.08}, links = {764, 767}, size = 1}
tree[766] = {x = 1038, y = 210, types = {'Special', 'Invuln'}, stats = {'Deals Damage While Invulnerable', 'deals_damage_while_invulnerable', true}, links = {767}, size = 3}
tree[767] = {x = 1002, y = 174, types = {'Invuln'}, stats = {'8% Increased Invulnerability Time', 'invulnerability_time_multiplier', 0.08}, links = {765, 766}, size = 1}
tree[768] = {x = 966, y = 258, types = {'Attack'}, stats = {'8% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.08}, links = {769, 764}, size = 1}
tree[769] = {x = 1002, y = 294, types = {'Attack'}, stats = {'8% Increased Attack Spawn Rate', 'attack_spawn_rate_multiplier', 0.08}, links = {770, 768}, size = 1}
tree[770] = {x = 1038, y = 258, types = {'Special', 'Attack'}, stats = {'Only Spawn Attack', 'only_spawn_attack', true}, links = {769}, size = 2}
tree[774] = {x = 930, y = -18, types = {'PSPD'}, stats = {'4% Increased Projectile Speed', 'pspd_multiplier', 0.04}, links = {496, 775, 781}, size = 1}
tree[775] = {x = 954, y = -42, types = {'Proj'}, stats = {'6% Increased Projectile Duration', 'projectile_duration_multiplier', 0.06}, links = {774, 776}, size = 1}
tree[776] = {x = 990, y = -78, types = {'Proj'}, stats = {'12% Increased Projectile Duration', 'projectile_duration_multiplier', 0.12}, links = {775, 777}, size = 1}
tree[777] = {x = 1050, y = -78, types = {'Proj'}, stats = {'6% Increased Projectile Duration', 'projectile_duration_multiplier', 0.06}, links = {776, 778}, size = 1}
tree[778] = {x = 1050, y = -18, types = {'Special', 'Proj'}, stats = {'Projectiles Explode on Expiration', 'projectiles_explode_on_expiration', true}, links = {777, 779}, size = 3}
tree[779] = {x = 1050, y = 42, types = {'Proj'}, stats = {'16% Decreased Projectile Duration', 'projectile_duration_multiplier', -0.16}, links = {778, 780}, size = 1}
tree[780] = {x = 990, y = 42, types = {'Proj'}, stats = {'24% Decreased Projectile Duration', 'projectile_duration_multiplier', -0.24}, links = {779, 781}, size = 1}
tree[781] = {x = 954, y = 6, types = {'Proj'}, stats = {'16% Decreased Projectile Duration', 'projectile_duration_multiplier', -0.16}, links = {780, 774}, size = 1}
tree[904] = {x = 930, y = -222, types = {'Special', 'Ammo', 'Attack'}, stats = {'No Ammo Drops', 'no_ammo_drop', true, 'Infinite Ammo', 'infinite_ammo', true, 
'Change Attack Every 10 Seconds', 'change_attack_periodically', true}, links = {495}, size = 3}
tree[782] = {x = 750, y = -378, types = {'Area'}, stats = {'5% Increased Area', 'area_multiplier', 0.05}, links = {494, 784}, size = 1}
tree[783] = {x = 726, y = -402, types = {'PSPD'}, stats = {'8% Increased Projectile Speed', 'pspd_multiplier', 0.08}, links = {493, 786}, size = 1}
tree[520] = {x = 750, y = -426, types = {'PSPD'}, stats = {'32% Decreased Projectile Speed', 'pspd_multiplier', -0.32}, links = {783, 789}, size = 1}
tree[784] = {x = 774, y = -354, types = {'Area'}, stats = {'5% Increased Area', 'area_multiplier', 0.05}, links = {782, 785}, size = 1}
tree[785] = {x = 822, y = -402, types = {'Area'}, stats = {'5% Increased Area', 'area_multiplier', 0.05}, links = {784, 790}, size = 1}
tree[786] = {x = 702, y = -426, types = {'PSPD'}, stats = {'8% Increased Projectile Speed', 'pspd_multiplier', 0.08}, links = {783, 787}, size = 1}
tree[787] = {x = 726, y = -450, types = {'PSPD'}, stats = {'8% Increased Projectile Speed', 'pspd_multiplier', 0.08}, links = {786, 788}, size = 1}
tree[788] = {x = 750, y = -474, types = {'PSPD'}, stats = {'8% Increased Projectile Speed', 'pspd_multiplier', 0.08}, links = {787, 789}, size = 1}
tree[789] = {x = 774, y = -450, types = {'Special', 'Attack'}, stats = {'Fixed Spin Direction', 'fixed_spin_direction', true, '12% Added Chance to Spawn Spin Attack', 'spin_spawn_chance', 20, 
'Start With Spin Attack', 'start_with_spin', true}, links = {788}, size = 2}
tree[790] = {x = 822, y = -450, types = {'Area', 'Attack'}, stats = {'10% Increased Area', 'area_multiplier', 0.10, '+1 Lightning Bolt', 'additional_lightning_bolt', 1, 
'50% Increased Lightning Trigger Distance', 'lightning_trigger_distance_multiplier', 0.50}, links = {785}, size = 2}
tree[791] = {x = 606, y = -570, types = {'Special', 'ES'}, stats = {'[Energy Shield]', 'energy_shield', true, 'Takes Double Damage', 'energy_shield', true, 'Recharging HP', 'energy_shield', true, 
'Half Invulnerability Time', 'energy_shield', true}, links = {463, 792}, size = 3}
tree[792] = {x = 654, y = -522, types = {'ES'}, stats = {'8% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.08}, links = {791, 793, 793}, size = 1}
tree[793] = {x = 678, y = -546, types = {'ES'}, stats = {'8% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.08}, links = {792, 794, 792, 794}, size = 1}
tree[794] = {x = 702, y = -522, types = {'ES'}, stats = {'16% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.16}, links = {793, 793}, size = 1}
tree[795] = {x = 582, y = -690, types = {'Area'}, stats = {'5% Increased Area', 'area_multiplier', 0.05}, links = {796, 797, 449}, size = 1}
tree[796] = {x = 618, y = -690, types = {'Area'}, stats = {'5% Increased Area', 'area_multiplier', 0.05, '+5 Max HP', 'flat_hp', 5}, links = {795, 798}, size = 1}
tree[797] = {x = 582, y = -726, types = {'Area'}, stats = {'5% Increased Area', 'area_multiplier', 0.05}, links = {799, 795}, size = 1}
tree[798] = {x = 642, y = -714, types = {'Area', 'Attack', 'HP'}, stats = {'+1 Lightning Bolt', 'additional_lightning_bolt', 1, '10% Increased Area', 'area_multiplier', 0.10, '+10 Max HP', 'flat_hp', 10}, links = {796, 799}, size = 2}
tree[799] = {x = 606, y = -750, types = {'Area'}, stats = {'5% Increased Area', 'area_multiplier', 0.05}, links = {798, 797}, size = 1}
tree[800] = {x = 330, y = -690, types = {'MVSPD'}, stats = {'4% Increased Movement Speed', 'mvspd_multiplier', 0.04}, links = {801, 437}, size = 1}
tree[801] = {x = 354, y = -714, types = {'MVSPD'}, stats = {'4% Increased Movement Speed', 'mvspd_multiplier', 0.04}, links = {800, 803}, size = 1}
tree[803] = {x = 378, y = -738, types = {'MVSPD'}, stats = {'8% Increased Movement Speed', 'mvspd_multiplier', 0.08, '20% Decreased Size', 'size_multiplier', -0.20}, links = {809, 811, 801}, size = 2}
tree[804] = {x = 282, y = -690, types = {'HP'}, stats = {'4% Increased Chance to Spawn HP', 'hp_spawn_chance_multiplier', 0.04}, links = {437, 805}, size = 1}
tree[805] = {x = 258, y = -714, types = {'HP'}, stats = {'4% Increased Chance to Spawn HP', 'hp_spawn_chance_multiplier', 0.04}, links = {804, 807}, size = 1}
tree[807] = {x = 234, y = -738, types = {'HP'}, stats = {'16% Increased Chance to Spawn HP', 'hp_spawn_chance_multiplier', 0.08, '10% Increased Size', 'size_multiplier', 0.10}, links = {808, 811, 805}, size = 2}
tree[808] = {x = 258, y = -762, types = {'HP'}, stats = {'8% Increased Chance to Spawn HP', 'hp_spawn_chance_multiplier', 0.08}, links = {807}, size = 1}
tree[809] = {x = 354, y = -762, types = {'MVSPD'}, stats = {'8% Increased Movement Speed', 'mvspd_multiplier', 0.08}, links = {803}, size = 1}
tree[811] = {x = 306, y = -738, types = {'Special', 'Boost'}, stats = {'No Boost', 'no_boost', true, '+50 Max HP', 'flat_hp', 50}, links = {807, 803}, size = 3}
tree[812] = {x = 162, y = -690, types = {'Buff'}, stats = {'5% Increased Stat Boost Duration', 'stat_boost_duration_multiplier', 0.05}, links = {436, 813}, size = 1}
tree[813] = {x = 162, y = -726, types = {'Buff'}, stats = {'5% Increased Stat Boost Duration', 'stat_boost_duration_multiplier', 0.05}, links = {812, 816}, size = 1}
tree[814] = {x = 114, y = -690, types = {'Proj'}, stats = {'5% Increased Projectile Duration', 'projectile_duration_multiplier', 0.05}, links = {815, 436}, size = 1}
tree[815] = {x = 114, y = -726, types = {'Proj'}, stats = {'5% Increased Projectile Duration', 'projectile_duration_multiplier', 0.05}, links = {816, 814}, size = 1}
tree[816] = {x = 138, y = -750, types = {'Buff', 'Proj', 'Ammo'}, stats = {'10% Increased Stat Boost Duration', 'stat_boost_duration_multiplier', 0.10, 
'10% Increased Projectile Duration', 'projectile_duration_multiplier', 0.10, '-15 Max Ammo', 'flat_ammo', -15}, links = {813, 815}, size = 2}
tree[817] = {x = -6, y = -702, types = {'Attack'}, stats = {'6% Added Chance to Spawn Triple Attack', 'triple_spawn_chance', 10}, links = {820, 406}, size = 1}
tree[818] = {x = 66, y = -702, types = {'Attack'}, stats = {'6% Added Chance to Spawn Double Attack', 'double_spawn_chance', 10}, links = {406, 819}, size = 1}
tree[819] = {x = 30, y = -738, types = {'Attack'}, stats = {'6% Added Chance to Spawn Double Attack', 'double_spawn_chance', 10, '6% Added Chance to Spawn Triple Attack', 'triple_spawn_chance', 10,
'Start With Double Attack', 'start_with_double', true, 'Start With Triple Attack', 'start_with_triple', true}, links = {818, 820}, size = 2}
tree[820] = {x = -6, y = -738, types = {'Attack'}, stats = {'6% Added Chance to Spawn Triple Attack', 'triple_spawn_chance', 10}, links = {819, 817}, size = 1}
tree[821] = {x = -282, y = -702, types = {'Special', 'HP', 'Ammo'}, stats = {'Half HP', 'half_hp', true, '+50 Max Ammo', 'flat_ammo', 50}, links = {405, 822}, size = 3}
tree[822] = {x = -318, y = -738, types = {'Ammo'}, stats = {'+10 Max Ammo', 'flat_ammo', 10}, links = {821, 823}, size = 1}
tree[823] = {x = -294, y = -762, types = {'Ammo'}, stats = {'8% Increased Ammo', 'ammo_multiplier', 0.08}, links = {822, 824}, size = 1}
tree[824] = {x = -270, y = -786, types = {'Ammo'}, stats = {'8% Increased Ammo', 'ammo_multiplier', 0.08}, links = {823}, size = 1}
tree[825] = {x = -390, y = -558, types = {'ASPD', 'SP'}, stats = {'2% Added Chance to Spawn Haste Area on SP Pickup', 'spawn_haste_area_on_sp_pickup_chance', 2}, links = {827, 404}, size = 1}
tree[826] = {x = -426, y = -522, types = {'Ammo', 'Cycle'}, stats = {'1% Added Chance to Regain Full Ammo on Cycle', 'regain_full_ammo_on_cycle_chance', 1}, links = {404, 828}, size = 1}
tree[827] = {x = -414, y = -582, types = {'ASPD', 'SP'}, stats = {'2% Added Chance to Spawn Haste Area on SP Pickup', 'spawn_haste_area_on_sp_pickup_chance', 2}, links = {828, 825}, size = 1}
tree[828] = {x = -450, y = -546, types = {'ASPD', 'SP', 'Ammo', 'Cycle'}, stats = {'5% Added Chance to Spawn Haste Area on SP Pickup', 'spawn_haste_area_on_sp_pickup_chance', 5, 
'3% Added Chance to Regain Full Ammo on Cycle', 'regain_full_ammo_on_cycle_chance', 3}, links = {826, 827}, size = 2}
tree[830] = {x = -522, y = -438, types = {'Proj'}, stats = {'2% Added Chance to Shoot Shield Projectiles', 'shield_projectile_chance', 2}, links = {365, 831}, size = 1}
tree[831] = {x = -546, y = -462, types = {'Proj'}, stats = {'2% Added Chance to Shoot Shield Projectiles', 'shield_projectile_chance', 2}, links = {830, 833, 832}, size = 1}
tree[832] = {x = -570, y = -486, types = {'Proj'}, stats = {'4% Increased Projectile Size', 'projectile_size_multiplier', 0.04}, links = {835, 831}, size = 1}
tree[833] = {x = -570, y = -438, types = {'Proj'}, stats = {'5% Increased Projectile Duration', 'projectile_duration_multiplier', 0.05}, links = {831, 834}, size = 1}
tree[834] = {x = -606, y = -438, types = {'Proj'}, stats = {'5% Increased Projectile Duration', 'projectile_duration_multiplier', 0.05}, links = {833, 836}, size = 1}
tree[835] = {x = -606, y = -486, types = {'Proj'}, stats = {'4% Increased Projectile Size', 'projectile_size_multiplier', 0.04}, links = {836, 832}, size = 1}
tree[836] = {x = -630, y = -462, types = {'Proj'}, stats = {'10% Increased Projectile Duration', 'projectile_duration_multiplier', 0.10, '10% Increased Projectile Size', 'projectile_size_multiplier', 0.10, 
'4% Added Chance to Shoot Shield Projectiles', 'shield_projectile_chance', 4}, links = {834, 835}, size = 2}
tree[837] = {x = -630, y = -330, types = {'Attack'}, stats = {'4% Added Chance to Attack From Sides', 'attack_from_sides_chance', 4, 
'4% Added Chance to Attack From Back', 'attack_from_back_chance', 4}, links = {368, 838}, size = 1}
tree[838] = {x = -654, y = -354, types = {'Attack'}, stats = {'4% Added Chance to Attack From Sides', 'attack_from_sides_chance', 4, 
'4% Added Chance to Attack From Back', 'attack_from_back_chance', 4}, links = {837, 839, 840}, size = 1}
tree[839] = {x = -654, y = -390, types = {'Attack'}, stats = {'8% Added Chance to Attack From Back', 'attack_from_back_chance', 8}, links = {838, 841}, size = 1}
tree[840] = {x = -690, y = -354, types = {'Attack'}, stats = {'8% Added Chance to Attack From Sides', 'attack_from_sides_chance', 8}, links = {841, 838}, size = 1}
tree[841] = {x = -690, y = -390, types = {'Attack'}, stats = {'12% Added Chance to Attack From Sides', 'attack_from_sides_chance', 4, 
'12% Added Chance to Attack From Back', 'attack_from_back_chance', 4}, links = {839, 840}, size = 2}
tree[842] = {x = -762, y = -222, types = {'Special', 'Boost'}, stats = {'No Boost', 'no_boost', true, '+50 Max Ammo', 'flat_ammo', 50}, links = {366}, size = 3}
tree[843] = {x = -762, y = -18, types = {'HP'}, stats = {'4% Added Chance to Spawn Double HP', 'spawn_double_hp_chance', 4}, links = {367, 845}, size = 1}
tree[844] = {x = -762, y = 54, types = {'SP'}, stats = {'4% Added Chance to Spawn Double SP', 'spawn_double_sp_chance', 4}, links = {367, 845}, size = 1}
tree[845] = {x = -798, y = 18, types = {'HP', 'SP'}, stats = {'4% Added Chance to Spawn Double HP', 'spawn_double_hp_chance', 4, '4% Added Chance to Spawn Double SP', 'spawn_double_sp_chance', 4}, links = {844, 846, 843}, size = 1}
tree[846] = {x = -858, y = 18, types = {'HP', 'SP', 'Luck', 'Ammo'}, stats = {'8% Added Chance to Spawn Double HP', 'spawn_double_hp_chance', 8, '8% Added Chance to Spawn Double SP', 'spawn_double_sp_chance', 8, '14% Increased Luck', 'luck_multiplier', 0.14, '-15 Max Ammo', 'flat_ammo', -15, '-15 Max HP', 'flat_hp', -15}, links = {845}, size = 3}
tree[847] = {x = -762, y = 246, types = {'Ammo'}, stats = {'2% Decreased Ammo Consumption', 'ammo_consumption_multiplier', -0.02}, links = {510, 848}, size = 1}
tree[848] = {x = -798, y = 246, types = {'Ammo'}, stats = {'2% Decreased Ammo Consumption', 'ammo_consumption_multiplier', -0.02}, links = {847, 849}, size = 1}
tree[849] = {x = -834, y = 246, types = {'Ammo'}, stats = {'2% Decreased Ammo Consumption', 'ammo_consumption_multiplier', -0.02}, links = {848, 850}, size = 1}
tree[850] = {x = -834, y = 210, types = {'Ammo'}, stats = {'2% Decreased Ammo Consumption', 'ammo_consumption_multiplier', -0.02}, links = {849, 851}, size = 1}
tree[851] = {x = -798, y = 210, types = {'Ammo'}, stats = {'4% Decreased Ammo Consumption', 'ammo_consumption_multiplier', -0.02}, links = {850, 852}, size = 1}
tree[852] = {x = -762, y = 210, types = {'Ammo'}, stats = {'4% Decreased Ammo Consumption', 'ammo_consumption_multiplier', -0.04}, links = {851, 853}, size = 1}
tree[853] = {x = -762, y = 162, types = {'Ammo'}, stats = {'8% Decreased Ammo Consumption', 'ammo_consumption_multiplier', -0.08, '+15 Max Ammo', 'flat_ammo', 15}, links = {852}, size = 2}
tree[855] = {x = -678, y = 366, types = {'Ammo'}, stats = {'4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {857, 863, 856, 511}, size = 1}
tree[856] = {x = -726, y = 366, types = {'Ammo', 'Cycle'}, stats = {'1% Added Chance to Regain Full Ammo on Cycle', 'regain_full_ammo_on_cycle_chance', 1}, links = {855, 860}, size = 1}
tree[857] = {x = -678, y = 414, types = {'ASPD'}, stats = {'5% Increased Attack Speed', 'aspd_multiplier', 0.05}, links = {855, 858}, size = 1}
tree[858] = {x = -702, y = 438, types = {'ASPD'}, stats = {'5% Increased Attack Speed', 'aspd_multiplier', 0.05}, links = {857, 859}, size = 1}
tree[859] = {x = -726, y = 462, types = {'ASPD'}, stats = {'5% Increased Attack Speed', 'aspd_multiplier', 0.05}, links = {858, 862}, size = 1}
tree[860] = {x = -750, y = 390, types = {'Ammo', 'Cycle'}, stats = {'1% Added Chance to Regain Full Ammo on Cycle', 'regain_full_ammo_on_cycle_chance', 1}, links = {856, 861}, size = 1}
tree[861] = {x = -774, y = 414, types = {'Ammo', 'Cycle'}, stats = {'1% Added Chance to Regain Full Ammo on Cycle', 'regain_full_ammo_on_cycle_chance', 1}, links = {860, 862}, size = 1}
tree[862] = {x = -774, y = 462, types = {'ASPD', 'Ammo'}, stats = {'10% Increased Attack Speed', 'aspd_multiplier', 0.10, '+20 Max Ammo', 'flat_ammo', 20}, links = {859, 865, 861}, size = 2}
tree[863] = {x = -702, y = 390, types = {'HP'}, stats = {'+5 Max HP', 'flat_hp', 5}, links = {855, 864}, size = 1}
tree[864] = {x = -726, y = 414, types = {'HP'}, stats = {'+10 Max HP', 'flat_hp', 10}, links = {863, 865}, size = 1}
tree[865] = {x = -750, y = 438, types = {'HP'}, stats = {'+5 Max HP', 'flat_hp', 5}, links = {864, 862}, size = 1}
tree[866] = {x = -690, y = 534, types = {'ES'}, stats = {'30% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.30, 
'30% Increased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', -0.30}, links = {512, 867}, size = 3}
tree[867] = {x = -738, y = 534, types = {'ES'}, stats = {'5% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.05}, links = {866, 868}, size = 1}
tree[868] = {x = -762, y = 558, types = {'ES'}, stats = {'5% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.05}, links = {867, 869}, size = 1}
tree[869] = {x = -762, y = 594, types = {'ES'}, stats = {'5% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.05}, links = {868, 874}, size = 1}
tree[870] = {x = -690, y = 642, types = {'ES'}, stats = {'30% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.30, 
'30% Decreased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', -0.30}, links = {513, 871}, size = 3}
tree[871] = {x = -726, y = 678, types = {'ES'}, stats = {'5% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.05}, links = {870, 872}, size = 1}
tree[872] = {x = -762, y = 678, types = {'ES'}, stats = {'5% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.05}, links = {873, 871}, size = 1}
tree[873] = {x = -786, y = 654, types = {'ES'}, stats = {'5% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.05}, links = {874, 872}, size = 1}
tree[874] = {x = -786, y = 618, types = {'ES'}, stats = {'5% Increased Energy Shield Recharge Amount', 'energy_shield_recharge_amount_multiplier', 0.05, 
'5% Decreased Energy Shield Recharge Cooldown', 'energy_shield_recharge_cooldown_multiplier', 0.05}, links = {869, 873}, size = 1}
tree[875] = {x = -570, y = 750, types = {'Proj'}, stats = {'5% Increased Angle Change Frequency', 'projectile_angle_change_frequency_multiplier', 0.05, 
'5% Increased Projectile Waviness', 'projectile_waviness_multiplier', 0.05}, links = {509, 876, 877}, size = 1}
tree[876] = {x = -594, y = 774, types = {'Proj'}, stats = {'5% Increased Angle Change Frequency', 'projectile_angle_change_frequency_multiplier', 0.05}, links = {875, 878}, size = 1}
tree[877] = {x = -546, y = 774, types = {'Proj'}, stats = {'5% Added Projectile Waviness', 'projectile_waviness_multiplier', 0.05}, links = {878, 875}, size = 1}
tree[878] = {x = -570, y = 798, types = {'Proj'}, stats = {'20% Increased Angle Change Frequency', 'projectile_angle_change_frequency_multiplier', 0.20, 
'20% Increased Projectile Waviness', 'projectile_waviness_multiplier', 0.20}, links = {876, 877, 879}, size = 2}
tree[879] = {x = -570, y = 834, types = {'Proj'}, stats = {'5% Increased Angle Change Frequency', 'projectile_angle_change_frequency_multiplier', 0.05, 
'5% Increased Projectile Waviness', 'projectile_waviness_multiplier', 0.05}, links = {878, 880, 884}, size = 1}
tree[880] = {x = -606, y = 834, types = {'Proj'}, stats = {'5% Increased Angle Change Frequency', 'projectile_angle_change_frequency_multiplier', 0.05}, links = {879, 881}, size = 1}
tree[881] = {x = -606, y = 870, types = {'Proj'}, stats = {'5% Increased Angle Change Frequency', 'projectile_angle_change_frequency_multiplier', 0.05}, links = {880, 882}, size = 1}
tree[882] = {x = -570, y = 870, types = {'Proj'}, stats = {'5% Increased Angle Change Frequency', 'projectile_angle_change_frequency_multiplier', 0.05, 
'5% Increased Projectile Waviness', 'projectile_waviness_multiplier', 0.05}, links = {881, 883}, size = 1}
tree[883] = {x = -534, y = 870, types = {'Proj'}, stats = {'5% Added Projectile Waviness', 'projectile_waviness_multiplier', 0.05}, links = {882, 884}, size = 1}
tree[884] = {x = -534, y = 834, types = {'Proj'}, stats = {'5% Added Projectile Waviness', 'projectile_waviness_multiplier', 0.05}, links = {883, 879}, size = 1}
tree[885] = {x = -390, y = 750, types = {'MVSPD'}, stats = {'4% Increased Movement Speed', 'mvspd_multiplier', 0.04}, links = {508, 886, 887}, size = 1}
tree[886] = {x = -414, y = 774, types = {'Boost'}, stats = {'8% Increased Boost Effectiveness', 'boost_effectiveness_multiplier', 0.08}, links = {885, 890}, size = 1}
tree[887] = {x = -366, y = 774, types = {'Boost'}, stats = {'8% Increased Boost Recharge Rate', 'boost_recharge_rate_multiplier', 0.08}, links = {888, 885}, size = 1}
tree[888] = {x = -366, y = 810, types = {'Boost'}, stats = {'8% Increased Boost Recharge Rate', 'boost_recharge_rate_multiplier', 0.08}, links = {889, 887}, size = 1}
tree[889] = {x = -366, y = 846, types = {'Boost'}, stats = {'24% Increased Boost Recharge Rate', 'boost_recharge_rate_multiplier', 0.24}, links = {892, 888}, size = 2}
tree[890] = {x = -414, y = 810, types = {'Boost'}, stats = {'8% Increased Boost Effectiveness', 'boost_effectiveness_multiplier', 0.08}, links = {886, 891}, size = 1}
tree[891] = {x = -414, y = 846, types = {'Boost'}, stats = {'24% Increased Boost Effectiveness', 'boost_effectiveness_multiplier', 0.24}, links = {890, 892}, size = 2}
tree[892] = {x = -390, y = 870, types = {'Boost'}, stats = {'8% Increased Boost Effectiveness', 'boost_effectiveness_multiplier', 0.08, '8% Increased Boost Recharge Rate', 'boost_recharge_rate_multiplier', 0.08}, links = {891, 889}, size = 1}
