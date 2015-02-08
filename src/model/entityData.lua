local helper = require "utils.helper"
local const = require "const"
local Direction = const.Direction
local DirectionToVec = const.DirectionToVec
EntityData = class("EntityData")

EntityData.__index = EntityData

function EntityData:ctor()
    

end

function EntityData:createWithDict(dict, gameMap)
    local data = EntityData.new()
    data:init(dict, gameMap)
    return data
end

function EntityData:create(eid, gameMap)
    local dict
    if eid == 1 then
        dict = {name='bgj', speed=200, dir=Direction.S,
                camp=1, atk=100, def=10, hp=2000}
    else
        dict = {name='bgj', speed=100, dir=Direction.S,
                camp=1, atk=80, def=10, hp=200}
    end

    return self:createWithDict(dict, gameMap)
end

function EntityData:setPath(path)
    self.pathIdx = 1
    self.path = path
    if #path >= 1 then
        self.runFlag = true
    else
        self.runFlag = false
    end
    self.runTimeUsed = 0
    self.runTimeTotal = 0
end

function EntityData:step(dt)
    local dst = self.path[self.pathIdx]
    if dst ~= nil and self.speed > 0 then
        self.runFlag = true

        if self.runTimeUsed >= self.runTimeTotal then
            -- 跑完一段，该跑下一段了
            self.runTimeTotal = cc.pGetDistance(self.pos, dst) / self.speed
            self.runTimeUsed = 0
            self.startPos.x, self.startPos.y = self.pos.x, self.pos.y
            self.deltaPos.x, self.deltaPos.y = dst.x - self.pos.x, dst.y - self.pos.y
            -- 更新方向
            local dir = helper.getDirection(self.pos, dst)
            self.dir = dir
        end
        
        -- 根据百分比更新坐标
        self.runTimeUsed = self.runTimeUsed + dt
        local percent = math.min(1, self.runTimeUsed / self.runTimeTotal)
        local vec = DirectionToVec[dir]
        local newx, newy =  self.startPos.x + percent * self.deltaPos.x,
                            self.startPos.y + percent * self.deltaPos.y

        self.pos.x, self.pos.y = newx, newy

        if self.runTimeUsed >= self.runTimeTotal then
            self.pathIdx = self.pathIdx + 1
        end
    else
        self.runFlag = false
    end
end

function EntityData:setPosition(x, y)
    self.pos.x, self.pos.y = x, y
end

function EntityData:init(dict, gameMap)
    self.name = dict.name
    self.speed = dict.speed
    self.dir = dict.dir
    self.camp = dict.camp
    self.atk = dict.atk
    self.def = dict.def
    self.hp = dict.hp
    self.texturePath = self.name .. '.plist'
    self.effectPath = 'effect.plist'

    self.pos = dict.pos
    self.path = {}
    self.pathIdx = 1
    self.runTimeUsed = 0
    self.runTimeTotal = 0
    self.runFlag = false
    self.startPos = cc.p(0, 0)
    self.deltaPos = cc.p(0, 0)

    self.gameMap = gameMap
    
end