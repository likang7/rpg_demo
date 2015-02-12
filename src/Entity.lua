local const = require "const"
local helper = require "utils.helper"

local Direction = const.Direction
local DiagDirection = const.DiagDirection
local DirectionToVec = const.DirectionToVec
local math = math
local Status = const.Status

Entity = class("Entity",
    function()
        return cc.Sprite:create()  
    end
)

Entity.__index = Entity

local ANIMATE_TYPE = {idle=0, run=1, attack=2, hurt=3, die=4}
local IDLE_DELAYTIME = 1
local function onNodeEvent(tag)
    if tag == "exit" then
        print("xxxxxxxxxxxxxxxxxxxxxx")
        -- self.runAnimationFrames:release()        
    end
end

function Entity:create(data)
    local sprite = Entity.new()
    sprite:init(data)

    return sprite
end

function Entity:ctor()
end

function Entity:createAnimationFrames(isFullDir, pname, prefix, num)
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    local frames = {}

    local directions
    if isFullDir then
        directions = Direction
    else
        directions = DiagDirection
    end

    for _, dir in pairs(directions) do
        frames[dir] = {}
        for i = 0, num-1 do 
            local name = string.format("%s-%s-%d%d.tga", pname, prefix, dir, i)
            table.insert(frames[dir], spriteFrameCache:getSpriteFrame(name))
        end
    end
    return frames
end

function Entity:playAnimation(frames, callback, isFullDir, dt, target)
    if target == nil then
        target = self
    end

    local dir
    if isFullDir then
        dir = self.dir
    else
        dir = const.FullToDiagDir[self.dir]
    end

    local animate = cc.Animate:create(cc.Animation:createWithSpriteFrames(frames[dir], dt))
    if callback ~= nil then
        local callFunc = cc.CallFunc:create(callback)
        local seq = cc.Sequence:create(animate, callFunc)
        target:runAction(seq)
    else
        target:runAction(animate)
    end
end

function Entity:setStandDirection(dir)
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    local frame = spriteFrameCache:getSpriteFrame(string.format("bgj-stand-%d0.tga", dir))
    self:setSpriteFrame(frame)
end

function Entity:stopRuning()
    if self.status ~= Status.run then
        return
    end
    
    self:stopActionByTag(self.runAnimateTag)
    self:setStandDirection(self.dir)
    -- self:setStatus(Status.idle)
end

function Entity:_run(path, idx, cb_end, dir)
    self:setStatus(Status.run)
    if path[idx] == nil then
        if cb_end ~= nil then
            cb_end()
        else
            self:stopRuning()
        end
        return
    end

    local playerPos = cc.p(self:getPosition())

    if dir == nil then
        dir = helper.getDirection(playerPos, path[idx])
    end

    -- 同一方向的弄在同一个action里走
    local end_idx = idx + 1
    while path[end_idx] ~= nil do
        local next_dir = helper.getDirection(path[end_idx - 1], path[end_idx])
        if next_dir ~= dir then
            break
        end
        end_idx = end_idx + 1
    end
    idx = end_idx - 1

    -- 移动精灵，并递归走剩下的路径
    local distance = cc.pGetDistance(playerPos, path[idx])
    -- print('t = ', distance/self.speed)
    local moveTo = cc.MoveTo:create(distance/self.speed, path[idx])
    local cb = cc.CallFunc:create(
        function() 
            self:_run(path, idx + 1, cb_end)
        end
    )
    local seq = cc.Sequence:create(moveTo, cb)
    seq:setTag(self.runActionTag)
    self:runAction(seq)

    -- 播放奔跑动画
    if dir ~= self.dir or self:getActionByTag(self.runAnimateTag) == nil then
        self:stopActionByTag(self.runAnimateTag)
        local repeatForever = cc.RepeatForever:create(
        cc.Animate:create(cc.Animation:createWithSpriteFrames(self.runAnimationFrames[dir], self.runAnimDelay)))
        repeatForever:setTag(self.runAnimateTag)
        self:runAction(repeatForever)
    end
    self.dir = dir
end

function Entity:runPath(path, cb_end, dir)
    if self.status ~= Status.idle and self.status ~= Status.run then
        return
    end
    self._model:setPath(path)
end

function Entity:runOneStep(dir)
    if self.status ~= Status.idle and self.status ~= Status.run then
        return
    end

    if dir ~= nil then
        self._model:setKeyboardMoveDir(true, dir)
    else
        self._model:setKeyboardMoveDir(false, dir)
    end
end

function Entity:releaseCache()
end

function Entity:tryAttack()
    if self.status == Status.attack or self.status == Status.hurt then
        return false
    end

    self:stopActionByTag(self.runAnimateTag)
    self._model.runFlag = false
    self:setStatus(Status.attack)
    local cb = function ()
        if self.status == Status.attack then
            self:setStandDirection(self.dir)
            self:setStatus(Status.idle)
        end
    end

    self:playAnimation(self.attackAnimationFrames, cb, false, self.runAnimDelay * 0.8)

    --技能特效
    local rect = self:getTextureRect()
    local effect = cc.Sprite:create()
    local cb = function ()
        effect:removeFromParent(true)
    end
    self:playAnimation(self.atkEffectAnimationFrames, cb, true, self.runAnimDelay * 0.8, effect)
    local v = DirectionToVec[self.dir]
    local r = const.TILESIZE * 0.8
    local dx, dy = v[1] * r, v[2] * r -- * INVSQRT2
    local moveBy = cc.MoveBy:create(0.3, cc.p(dx, dy))
    effect:runAction(moveBy)
    self:addChild(effect,-1)
    effect:setPosition(rect.width * 0.8 + 0.5 * r * v[1], rect.height * 0.5 + 0.5 * r * v[2])
    return true
end

function Entity:setStatus(status)
    if status == Status.idle then
        if self.status == Status.run then
            self:stopActionByTag(self.runAnimateTag)
            self:setStandDirection(self.dir)
        end
        if self:getActionByTag(self.idleActionTag) == nil and self.idleScheduleID == nil then
            local cb = function ()
                if self.status == Status.idle and self:getActionByTag(self.idleActionTag) == nil then
                    local repeatForever = cc.RepeatForever:create(cc.Animate:create(
                        cc.Animation:createWithSpriteFrames(self.idleAnimationFrames[self.dir], self.runAnimDelay)))
                    repeatForever:setTag(self.idleActionTag)
                    self:runAction(repeatForever)
                    local scheduler = cc.Director:getInstance():getScheduler()
                    scheduler:unscheduleScriptEntry(self.idleScheduleID)
                    self.idleScheduleID = nil
                end
            end
            local scheduler = cc.Director:getInstance():getScheduler()
            self.idleScheduleID = scheduler:scheduleScriptFunc(cb, IDLE_DELAYTIME, false)
        end
    else
        self:stopActionByTag(self.idleActionTag)
        if self.idleScheduleID ~= nil then
            local scheduler = cc.Director:getInstance():getScheduler()
            scheduler:unscheduleScriptEntry(self.idleScheduleID)
            self.idleScheduleID = nil
        end
    end
    self.status = status
end

function Entity:showHurt(deltaHp, isCritial)
    if isCritial == nil then
        isCritial = false
    end
    -- self:stopRuning()
    self:setStatus(Status.hurt)
    
    -- 飘血
    local fontSize = 24
    if isCritial == true then
        fontSize = 28
    end
    local bloodLabel = cc.Label:createWithSystemFont(tostring(-deltaHp), const.DEFAULT_FONT, fontSize)
    self:getParent():addChild(bloodLabel, 10)
    local rect = self:getTextureRect()
    bloodLabel:setPosition(self:getPositionX(), self:getPositionY() + rect.height - const.TILESIZE/2)
    if self:getCamp() == 0 then
        bloodLabel:setColor(cc.c3b(0,0,255))
    else
        bloodLabel:setColor(cc.c3b(255, 0, 0))
    end
    local moveup = cc.MoveBy:create(0.8, cc.p(0, 100))
    local callFunc = cc.CallFunc:create(function ()
        bloodLabel:removeFromParent(true)
    end)
    local seq = cc.Sequence:create(moveup, callFunc)
    bloodLabel:runAction(seq)

    -- 击中特效
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    local frames = {}
    for i = 0, 4 do 
        local name = string.format("%s-%s-%03d.tga", 'effect', 'hit', i)
        table.insert(frames, spriteFrameCache:getSpriteFrame(name))
    end 
    local effect = cc.Sprite:create()
    local animate = cc.Animate:create(cc.Animation:createWithSpriteFrames(frames, self.runAnimDelay))
    local callFunc = cc.CallFunc:create(function ()
        effect:removeFromParent()
    end)
    local seq = cc.Sequence:create(animate, callFunc)
    effect:setScale(0.2)
    effect:runAction(seq)
    effect:setPosition(rect.width * 0.8, rect.height * 0.67)
    self:addChild(effect)

    -- 死亡
    if self:getLifeState() == const.LifeState.Die then
        local cb = function ()
            local scheduler = cc.Director:getInstance():getScheduler()
            if self.idleScheduleID ~= nil then
                scheduler:unscheduleScriptEntry(self.idleScheduleID)
            end
            if self.sechedulerAIID ~= nil then
                scheduler:unscheduleScriptEntry(self.sechedulerAIID)
            end
            self:setVisible(false)
            self:setStatus(Status.die)
        end
        print('gua le')
        self:setStatus(Status.dying)
        self:stopActionByTag(self.runAnimateTag)
        self:playAnimation(self.dyingAnimationFrames, cb, false, self.runAnimDelay)
    else
        local cb = function ()
            if self.status == Status.hurt then
                self:setStatus(Status.idle)
                self:setStandDirection(self.dir)
            end
        end
        if self.status == Status.hurt then
            --TODO:这里最好还是取消上一次的击中回调吧
            -- 避免受伤到一半状态就被取消了
            self:playAnimation(self.hitAnimationFrames, cb, false, self.runAnimDelay * 0.5)
        end
    end
end

function Entity:setAIComp(comp)
    self.aiComp = comp
end

function Entity:updatePosition()
    if self._model.runFlag == true then
        local p = self._model.pos
        self:setPosition(p.x, p.y)
        self:setStatus(Status.run)
        -- 播放奔跑动画
        if self._model.dir ~= self.dir or self:getActionByTag(self.runAnimateTag) == nil then
            self.dir = self._model.dir
            self:stopActionByTag(self.runAnimateTag)
            local repeatForever = cc.RepeatForever:create(
            cc.Animate:create(cc.Animation:createWithSpriteFrames(self.runAnimationFrames[self.dir], self.runAnimDelay)))
            repeatForever:setTag(self.runAnimateTag)
            self:runAction(repeatForever)
        end
    elseif self.status == Status.run then
        self:setStatus(Status.idle)
        self:stopActionByTag(self.runAnimateTag)
    end
end

function Entity:step(dt)
    if self.aiComp ~= nil then
        self.aiComp:step()
    end

    self._model:step(dt)

    -- 更新角色位置，以及跑的动画
    self:updatePosition()
end

function Entity:updateDir(dir)
    self.dir = dir
    self._model.dir = dir
end

function Entity:obtainItem(item)
    local info = item:getItemInfo()
    self._model:onObtainItem(info)
    item:onObtain()
    -- 显示
    local msg = helper.getRewardInfoByItemInfo(info)
    local bloodLabel = cc.Label:createWithSystemFont(msg, const.DEFAULT_FONT, 24)
    self:getParent():addChild(bloodLabel, 10)
    local rect = self:getTextureRect()
    bloodLabel:setPosition(self:getPositionX(), self:getPositionY() + rect.height - const.TILESIZE/2)
    bloodLabel:setColor(cc.c3b(0, 255, 0))

    local moveup = cc.MoveBy:create(0.8, cc.p(0, 100))
    local callFunc = cc.CallFunc:create(function ()
        bloodLabel:removeFromParent(true)
    end)
    local seq = cc.Sequence:create(moveup, callFunc)
    bloodLabel:runAction(seq)
end

-- skillId 暂时用不上
function Entity:attack(enemys, skillId)
    -- 1. 尝试播放攻击动画(如果不能，返回)
    self._model:attack(enemys, skillId)
end

function Entity:getLifeState()
    return self._model.lifeState
end

function Entity:getRangeId()
    return self._model.rangeId
end

function Entity:getCamp()
    return self._model.camp
end

function Entity:getAtkRange()
    return self._model.atkRange
end

function Entity:init(data)
    self._model = data
    self.name = data.name
    self.dir = data.dir
    self:setScale(0.8)

    self.texturePlist = data.texturePath
    local pos = self._model.pos
    self:setPosition(pos.x, pos.y)
    local effectPath = data.effectPath

    self.runAnimDelay = 0.1
    self.runActionTag = 10
    self.runAnimateTag = 11
    self.idleActionTag = 12
    self.idleScheduleID = nil
    
    self.status = Status.idle
    self.aiComp = nil

    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames(self.texturePlist)
    
    spriteFrameCache:addSpriteFrames(effectPath)

    self.runAnimationFrames = self:createAnimationFrames(true, self.name, 'run', 8)

    self.attackAnimationFrames = self:createAnimationFrames(false, self.name, 'skill1', 16)

    self.hitAnimationFrames = self:createAnimationFrames(false, self.name, 'hit', 2)

    self.dyingAnimationFrames = self:createAnimationFrames(false, self.name, 'die', 10)

    self.idleAnimationFrames = self:createAnimationFrames(true, self.name, 'stand', 8)

    self.atkEffectAnimationFrames = self:createAnimationFrames(true, 'effect', 'skill1', 8)

    self:setStandDirection(Direction.S)

    self:setStatus(Status.idle)

    self:setAnchorPoint(cc.p(0.5, 0.25))

    self:registerScriptHandler(onNodeEvent)
end

return Entity