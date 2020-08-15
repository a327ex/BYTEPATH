CreditsModule = Object:extend()

function CreditsModule:new(console, y)
    self.console = console
    self.y = y
    
    self.console:addLine(0.02, '')
    self.console:addLine(0.04, '    game by $SSYGEN%')
    self.console:addLine(0.06, '    music by $AIRGLOW%')
    self.console:addLine(0.08, '    sound effects from $freesound.org% by')
    self.console:addLine(0.10, '        $fins jeckkech josepharaoh99 KorGround NSStudios TreasureSounds TheDweebMan%')
    self.console:addLine(0.12, '        $LittleRobotSoundFactory GameAudio NenadSimic DrMinky pyzaist CGEffex broumbroum%')
    self.console:addLine(0.14, '    fonts by')
    self.console:addLine(0.16, '        $Daniel Linssen Troy Mark Simonson%')
    self.console:addLine(0.18, '    made with $love2d.org% with help from')
    self.console:addLine(0.20, '        $slime bartbes CapsAdmin rxi RolandYonaba vrld pelevesque davisdude gvx bakpakin%')
    self.console:addLine(0.22, '')

    self.y = y
    self.h = 6*self.console.font:getHeight()

    self.vertical_selection_index = 1
    self.horizontal_selection_index = 1
    self:setSelections()

    self.console.timer:after(0.20, function() self.active = true end)
end

function CreditsModule:update(dt)
    if not self.active then return end

    if input:pressed('up') then
        self.vertical_selection_index = self.vertical_selection_index - 1
        if self.vertical_selection_index < 1 then self.vertical_selection_index = #self.selections end
        self.horizontal_selection_index = math.min(math.max(1, #self.selections[self.vertical_selection_index]), self.horizontal_selection_index)
    end

    if input:pressed('down') then
        self.vertical_selection_index = self.vertical_selection_index + 1
        if self.vertical_selection_index > #self.selections then self.vertical_selection_index = 1 end
        self.horizontal_selection_index = math.min(math.max(1, #self.selections[self.vertical_selection_index]), self.horizontal_selection_index)
    end

    if input:pressed('left') then
        self.horizontal_selection_index = self.horizontal_selection_index - 1
        if self.horizontal_selection_index < 1 then self.horizontal_selection_index = #self.selections[self.vertical_selection_index] end
    end

    if input:pressed('right') then
        self.horizontal_selection_index = self.horizontal_selection_index + 1
        if self.horizontal_selection_index > #self.selections[self.vertical_selection_index] then self.horizontal_selection_index = 1 end
    end

    if input:pressed('return') then
        local t = self.selections[self.vertical_selection_index][self.horizontal_selection_index]
        if t then love.system.openURL(t.link) end
    end

    if input:pressed('escape') then
        self.active = false
        self.console:addInputLine(0.02, '[;root,]arch~ ')
    end
end

function CreditsModule:draw()
    if not self.active then return end
    
    local font = self.console.font
    local t = self.selections[self.vertical_selection_index][self.horizontal_selection_index]
    local x, y = t.ox - 1, self.vertical_selection_index*(font:getHeight() + 2) + 5
    if self.vertical_selection_index >= 6 then y = y + font:getHeight() + 2 end
    local w, h = t.w + 2, font:getHeight()
    local r, g, b = unpack(boost_color)
    love.graphics.setColor(r, g, b, 128)
    love.graphics.rectangle('fill', 8 + x, self.y + y, w, h)
    love.graphics.setColor(255, 255, 255, 255)
end

function CreditsModule:setSelections()
    local font = self.console.font
    self.selections = {
        [1] = {{ox = font:getWidth('    game by '), w = font:getWidth('SSYGEN'), link = 'https://twitter.com/SSYGEN'}},
        [2] = {{ox = font:getWidth('    music by '), w = font:getWidth('AIRGLOW'), link = 'https://stratfordct.bandcamp.com/album/airglow-memory-bank'}},
        [3] = {{ox = font:getWidth('    sound effects from '), w = font:getWidth('freesound.org'), link = 'https://freesound.org/'}},
        [4] = {
            {ox = font:getWidth('        '), w = font:getWidth('fins'), link = 'https://freesound.org/people/fins/'},
            {ox = font:getWidth('        fins '), w = font:getWidth('jeckkech'), link = 'https://freesound.org/people/jeckkech/'},
            {ox = font:getWidth('        fins jeckkech '), w = font:getWidth('josepharaoh99'), link = 'https://freesound.org/people/josepharaoh99/'},
            {ox = font:getWidth('        fins jeckkech josepharaoh99 '), w = font:getWidth('KorGround'), link = 'https://freesound.org/people/KorGround/'},
            {ox = font:getWidth('        fins jeckkech josepharaoh99 KorGround '), w = font:getWidth('NSStudios'), link = 'https://freesound.org/people/nsstudios/'},
            {ox = font:getWidth('        fins jeckkech josepharaoh99 KorGround NSStudios '), w = font:getWidth('TreasureSounds'), link = 'https://freesound.org/people/TreasureSounds/'},
            {ox = font:getWidth('        fins jeckkech josepharaoh99 KorGround NSStudios TreasureSounds '), w = font:getWidth('TheDweebMan'), link = 'https://freesound.org/people/TheDweebMan/'},
        },
        [5] = {
            {ox = font:getWidth('        '), w = font:getWidth('LittleRobotSoundFactory'), link = 'https://freesound.org/people/LittleRobotSoundFactory/'},
            {ox = font:getWidth('        LittleRobotSoundFactory '), w = font:getWidth('GameAudio'), link = 'https://www.gameaudio101.com/'},
            {ox = font:getWidth('        LittleRobotSoundFactory GameAudio '), w = font:getWidth('NenadSimic'), link = 'https://freesound.org/people/NenadSimic/'},
            {ox = font:getWidth('        LittleRobotSoundFactory GameAudio NenadSimic '), w = font:getWidth('DrMinky'), link = 'https://freesound.org/people/DrMinky/'},
            {ox = font:getWidth('        LittleRobotSoundFactory GameAudio NenadSimic DrMinky '), w = font:getWidth('pyzaist'), link = 'https://freesound.org/people/pyzaist/'},
            {ox = font:getWidth('        LittleRobotSoundFactory GameAudio NenadSimic DrMinky pyzaist '), w = font:getWidth('CGEffex'), link = 'https://freesound.org/people/CGEffex/'},
            {ox = font:getWidth('        LittleRobotSoundFactory GameAudio NenadSimic DrMinky pyzaist CGEffex '), w = font:getWidth('broumbroum'), link = 'https://freesound.org/people/broumbroum/'},
        },
        [6] = {
            {ox = font:getWidth('        '), w = font:getWidth('Daniel Linssen'), link = 'https://twitter.com/managore'},
            {ox = font:getWidth('        Daniel Linssen '), w = font:getWidth('Troy'), link = 'http://www.pentacom.jp/pentacom/bitfontmaker2/gallery/?id=612'},
            {ox = font:getWidth('        Daniel Linssen Troy '), w = font:getWidth('Mark Simonson'), link = 'https://www.marksimonson.com/'},
        },
        [7] = {{ox = font:getWidth('    made with '), w = font:getWidth('love2d.org'), link = 'https://love2d.org/'}},
        [8] = {
            {ox = font:getWidth('        '), w = font:getWidth('slime'), link = 'https://twitter.com/slime73'},
            {ox = font:getWidth('        slime '), w = font:getWidth('bartbes'), link = 'https://twitter.com/bartbes'},
            {ox = font:getWidth('        slime bartbes '), w = font:getWidth('CapsAdmin'), link = 'https://steamcommunity.com/id/eliashogstvedt'},
            {ox = font:getWidth('        slime bartbes CapsAdmin '), w = font:getWidth('rxi'), link = 'https://github.com/rxi'},
            {ox = font:getWidth('        slime bartbes CapsAdmin rxi '), w = font:getWidth('RolandYonaba'), link = 'https://github.com/Yonaba'},
            {ox = font:getWidth('        slime bartbes CapsAdmin rxi RolandYonaba '), w = font:getWidth('vrld'), link = 'https://twitter.com/the_vrld'},
            {ox = font:getWidth('        slime bartbes CapsAdmin rxi RolandYonaba vrld '), w = font:getWidth('pelevesque'), link = 'https://github.com/pelevesque'},
            {ox = font:getWidth('        slime bartbes CapsAdmin rxi RolandYonaba vrld pelevesque '), w = font:getWidth('davisdude'), link = 'https://github.com/pelevesque'},
            {ox = font:getWidth('        slime bartbes CapsAdmin rxi RolandYonaba vrld pelevesque davisdude '), w = font:getWidth('gvx'), link = 'https://twitter.com/gvxdev'},
            {ox = font:getWidth('        slime bartbes CapsAdmin rxi RolandYonaba vrld pelevesque davisdude gvx '), w = font:getWidth('bakpakin'), link = 'http://bakpakin.com/'},
        },
    }
end
