InfoText = GameObject:extend()

function InfoText:new(area, x, y, opts)
    InfoText.super.new(self, area, x, y, opts)

    self.font = fonts.m5x7_16
    self.w, self.h = self.font:getWidth(self.text), self.font:getHeight()

    self.characters = {}
    self.background_colors = {}
    self.foreground_colors = {}
    for i = 1, #self.text do table.insert(self.characters, self.text:utf8sub(i, i)) end

    local all_info_texts = self.area:getAllGameObjectsThat(function(o) if o:is(Ammo) and o.id ~= self.id then return true end end)
    local collidesWithOtherInfoText = function()
        for _, info_text in ipairs(all_info_texts) do
            return areRectanglesOverlapping(self.x, self.y, self.x + self.w, self.y + self.h, info_text.x, info_text.y, info_text.x + info_text.w, info_text.y + info_text.h)
        end
    end
    while collidesWithOtherInfoText() do
        self.x = self.x + table.random({-1, 0, 1})*self.w
        self.y = self.y + table.random({-1, 0, 1})*self.h
    end
    
    self.visible = true
    self.timer:after(0.70, function()
        self.timer:every(0.05, function() self.visible = not self.visible end, 6)
        self.timer:after(0.35, function() self.visible = true end)

        self.timer:every(0.035, function()
            local random_characters = '0123456789!@#$%¨&*()-=+[]^~/;?><.,|abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYXZ'
            for i, character in ipairs(self.characters) do
                if love.math.random(1, 20) <= 1 then
                    local r = love.math.random(1, #random_characters)
                    self.characters[i] = random_characters:utf8sub(r, r)
                else self.characters[i] = character end

                if love.math.random(1, 10) <= 1 then self.background_colors[i] = table.random(all_colors)
                else self.background_colors[i] = nil end

                if love.math.random(1, 10) <= 2 then self.foreground_colors[i] = table.random(all_colors)
                else self.foreground_colors[i] = nil end
            end
        end)
    end)
    self.timer:after(1.10, function() self.dead = true end)
end

function InfoText:update(dt)
    InfoText.super.update(self, dt)
end

function InfoText:draw()
    if not self.visible then return end

    love.graphics.setFont(self.font)
    for i = 1, #self.characters do
        local width = 0
        if i > 1 then
            for j = 1, i-1 do
                width = width + self.font:getWidth(self.characters[j])
            end
        end

        if self.background_colors[i] then
      		love.graphics.setColor(self.background_colors[i])
      		love.graphics.rectangle('fill', self.x + width, self.y - self.font:getHeight()/2, self.font:getWidth(self.characters[i]), self.font:getHeight())
      	end
    	love.graphics.setColor(self.foreground_colors[i] or self.color or default_color)
    	love.graphics.print(self.characters[i], self.x + width, self.y, 0, 1, 1, 0, self.font:getHeight()/2)
    end
    love.graphics.setColor(default_color)
end

function InfoText:destroy()
    InfoText.super.destroy(self)
end
