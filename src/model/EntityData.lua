local helper = require "utils.helper"
local const = require "const"
local Globals = require "model.Globals"
local roleData = require "data.roleData"
local Direction = const.Direction
local DirectionToVec = const.DirectionToVec
local math = math
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
    local dict
    if eid == const.HERO_ID then
        dict = roleData[eid]
        dict.level = 1
        dict.standDirs = 8
        dict.runDirs = 8

        -- dict = {roleID=1000, name='白晶晶', speed=200, dir=Direction.S, criRate=50, antiCriRate=50,
        --         camp=0, atk=100, def=10, hp=20000, maxhp=20000, controlType=const.ControlType.Keyboard,
        --         atkRange=40, atkDelay=0.5, level=1, standDirs=8, runDirs=8}
    elseif eid == 3 then
        dict = {roleID=3013, name='恶魔随从',speed=100, dir=Direction.S, criRate=30, antiCriRate=20,
                camp=1, atk=80, def=10, hp=200, maxhp=200, atkRange=40, atkDelay=0.5, level=3, standDirs=4, runDirs=4}
    else
        -- dict = {roleID=3001, name='恶魔随从',speed=100, dir=Direction.S, criRate=30, antiCriRate=20,
        --         camp=1, atk=80, def=10, hp=200, maxhp=200, atkRange=40, atkDelay=0.5, level=3, standDirs=4, runDirs=4}
        dict = roleData[eid]
        dict.level=1
    end

    return self:createWithDict(dict)
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

    local criProb = self.criRate - target.antiCriRate
    local isCritial = math.random() < criProb
    if isCritial == true then
        hurt = 2 * hurt
    end

    return hurt, isCritial
end

function EntityData:attack(enemys, skillId)
    --TODO: 应该根据skillId来初始化
    skillData = {theta=90, r=self.atkRange, rate=1, additional=0}
    local targets = Globals.gameMap:searchTargetsInFan(self.pos.x, self.pos.y, self.dir, skillData.r, skillData.theta, enemys)
    for _, target in pairs(targets) do
        if target._model.lifeState == const.LifeState.Alive then
            local hurt, isCritial = self:calHurt(target._model, skillData)
            if hurt > 0 then
                target._model.hp = target._model.hp - hurt
                if target._model.hp <= 0 then
                    target._model.hp = 0
                    target._model.lifeState = const.LifeState.Die
                end
            end
            target:showHurt(hurt, isCritial)
        end
    end
end

function EntityData:findTarget(enemys)
    local targets = {}
    for _, enemy in pairs(enemys) do
        if enemy:getLifeState() == const.LifeState.Alive then
            ex, ey = enemy:getPosition()
            local dis = cc.pGetDistance(cc.p(ex, ey), self.pos)
            local detectRange = self.detectRange
            if detectRange == nil then
                detectRange = self.atkRange
            end
            if dis < math.max(self.atkRange, detectRange) then
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
        self.criRate = self.criRate + itemInfo.critical / 100.0
    elseif itemInfo.block ~= nil then
        self.antiCriRate = self.antiCriRate + itemInfo.block / 100.0
    elseif itemInfo.coin ~= nil then
        cclog('coin should not be controled by me')
    end
    return s
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
        texturePath = self.texturePath,
        effectPath = self.effectPath,
        atkDelay = self.atkDelay,
        standDirs = self.standDirs,
        runDirs = self.runDirs,
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

function EntityData:init(dict)
    self.roleID = dict.roleID
    self.name = dict.name
    self.speed = dict.speed
    self.dir = dict.dir
    self.camp = dict.camp
    if dict.camp == nil then
        self.camp = 1
    end
    self.atk = dict.atk
    self.def = dict.def
    self.hp = dict.hp
    self.criRate = dict.criRate / 100.0
    self.antiCriRate = dict.antiCriRate / 100.0
    if dict.maxhp == nil then
        self.maxhp = dict.hp
    else
        self.maxhp = dict.maxhp
    end
    self.atkRange = 40--dict.atkRange
    self.detectRange = dict.detectRange
    self.texturePath = self.roleID .. '.plist'
    self.effectPath = 'effect.plist'
    self.lifeState = const.LifeState.Alive
    self.atkDelay = 0.6--dict.atkDelay
    self.atkLock = false
    self.level = dict.level

    self.rangeId = dict.rangeId

    if dict.controlType == nil then
        self.controlType = const.ControlType.Click
    end

    -- 角色移动相关的变量
    self.runFlag = false
    self.controlType = dict.controlType
    self.pos = dict.pos
    self.bornPoint = dict.pos
    self.path = {}
    self.pathIdx = 1
    self.runTimeUsed = 0
    self.runTimeTotal = 0
    self.startPos = cc.p(0, 0)
    self.deltaPos = cc.p(0, 0)

    self.dialog = "放弃吧！你走不出我的手掌心的！"

    self.standDirs = dict.standDirs
    if dict.standDirs == nil then
        self.standDirs = 4
    end

    self.runDirs = dict.runDirs
    if dict.runDirs == nil then
        self.runDirs = 4
    end
end