Shake = Object:extend()

function Shake:new(amplitude, frequency, duration)
    self.amplitude = amplitude
    self.frequency = frequency
    self.duration = duration
    local sample_count = (self.duration/1000)*frequency
    self.samples = {}
    for i = 1, sample_count do self.samples[i] = random(-1, 1) end

    self.start_time = love.timer.getTime()*1000
    self.t = 0
    self.shaking = true
end

function Shake:update(dt)
    self.t = love.timer.getTime()*1000 - self.start_time
    if self.t > self.duration then self.shaking = false end
end

function Shake:getAmplitude(t)
    if not t then 
        if not self.shaking then return 0 end
        t = self.t
    end

    local s = (t/1000)*self.frequency
    local s0 = math.floor(s)
    local s1 = s0 + 1
    local k = self:decay(t)
    return self.amplitude*(self:noise(s0) + (s - s0)*(self:noise(s1) - self:noise(s0)))*k
end

function Shake:noise(s)
    if s >= #self.samples then return 0 end
    return self.samples[s] or 0
end

function Shake:decay(t)
    if t > self.duration then return 0 end
    return (self.duration - t)/self.duration
end
