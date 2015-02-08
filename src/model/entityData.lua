local const = require "const"
local Direction = const.Direction
EntityData = class("EntityData")

EntityData.__index = EntityData

function EntityData:ctor()
    

end

function EntityData:createWithDict(dict)
    local data = EntityData.new()
    data:init(dict)
    return data
end

function EntityData:create(eid)
    local dict
    if eid == 1 then
        dict = {name='bgj', speed=200, dir=Direction.S,
                camp=1, atk=100, def=10, hp=2000}
    else
        dict = {name='bgj', speed=100, dir=Direction.S,
                camp=1, atk=80, def=10, hp=200}
    end

    return self:createWithDict(dict)
end

function EntityData:setPath(path)
    self.pathIdx = 1
    self.path = path
end

function EntityData:step(dt)
    local dst = self.path[self.pathIdx]
    if dst ~= nil then
    end
end

function EntityData:init(dict)
    self.name = dict.name
    self.speed = dict.speed
    self.dir = dict.dir
    self.camp = dict.camp
    self.atk = dict.atk
    self.def = dict.def
    self.hp = dict.hp
    self.texturePath = self.name .. '.plist'
    self.effectPath = 'effect.plist'

    self.pos = cc.p(0, 0)
    self.path = {}
    self.pathIdx = 1
end