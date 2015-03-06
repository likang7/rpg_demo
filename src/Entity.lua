local const = require "const"
local helper = require "utils.helper"
local flashData = require "data.flashData"

local Direction = const.Direction
local DiagDirection = const.DiagDirection
local DirectionToVec = const.DirectionToVec
local math = math
local Status = const.Status
local performWithDelay = performWithDelay

Entity = class("Entity",
    function()
        return cc.Sprite:create()  
    end
)

Entity.__index = Entity

local ANIMATE_TYPE = {idle=1, run=2, attack=3, hurt=4, die=5}
local IDLE_DELAYTIME = 1
local function onNodeEvent(tag)
    if tag == "exit" then
        cclog("xxxxxxxxxxxxxxxxxxxxxx")
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

function Entity:createAnimationFrames(dNum, prefix, frameNum)
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    local frames = {}

    local directions
    if dNum == 8 then
        directions = Direction
    elseif dNum == 4 then
        directions = DiagDirection
    elseif dNum == 1 then
        directions = {self.dir}
    else
        error('undefined direction number')
    end

    for _, dir in pairs(directions) do
        frames[dir] = {}
        for i = 0, frameNum-1 do 
            local name
            if frameNum > 10 then
                name = string.format("%s-%d%02d.tga", prefix, dir, i)
            else
                name = string.format("%s-%d%d.tga", prefix, dir, i)
            end
            table.insert(frames[dir], spriteFrameCache:getSpriteFrame(name))
        end
    end
    return frames
end

function Entity:playAnimation(frames, callback, isFullDir, dt, target, tag)
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
        if tag ~= nil then
            seq:setTag(tag)
        end
    else
        target:runAction(animate)
        if tag ~= nil then
            animate:setTag(tag)
        end
    end
end

function Entity:setStandDirection(dir)
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    dir = self:getAnimDir(dir, ANIMATE_TYPE.idle)
    if self.idleFrameCnt > 10 then
        dir = dir .. '0'
    end
    local frame = spriteFrameCache:getSpriteFrame(string.format(self.name .. ANIMATE_TYPE.idle .. "-%d0.tga", dir))
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
    -- cclog('t = %f', distance/self.speed)
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
        local tDir = self:getAnimDir(dir, ANIMATE_TYPE.run)
        local repeatForever = cc.RepeatForever:create(
            cc.Animate:create(cc.Animation:createWithSpriteFrames(self.runAnimationFrames[tDir], self.runAnimDelay)))
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
    if self.status == Status.attack or self.status == Status.hurt or self._model.atkLock then
        return false
    end

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
                    local _dir = self:getAnimDir(self.dir, ANIMATE_TYPE.idle)
                    local repeatForever = cc.RepeatForever:create(cc.Animate:create(
                        cc.Animation:createWithSpriteFrames(self.idleAnimationFrames[_dir], self.runAnimDelay)))
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
    self:stopActionByTag(self.atkAnimateTag)
    self.status = status
end

function Entity:showHurt(deltaHp, isCritial)
    if isCritial == nil then
        isCritial = false
    end
    -- self:stopRuning()
    
    -- 飘血
    local fontSize = 24
    if isCritial then
        fontSize = fontSize * 1.5
    end

    local msg = tostring(-deltaHp)
    if deltaHp <= 0 then
        msg = 'MISS'
    end

    local color = cc.c3b(0, 0, 255)
    if self:getCamp() ~= 0 then
        color = cc.c3b(255, 0, 0)
    end

    local rect = self:getTextureRect()
    local pos = cc.p(self:getPositionX(), self:getPositionY() + rect.height - const.TILESIZE/2)

    helper.jumpMsg(self:getParent(), msg, color, pos, fontSize)

    -- 击中特效
    -- local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    -- local frames = {}
    -- for i = 0, 4 do 
    --     local name = string.format("%s-%s-%03d.tga", 'effect', 'hit', i)
    --     table.insert(frames, spriteFrameCache:getSpriteFrame(name))
    -- end 
    -- local effect = cc.Sprite:create()
    -- local animate = cc.Animate:create(cc.Animation:createWithSpriteFrames(frames, self.runAnimDelay))
    -- local callFunc = cc.CallFunc:create(function ()
    --     effect:removeFromParent()
    -- end)
    -- local seq = cc.Sequence:create(animate, callFunc)
    -- effect:setScale(0.2)
    -- effect:runAction(seq)
    -- effect:setPosition(rect.width * 0.8, rect.height * 0.67)
    -- self:addChild(effect)

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
            if self.drawNode ~= nil then
                self.drawNode:removeFromParent(true)
            end
            self:setVisible(false)
            self:setStatus(Status.die)
        end
        cclog('gua le')
        self:setStatus(Status.dying)
        self:stopActionByTag(self.runAnimateTag)
        self:playAnimation(self.dyingAnimationFrames, cb, false, self.runAnimDelay)
    elseif deltaHp > 0 then
        local cb = function ()
            if self.status == Status.hurt then
                self:setStatus(Status.idle)
                self:setStandDirection(self.dir)
            end
        end
        self:setStatus(Status.hurt)
        --TODO:这里最好还是取消上一次的击中回调吧
        -- 避免受伤到一半状态就被取消了
        self:playAnimation(self.hitAnimationFrames, cb, false, self.runAnimDelay * 0.5)
    end
end

function Entity:setAIComp(comp)
    self.aiComp = comp
end

function Entity:setDialogComp(comp)
    self.dialogComp = comp
end

function Entity:updatePosition()
    if self._model.runFlag == true then
        local p = self._model.pos
        self:setPosition(p.x, p.y)
        self:setStatus(Status.run)
        -- 播放奔跑动画
        if self._model.dir ~= self.dir or self:getActionByTag(self.runAnimateTag) == nil then
            self.dir = self._model.dir
            local dir = self:getAnimDir(self.dir, ANIMATE_TYPE.run)
            self:stopActionByTag(self.runAnimateTag)
            local repeatForever = cc.RepeatForever:create(
                cc.Animate:create(cc.Animation:createWithSpriteFrames(self.runAnimationFrames[dir], self.runAnimDelay)))
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

    if self.dialogComp ~= nil then
        self.dialogComp:step()
    end

    self._model:step(dt)

    -- 更新角色位置，以及跑的动画
    self:updatePosition()

    -- 更新警戒范围的显示
    self:updateDetectRangeShow()
end

function Entity:updateDetectRangeShow()
    if self.showDetectRange == true and self._model.detectRange ~= nil then
        if self.drawNode == nil then
            self.drawNode = cc.DrawNode:create()
            self.drawNode:drawDot(self._model.bornPoint, self._model.detectRange, cc.c4f(0,0,1.0, 0.2))
            self:getParent():addChild(self.drawNode, 1)
        else
            self.drawNode:setVisible(true)
        end
    else
        if self.drawNode ~= nil then
            self.drawNode:setVisible(false)
        end
    end
end

function Entity:setDetectRangeShow(flag)
    self.showDetectRange = flag
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
    local rect = self:getTextureRect()
    local pos = cc.p(self:getPositionX(), self:getPositionY() + rect.height - const.TILESIZE/2)
    helper.jumpMsg(self:getParent(), msg, cc.c3b(0, 255, 0), pos, 20)
end

function Entity:playAtkAnimate()
    self:stopActionByTag(self.runAnimateTag)
    self._model.runFlag = false
    self:setStatus(Status.attack)
    local cb = function ()
        if self.status == Status.attack then
            self:setStandDirection(self.dir)
            self:setStatus(Status.idle)
        end
    end

    self:playAnimation(self.attackAnimationFrames, cb, false, self.atkAnimDelay, self, self.atkAnimateTag)

    --技能特效
    if self.atkEffectAnimationFrames ~= nil then
        local rect = self:getTextureRect()
        local effect = cc.Sprite:create()
        local cb = function ()
            effect:removeFromParent(true)
        end
        self:playAnimation(self.atkEffectAnimationFrames, cb, true, self.runAnimDelay, effect)
        local v = DirectionToVec[self.dir]
        local r = const.TILESIZE * 0.8
        local dx, dy = v[1] * r, v[2] * r -- * INVSQRT2
        local moveBy = cc.MoveBy:create(0.3, cc.p(dx, dy))
        effect:runAction(moveBy)
        self:addChild(effect,-1)
        effect:setPosition(rect.width * 0.8 + 0.5 * r * v[1], rect.height * 0.5 + 0.5 * r * v[2])
    end
end

function Entity:findTarget(enemys)
    return self._model:findTarget(enemys)
end

function Entity:updateTarget(target)
    self:setTarget(target)
    if target ~= nil then
        self._model:updateDirWithPoint(target._model.pos)
        self:updateDir(self._model.dir)
        self:setStandDirection(self._model.dir)
    end
end

-- skillId 暂时用不上
function Entity:attack(enemys, skillId)
    local target = self:findTarget(enemys)
    self:updateTarget(target)

    -- 1. 播放攻击动画
    self:playAtkAnimate()

    -- 2. 攻击
    self._model:attack({target}, skillId)
    local cb = function ()
        self._model.atkLock = false
    end
    self._model.atkLock = true
    performWithDelay(self, cb, self._model.atkDelay)
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

function Entity:getDetectRange()
    return self._model.detectRange
end

function Entity:setTarget(target)
    self.targetEntity = target
end

function Entity:getTarget()
    return self.targetEntity
end

function Entity:getData()
    return self._model
end

function Entity:getDir()
    return self.dir
end

function Entity:getBornPoint()
    return self._model.bornPoint
end

function Entity:showDialog()
    if self.dialog == nil then
         -- 显示
        local fontSize = 22
        local msg = self._model.dialog
        self.label = cc.Label:createWithSystemFont(msg, const.DEFAULT_FONT, fontSize)
        -- self:addChild(self.label, 10)
        local rect = self:getTextureRect()
        self.label:setPosition(24, 5)
        self.label:setAnchorPoint(cc.p(0, 0))
        self.label:setColor(cc.c3b(0,0,0))
        self.label:setWidth(fontSize * 6)
        -- self.label:enableGlow(cc.c4b(0,0,255,255))

        local labelBox = self.label:getBoundingBox()
        self.dialog = ccui.Scale9Sprite:create(cc.rect(33,37.5,77,24), "conversationUI.png")
        self.dialog:setAnchorPoint(cc.p(0,0))
        self.dialog:setPreferredSize(cc.size(labelBox.width + 32, labelBox.height + 15))
        self.dialog:setPosition(14+const.TILESIZE/2, rect.height - 50)

        self.dialog:addChild(self.label)
        self:addChild(self.dialog, 9)
    else
        self.dialog:setVisible(true)
    end
end

function Entity:hideDialog()
    if self.dialog ~= nil then
        self.dialog:setVisible(false)
    end
end

function Entity:isRunning()
    return self._model.runFlag
end

function Entity:getAnimDir(dir, anim_type)
    if anim_type == ANIMATE_TYPE.run then
        if self._model.runDirs == 4 then
            return const.FullToDiagDir[dir]
        else
            return dir
        end
    elseif anim_type == ANIMATE_TYPE.idle then
        if self._model.standDirs == 4 then
            return const.FullToDiagDir[dir]
        else
            return dir
        end
    else
        return const.FullToDiagDir[dir]
    end
end

function Entity:getFuncionType()
    return self._model.funcType
end

function Entity:init(data)
    self._model = data
    self.name = data.roleID
    self.dir = data.dir
    self:setScale(0.8)

    self.texturePlist = data.texturePath
    local pos = self._model.pos
    self:setPosition(pos.x, pos.y)
    

    self.runAnimDelay = 0.1
    self.runActionTag = 10
    self.runAnimateTag = 11
    self.idleActionTag = 12
    self.idleScheduleID = nil

    self.atkAnimDelay = 0.03
    self.atkAnimateTag = 13
    
    self.status = Status.idle
    self.aiComp = nil
    self.dialogComp = nil

    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames(self.texturePlist)

    if self._model.type ~= const.ENTITY_TYPE.NPC then
        local runAnimData = flashData[tonumber(self.name .. ANIMATE_TYPE.run)]
        self.runAnimationFrames = self:createAnimationFrames(runAnimData.direction, self.name .. ANIMATE_TYPE.run, runAnimData.count)

        local attackAnimData = flashData[tonumber(self.name .. ANIMATE_TYPE.attack)]
        self.attackAnimationFrames = self:createAnimationFrames(attackAnimData.direction, self.name .. ANIMATE_TYPE.attack, attackAnimData.count)

        local hitAnimData = flashData[tonumber(self.name .. ANIMATE_TYPE.hurt)]
        self.hitAnimationFrames = self:createAnimationFrames(hitAnimData.direction, self.name .. ANIMATE_TYPE.hurt, hitAnimData.count)

        local dyingAnimData = flashData[tonumber(self.name .. ANIMATE_TYPE.die)]
        self.dyingAnimationFrames = self:createAnimationFrames(dyingAnimData.direction, self.name .. ANIMATE_TYPE.die, dyingAnimData.count)
    end

    local idleAnimData = flashData[tonumber(self.name .. ANIMATE_TYPE.idle)]
    self.idleFrameCnt = idleAnimData.count
    self.idleAnimationFrames = self:createAnimationFrames(idleAnimData.direction, self.name .. ANIMATE_TYPE.idle, idleAnimData.count)

    local effectPath = data.effectPath
    self.atkEffectAnimationFrames = nil
    if effectPath ~= nil then
        spriteFrameCache:addSpriteFrames(effectPath)
        self.atkEffectAnimationFrames = self:createAnimationFrames(8, 'effect-skill1', 8)
    end

    self:setStandDirection(self.dir)

    self:setStatus(Status.idle)

    self:setAnchorPoint(cc.p(0.5, 0.25))

    self:registerScriptHandler(onNodeEvent)

    self.drawNode = nil
    self.showDetectRange = true

    self.targetEntity = nil

    -- self:showDialog()
end

return Entity