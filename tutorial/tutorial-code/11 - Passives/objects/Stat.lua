Stat = Object:extend()

function Stat:new(base)
    self.base = base

    self.additive = 0
    self.additives = {}
    self.value = self.base*(1 + self.additive)
end

function Stat:update(dt)
    for _, additive in ipairs(self.additives) do self.additive = self.additive + additive end

    if self.additive >= 0 then
        self.value = self.base*(1 + self.additive)
    else
        self.value = self.base/(1 - self.additive)
    end

    self.additive = 0
    self.additives = {}
end

function Stat:increase(percentage)
    table.insert(self.additives, percentage*0.01)
end

function Stat:decrease(percentage)
    table.insert(self.additives, -percentage*0.01)
end
