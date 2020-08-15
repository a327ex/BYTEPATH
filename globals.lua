-- Colors
default_color = {222, 222, 222}
background_color = {16, 16, 16}
ammo_color = {123, 200, 164}
boost_color = {76, 195, 217}
hp_color = {241, 103, 69}
skill_point_color = {255, 198, 93}

default_colors = {default_color, hp_color, ammo_color, boost_color, skill_point_color}
negative_colors = {
    {255-default_color[1], 255-default_color[2], 255-default_color[3]}, 
    {255-hp_color[1], 255-hp_color[2], 255-hp_color[3]}, 
    {255-ammo_color[1], 255-ammo_color[2], 255-ammo_color[3]}, 
    {255-boost_color[1], 255-boost_color[2], 255-boost_color[3]}, 
    {255-skill_point_color[1], 255-skill_point_color[2], 255-skill_point_color[3]}
}
all_colors = fn.append(default_colors, negative_colors)

-- Skill tree colors
white = {222, 222, 222}
dark = {96, 96, 96}
gray = {160, 160, 160}
red = {222, 32, 32}
green = {32, 222, 32}
blue = {32, 32, 222}
pink = {222, 32, 222}
brown = {192, 96, 32}
yellow = {222, 222, 32}
orange = {222, 128, 32}
bluegreen = {32, 222, 222}
purple = {128, 32, 128}


-- Attacks
attacks = {
    ['Neutral'] = {cooldown = 0.24, ammo = 0, abbreviation = 'N', color = default_color},
    ['Double'] = {cooldown = 0.32, ammo = 2, abbreviation = '2', color = ammo_color},
    ['Triple'] = {cooldown = 0.32, ammo = 3, abbreviation = '3', color = boost_color},
    ['Rapid'] = {cooldown = 0.12, ammo = 1, abbreviation = 'R', color = default_color},
    ['Spread'] = {cooldown = 0.16, ammo = 1, abbreviation = 'RS', color = default_color},
    ['Back'] = {cooldown = 0.32, ammo = 2, abbreviation = 'Ba', color = skill_point_color},
    ['Side'] = {cooldown = 0.32, ammo = 2, abbreviation = 'Si', color = boost_color},
    ['Homing'] = {cooldown = 0.40, ammo = 3, abbreviation = 'H', color = skill_point_color},
    ['Blast'] = {cooldown = 0.64, ammo = 6, abbreviation = 'W', color = default_color},
    ['Spin'] = {cooldown = 0.24, ammo = 2, abbreviation = 'Sp', color = hp_color},
    ['Bounce'] = {cooldown = 0.32, ammo = 3, abbreviation = 'Bn', color = default_color},
    ['Lightning'] = {cooldown = 0.2, ammo = 4, abbreviation = 'Li', color = boost_color},
    ['Flame'] = {cooldown = 0.048, ammo = 0.4, abbreviation = 'F', color = skill_point_color},
    ['2Split'] = {cooldown = 0.32, ammo = 3, abbreviation = '2S', color = ammo_color},
    ['4Split'] = {cooldown = 0.4, ammo = 4, abbreviation = '4S', color = boost_color},
    ['Explode'] = {cooldown = 0.6, ammo = 4, abbreviation = 'E', color = hp_color},
    ['Laser'] = {cooldown = 0.8, ammo = 6, abbreviation = 'L', color = hp_color},
}
attack_names = {'Double', 'Triple', 'Rapid', 'Spread', 'Back', 'Side', 'Homing', 'Blast', 'Spin', 'Bounce', 'Lightning', 'Flame', '2Split', '4Split', 'Explode', 'Laser'}

-- Globals
function setPermanentGlobals(opts)
    local opts = opts or {}
    id = UUID()
    loop = opts.loop or 0
    main_volume = 5
    sfx_volume = 5
    music_volume = 5
    muted = false
    fullscreen = true
    display = 1
    sx, sy = 2, 2
    screen_shake = 10
    distortion = 5
    glitch = 10
    achievements = {}
    high_score = 0
end

function setTransientGlobals()
    if loop > 0 then skill_points = 20 + (loop-1)*10
    else skill_points = 0 end
    bought_node_indexes = {1}
    run = 1
    device = 'Fighter'
    unlocked_devices = {'Fighter'}
    classes = {}
    rank = 1
    score = 0
    found_keys = {0, 0, 0, 0, 0, 0, 0, 0}
    if loop > 0 then max_tree_nodes = math.min(max_tree_nodes + 5*loop, 100)
    else max_tree_nodes = 80 end
    spent_sp = 0
    keys = {}; for i = 1, 8 do keys[i] = {address = KEY(), value = KEY()} end 
    command_history = {}
end

-- Before running the UUID() function we need to set a random seed
-- love.run also sets the random seed but we require this file before love.run is run once
if love.math then love.math.setRandomSeed(os.time()) end 
setPermanentGlobals()
setTransientGlobals()

-- Enemies
-- enemies = {'Rock', 'BigRock', 'Shooter', 'Seeker', 'Waver', 'Roller', 'Trailer', 'Reflecteer', 'Orbitter', 'Tanker', 'RotatorPart', 'Triad', 'Sapper', 'Glitcher'}
enemies = {'Rock', 'BigRock', 'Shooter', 'Seeker', 'Waver', 'Roller', 'Trailer', 'Reflecteer', 'Orbitter', 'Tanker', 'Triad', 'Sapper', 'Glitcher'}

-- Classes
class_colors = { 
    ['Gunner'] = ammo_color, ['Tanker'] = hp_color, ['Runner'] = boost_color, ['Cycler'] = default_color,
    ['Buster'] = ammo_color, ['Buffer'] = ammo_color, ['Berserker'] = ammo_color, ['Shielder'] = hp_color,
    ['Regeneer'] = hp_color, ['Recycler'] = hp_color, ['Absorber'] = boost_color, ['Turner'] = boost_color,
    ['Driver'] = boost_color, ['Swapper'] = default_color, ['Barrager'] = default_color, ['Seeker'] = default_color,
    ['Repeater'] = ammo_color, ['Launcher'] = ammo_color, ['Panzer'] = hp_color, ['Reserver'] = hp_color, 
    ['Deployer'] = boost_color, ['Booster'] = boost_color, ['Processor'] = default_color, ['Gambler'] = default_color,
    ['Discharger'] = boost_color, ['Hoamer'] = skill_point_color, ['Splitter'] = boost_color, ['Bouncer'] = default_color,
    ['Blaster'] = default_color, ['Raider'] = skill_point_color, ['Waver'] = ammo_color, ['Bomber'] = hp_color, ['Zoomer'] = boost_color,
    ['Racer'] = boost_color, ['Miner'] = ammo_color, ['Piercer'] = ammo_color, ['Dasher'] = boost_color, ['Engineer'] = hp_color, ['Threader'] = default_color
}

-- Achievements
function unlockAchievement(achievement_name)
    if achievements[achievement_name] then return end
    achievements[achievement_name] = true
    if Steam then
        local steam_achievement_name = achievement_name:upper():gsub(' ', '_')
        print(Steam.userstats.SetAchievement(steam_achievement_name))
        print(achievement_name .. ' unlocked!')
        timer:after(0.5, function() Steam.userstats.StoreStats() end)
    end
end

achievement_names = {
    'Reroll Skills', 'Reroll Classes', 'Reroll Build', 'Escape',
    '10K Fighter', '10K Crusader', '10K Rogue', '10K Bit Hunter', '50K Sentinel', '50K Striker', '50K Nuclear', '50K Cycler', '50K Wisp',
    '100K Fighter', '100K Crusader', '100K Rogue', '100K Bit Hunter', '100K Sentinel', '100K Striker', '100K Nuclear', '100K Cycler', '100K Wisp',
    '500K Fighter', '500K Crusader', '500K Rogue', '500K Bit Hunter', '500K Sentinel', '500K Striker', '500K Nuclear', '500K Cycler', '500K Wisp',
    '1KK Fighter', '1KK Crusader', '1KK Rogue', '1KK Bit Hunter', '1KK Sentinel', '1KK Striker', '1KK Nuclear', '1KK Cycler', '1KK Wisp',
}

achievement_descriptions = {
    ['Reroll Build'] = 'Reroll all 80 points spent in the passive skill tree and all 9 classes bought',
    ['Reroll Skills'] = 'Reroll all 80 points spent in the passive skill tree',
    ['Reroll Classes'] = 'Reroll all 9 classes bought',
    ['Escape'] = 'Beat the game and escape the terminal',

    ['10K Fighter'] = 'Reach 10K score with the Fighter device',
    ['10K Crusader'] = 'Reach 10K score with the Crusader device',
    ['10K Rogue'] = 'Reach 10K score with the Rogue device',
    ['10K Bit Hunter'] = 'Reach 10K score with the Bit Hunter device',
    ['50K Sentinel'] = 'Reach 50K score with the Sentinel device',
    ['50K Striker'] = 'Reach 50K score with the Striker device',
    ['50K Nuclear'] = 'Reach 50K score with the Nuclear device',
    ['50K Cycler'] = 'Reach 50K score with the Cycler device',
    ['50K Wisp'] = 'Reach 50K score with the Wisp device',

    ['100K Fighter'] = 'Reach 100K score with the Fighter device',
    ['100K Crusader'] = 'Reach 100K score with the Crusader device',
    ['100K Rogue'] = 'Reach 100K score with the Rogue device',
    ['100K Bit Hunter'] = 'Reach 100K score with the Bit Hunter device',
    ['100K Sentinel'] = 'Reach 100K score with the Sentinel device',
    ['100K Striker'] = 'Reach 100K score with the Striker device',
    ['100K Nuclear'] = 'Reach 100K score with the Nuclear device',
    ['100K Cycler'] = 'Reach 100K score with the Cycler device',
    ['100K Wisp'] = 'Reach 100K score with the Wisp device',

    ['500K Fighter'] = 'Reach 500K score with the Fighter device',
    ['500K Crusader'] = 'Reach 500K score with the Crusader device',
    ['500K Rogue'] = 'Reach 500K score with the Rogue device',
    ['500K Bit Hunter'] = 'Reach 500K score with the Bit Hunter device',
    ['500K Sentinel'] = 'Reach 500K score with the Sentinel device',
    ['500K Striker'] = 'Reach 500K score with the Striker device',
    ['500K Nuclear'] = 'Reach 500K score with the Nuclear device',
    ['500K Cycler'] = 'Reach 500K score with the Cycler device',
    ['500K Wisp'] = 'Reach 500K score with the Wisp device',

    ['1KK Fighter'] = 'Reach 1KK score with the Fighter device',
    ['1KK Crusader'] = 'Reach 1KK score with the Crusader device',
    ['1KK Rogue'] = 'Reach 1KK score with the Rogue device',
    ['1KK Bit Hunter'] = 'Reach 1KK score with the Bit Hunter device',
    ['1KK Sentinel'] = 'Reach 1KK score with the Sentinel device',
    ['1KK Striker'] = 'Reach 1KK score with the Striker device',
    ['1KK Nuclear'] = 'Reach 1KK score with the Nuclear device',
    ['1KK Cycler'] = 'Reach 1KK score with the Cycler device',
    ['1KK Wisp'] = 'Reach 1KK score with the Wisp device',
}

devices = {'Fighter', 'Crusader', 'Rogue', 'Bit Hunter', 'Sentinel', 'Striker', 'Nuclear', 'Cycler', 'Wisp'}
