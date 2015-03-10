local helper = require "utils.helper"
local const = require "const"
local Globals = require "model.Globals"
local roleData = require "data.roleData"
local Direction = const.Direction
local DirectionToVec = const.DirectionToVec

local math = math
local pairs = pairs
local next = next
local table = table

EntityData = class("EntityData")

EntityData.__index = EntityData

local INVSQRT2 = 1.0 / math.sqrt(2)

function EntityData:ctor()
    

end

function EntityData:createWithDict(dict)
    local data = EntityData.new()
    data:init(dict)
    return data
end

function EntityData:create(eid)
    local dict = roleData[eid]

    if dict.level == nil then
        dict.level = 1
    end

    if eid == const.HERO_ID then
        dict.detectRange = const.TILESIZE * 5
    end

    if dict.dir == nil then
        dict.dir = math.random(0,7)
    end

    return self:createWithDict(dict)
end

function EntityData:setPath(path)
    self.pathIdx = 1
    self.path = path
    if next(path) ~= nil then
        self.runFlag = true
    else
        self.runFlag = false
    end
    self.runTimeUsed = 0
    self.runTimeTotal = 0
    self.controlType = const.ControlType.Click
end

function EntityData:setKeyboardMoveDir(flag, dir)
    self.runFlag = flag
    if dir ~= nil then
        self.dir = dir
    end
    self.controlType = const.ControlType.Keyboard
end

function EntityData:updateDirWithPoint(p)
    local dir = helper.getDirection(self.pos, p)
    self.dir = dir
end

-- 更新用户点击屏幕行走时的位置
function EntityData:updatePositionClick(dt)
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

-- 更新用户键盘控制行走时的位置
function EntityData:updatePositionKeyboard(dt)
    local vec = DirectionToVec[self.dir]
    local dx, dy = dt * self.speed * vec[1], dt * self.speed * vec[2]
    if vec[1] ~= 0 and vec[2] ~= 0 then
        dx, dy = dx * INVSQRT2, dy * INVSQRT2
    end

    local newx, newy = self.pos.x + dx, self.pos.y + dy
    if Globals.gameMap:isValidViewPoint(newx, newy) then
        self.pos.x, self.pos.y = newx, newy
    end
end

function EntityData:step(dt)
    if self.runFlag == true then
        -- 更新角色位置
        if self.controlType == const.ControlType.Click then
            self:updatePositionClick(dt)
        elseif self.controlType == const.ControlType.Keyboard then
            self:updatePositionKeyboard(dt)
        end
    end
end

function EntityData:setPosition(x, y)
    self.pos.x, self.pos.y = x, y
end

function EntityData:calHurt(target, skillData)
    if skillData == nil then
        skillData = {rate=1, additional=0}
    end
    local base = self.atk - target.def
    local hurt = base * skillData.rate + skillData.additional

    local criProb = (self.criRate - target.antiCriRate) / 100.0
    local isCritial = math.random() < criProb
    if isCritial == true then
        hurt = 2 * hurt
    end

    return math.max(0, hurt), isCritial
end

function EntityData:attack(enemys, skillId)
    --TODO: 应该根据skillId来初始化
    skillData = {theta=90, r=self.atkRange, rate=1, additional=0}
    local targets = Globals.gameMap:searchTargetsInFan(self.pos.x, self.pos.y, self.dir, skillData.r, skillData.theta, enemys)
    for _, target in pairs(targets) do
        local targetData = target._model
        if targetData.lifeState == const.LifeState.Alive then
            local hurt, isCritial = self:calHurt(targetData, skillData)
            if hurt > 0 then
                targetData.hp = targetData.hp - hurt
                if targetData.hp <= 0 then
                    targetData.hp = 0
                    targetData.lifeState = const.LifeState.Die
                    if self.type == const.ENTITY_TYPE.Hero then
                        Globals.player:onKillMonster(targetData)
                    end
                end
            end
            target:showHurt(hurt, isCritial)
        end
    end
end

function EntityData:findTarget(enemys, range)
    if range == nil then
        range = self.detectRange
        if range == nil then
            range = self.atkRange
        end
    end

    local targets = {}
    for _, enemy in pairs(enemys) do
        if enemy:getLifeState() == const.LifeState.Alive then
            ex, ey = enemy:getPosition()
            local dis = cc.pGetDistance(cc.p(ex, ey), self.pos)
            if dis < math.max(self.atkRange, range) then
                table.insert(targets, {["target"]=enemy, ["dis"]=dis})
            end
        end
    end

    local comp = function (a, b)
        return a.dis < b.dis
    end
    table.sort(targets, comp)
    local r = targets[1]
    if r ~= nil then
        return r.target
    else
        return nil
    end
end

function EntityData:onObtainItem(itemInfo)
    if itemInfo.attack ~= nil then
        self.atk = self.atk + itemInfo.attack
    elseif itemInfo.defense ~= nil then
        self.def = self.def + itemInfo.defense
    elseif itemInfo.hp ~= nil then
        self.hp = self.hp + itemInfo.hp
    elseif itemInfo.critical ~= nil then
        self.criRate = self.criRate + itemInfo.critical
    elseif itemInfo.block ~= nil then
        self.antiCriRate = self.antiCriRate + itemInfo.block
    end
end

function EntityData:getPersistent()
    return {
        roleID = self.roleID,
        name = self.name,
        speed = self.speed,
        dir = self.dir,
        camp = self.camp,
        atk = self.atk,
        def = self.def,
        hp = self.hp,
        criRate = self.criRate,
        antiCriRate = self.antiCriRate,
        maxhp = self.maxhp,
        atkRange = self.atkRange,
        detectRange = self.detectRange,
        pos = self.pos,
        effectPath = self.effectPath,
        atkDelay = self.atkDelay,
        headIcon = self.headIcon,
        dialog = self.dialog,
        ['type'] = self.type,
        coinDrop = self.coinDrop,
        expDrop = self.expDrop,
        meetConversationID = self.meetConversationID,
        dieConversationID = self.ConversationID,
        soundID = self.soundID,
    }
end

function EntityData:setBornPoint(p, resetPos)
    self.bornPoint = p
    if self.pos == nil or resetPos == true then
        self.pos = cc.p(p.x, p.y)
    end
end

function EntityData:setAtk(atk)
    self.atk = atk
end

function EntityData:setDef(def)
    self.def = def
end

function EntityData:setHp(hp)
    self.hp = hp
end

function EntityData:setCriRate(criRate)
    self.criRate = math.min(100, math.max(0, criRate))
end

function EntityData:setAntiCriRate(antiCriRate)
    self.antiCriRate = math.min(100, math.max(0, antiCriRate))
end

function EntityData:getDialog()
    if self.dialog ~= nil then
        if Globals.player:isTaskFinished() and self.dialog[2] ~= nil then
            return self.dialog[2]
        else
            return self.dialog[1]
        end
    else
        return nil
    end
end

function EntityData:init(dict)
    for k, v in pairs(dict) do
        self[k] = v
    end

    if dict.camp == nil then
        self.camp = 1
    end

    if dict.maxhp == nil then
        self.maxhp = dict.hp
    else
        self.maxhp = dict.maxhp
    end

    self.atkRange = 40--dict.atkRange
    self.texturePath = self.roleID .. '.plist'
    self.lifeState = const.LifeState.Alive
    self.atkDelay = 0.6--dict.atkDelay
    self.atkLock = false

    if dict.controlType == nil then
        self.controlType = const.ControlType.Click
    end

    -- 角色移动相关的变量
    self.runFlag = false
    self.bornPoint = dict.pos
    self.path = {}
    self.pathIdx = 1
    self.runTimeUsed = 0
    self.runTimeTotal = 0
    self.startPos = cc.p(0, 0)
    self.deltaPos = cc.p(0, 0)

    self.dialog = dict.dialog--"放弃吧！你走不出我的手掌心的！"
end