function sound()
    sources = {}
    playing_sources = {}
    tags = {
        sfx = {volume = 1}, 
        master = {volume = 1}, keyboard = {volume = 0.5}, 
        computer = {volume = 1}, 
        music = {base_volume = 1, volume = 1, multiplier = 0}, 
        game = {base_volume = 1, volume = 1, multiplier = 0}
    }

    for i = 1, 28 do register('keystroke_' .. i, 'static', {'master', 'sfx', 'keyboard'}) end
    register('computer_line', 'static', {'master', 'sfx', 'computer'})
    register('menu_back', 'static', {'master', 'sfx'})
    register('menu_switch', 'static', {'master', 'sfx'})
    register('menu_select', 'static', {'master', 'sfx'})
    register('menu_error', 'static', {'master', 'sfx'})
    register('menu_click', 'static', {'master', 'sfx'})
    register('game_shoot_1', 'static', {'master', 'sfx', 'game'})
    register('game_shoot_2', 'static', {'master', 'sfx', 'game'})
    register('game_explosion', 'static', {'master', 'sfx', 'game'})
    register('game_ammo', 'static', {'master', 'sfx', 'game'})
    register('game_item', 'static', {'master', 'sfx', 'game'})
    register('game_key', 'static', {'master', 'sfx', 'game'})
    register('game_laser', 'static', {'master', 'sfx', 'game'})
    register('game_enemy_die', 'static', {'master', 'sfx', 'game'})
    register('game_lightning_1', 'static', {'master', 'sfx', 'game'})
    register('game_lightning_2', 'static', {'master', 'sfx', 'game'})
    register('game_lightning_3', 'static', {'master', 'sfx', 'game'})
    register('game_lightning_4', 'static', {'master', 'sfx', 'game'})
    register('game_lightning_5', 'static', {'master', 'sfx', 'game'})
    register('game_hurt_1', 'static', {'master', 'sfx', 'game'})
    register('game_hurt_2', 'static', {'master', 'sfx', 'game'})
    register('game_hurt_3', 'static', {'master', 'sfx', 'game'})
    register('game_flame', 'static', {'master', 'sfx', 'game'})
    register('game_engine', 'static', {'master', 'sfx', 'game'})

    songs = {
        'AIRGLOW - AIRGLOW - Memory Bank - 01 Memory Bank',
        'AIRGLOW - AIRGLOW - Memory Bank - 02 Cepheid Disk',
        'AIRGLOW - AIRGLOW - Memory Bank - 03 Electrifying Landscape',
        'AIRGLOW - AIRGLOW - Memory Bank - 04 Blueshift',
        'AIRGLOW - AIRGLOW - Memory Bank - 05 Far Apart',
        'AIRGLOW - AIRGLOW - Memory Bank - 06 Lisa',
        'AIRGLOW - AIRGLOW - Memory Bank - 07 New Touch',
        'AIRGLOW - AIRGLOW - Memory Bank - 08 Spliff & Wesson',
        'AIRGLOW - AIRGLOW - Memory Bank - 09 Innermission',
        'AIRGLOW - AIRGLOW - Memory Bank - 10 System Shutdown',
    }
    for _, song in ipairs(songs) do register(song, 'stream', {'master', 'music'}) end
end

function soundUpdate(dt)
    for k, v in pairs(sources) do v.played_this_frame = false end

    local remove = {}
    for i = #playing_sources, 1, -1 do
        if playing_sources[i].source:isStopped() then
            if fn.any(playing_sources[i].tags, 'music') then playRandomSong() end
            table.remove(playing_sources, i)
        end
    end

    tags.music.volume = tags.music.base_volume*tags.music.multiplier*(music_volume/10)*(main_volume/10)
    tags.game.volume = tags.game.base_volume*tags.game.multiplier*(sfx_volume/10)*(main_volume/10)

    for _, source in ipairs(playing_sources) do
        if muted then 
            if fn.any(source.tags, 'music') then
                source.source:stop() 
            end
        end
        source.source:setPitch(slow_amount)
        if fn.any(source.tags, 'music') or fn.any(source.tags, 'game') then
            local volume = source.volume or 1
            for _, tag in ipairs(source.tags) do volume = volume*(tags[tag].volume) end
            source.source:setVolume(volume)
        end
    end
end

function register(name, source_type, tags)
    if not sources[name] then sources[name] = {source = love.audio.newSource('resources/sounds/' .. name .. '.ogg', source_type), type = source_type, tags = tags} end
end

function isAnySongPlaying()
    for _, source in ipairs(playing_sources) do
        if fn.any(source.tags, 'music') then
            return true
        end
    end
end

function play(name, opts)
    if muted then return end
    if not sources[name] then error("unregistered source " .. name) end
    if sources[name].played_this_frame then return end
    local source = sources[name]
    local opts = opts or {}
    source.played_this_frame = true

    if source.type == 'static' then
        local cloned_source = source.source:clone()
        local volume = opts.volume or 1
        for _, tag in ipairs(source.tags) do volume = volume*(tags[tag].volume or 1) end
        cloned_source:setVolume(volume)
        cloned_source:setPitch(opts.pitch or 1)
        cloned_source:setLooping(opts.loop)
        cloned_source:play()
        table.insert(playing_sources, {volume = volume, tags = source.tags, source = cloned_source})
        return cloned_source

    else
        local source = love.audio.newSource('resources/sounds/' .. name .. '.ogg', 'stream')
        local volume = opts.volume or 1
        for _, tag in ipairs(sources[name].tags) do volume = volume*(tags[tag].volume or 1) end
        source:setVolume(volume)
        source:setPitch(opts.pitch or 1)
        source:setLooping(opts.loop)
        source:play()
        table.insert(playing_sources, {tags = sources[name].tags, source = source})
        return source
    end
end

function fadeIn(name, opts)
    local source = play(name, {loop = opts.loop, volume = 0})
    if not opts.duration then error("fadeIn() needs a 'duration' argument in the options table") end
    local time = 0
    timer:during('computer_background', opts.duration, function(dt)
        time = time + dt
        source:setVolume(opts.volume*(time/opts.duration))
    end)
    return source
end

function fadeOut(source, duration)
    local volume = source:getVolume()
    local time = 0
    timer:during('computer_background', duration, function(dt)
        time = time + dt
        source:setVolume(volume*(1-(time/duration)))
    end)
end

function fadeVolume(tag_name, duration, target_volume)
    timer:cancel(tag_name)
    timer:tween(tag_name, duration, tags[tag_name], {multiplier = target_volume}, 'linear')
end

function playRandomSong()
    if currently_playing_song then currently_playing_song:stop() end
    for i, source in ipairs(playing_sources) do
        if source.source:isStopped() then
            table.remove(playing_sources, i)
        end
    end
    currently_playing_song = play(table.random(songs))
end

function playKeystroke()
    play('keystroke_' .. love.math.random(1, 28), {volume = random(0.6, 0.8), pitch = random(0.9, 1.1)})
end

function playMenuClick()
    play('menu_click', {volume = 0.4})
end

function playComputerStartup()
    play('computer_startup', {volume = 0.5})
    timer:after(10.5, function()
        play('computer_background', {loop = true, volume = 0.5})
    end)
end

function fadeInComputerBackground()
    computer_background_source = fadeIn('computer_background', {loop = true, volume = 0.5, duration = 4})
end

function fadeOutComputerBackground()
    if not computer_background_source then return end
    fadeOut(computer_background_source, 4)
    computer_background_source = nil
end

function playMenuSwitch()
    play('menu_switch', {volume = 0.4})
end

function playMenuSelect()
    play('menu_select', {volume = 0.4})
end

function playMenuBack()
    play('menu_back', {volume = 0.4})
end

function playMenuError()
    play('menu_error', {volume = 0.35})
end

function playComputerLine()
    play('computer_line', {volume = random(0.7, 0.9), pitch = random(0.9, 1.1)})
end

function playGameShoot1()
    play('game_shoot_1', {volume = 0.6, pitch = random(0.9, 1.1)})
end

function playGameShoot2()
    play('game_shoot_2', {volume = 0.6, pitch = random(0.9, 1.1)})
end

function playGameExplosion()
    play('game_explosion', {volume = 0.3, pitch = random(0.9, 1.1)})
end

function playGameItem()
    play('game_item', {volume = 1, pitch = random(0.9, 1.1)})
end

function playGameEnemyDie()
    play('game_enemy_die', {volume = 0.6, pitch = random(1.1, 1.3)})
end

function playGameKey()
    play('game_key', {volume = 1})
end

function playGameLaser()
    play('game_laser', {volume = 0.6})
end

function playGameLightning()
    play('game_lightning_' .. love.math.random(1, 5), {volume = 0.6})
end

function playGameHurt()
    play('game_hurt_' .. love.math.random(1, 3), {volume = 1, pitch = random(0.9, 1.1)})
end

function playGameFlame()
    play('game_flame', {volume = 1})
end
