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
local RunAnimDelay = 0.1
local AtkAnimDelay = 0.03

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

function Entity:playSoundEffect(soundType)
    local audioEngine = cc.SimpleAudioEngine:getInstance()
    local path = nil
    if soundType == ANIMATE_TYPE.attack then
        path = self.atkEffectPath
    elseif soundType == ANIMATE_TYPE.hurt then
        path = self.hurtEffectPath
    elseif soundType == ANIMATE_TYPE.die then
        path = self.dieEffectPath
        audioEngine:stopAllEffects()
    end

    if path == nil then
        return 
    end
    
    audioEngine:playEffect(path, false)
end

function Entity:setStandDirection(dir)
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    dir = self:getAnimDir(dir, ANIMATE_TYPE.idle)
    if self.idleFrameCnt > 10 then
        dir = dir .. '0'
    end
    local frame = spriteFrameCache:getSpriteFrame(string.format(self.roleID .. ANIMATE_TYPE.idle .. "-%d0.tga", dir))
    self:setSpriteFrame(frame)
end

function Entity:stopRuning()
    if self.status ~= Status.run then
        return
    end
    
    self:stopActionByTag(ANIMATE_TYPE.run)
    self:setStandDirection(self.dir)
end

-- 鼠标点击或寻路控制的行走
function Entity:runPath(path, cb_end, dir)
    if self.status ~= Status.idle and self.status ~= Status.run then
        return
    end
    self._model:setPath(path)
end

-- 键盘控制的行走
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

function Entity:tryAttack()
    if self.status == Status.attack or self.status == Status.hurt or self._model.atkLock then
        return false
    end

    return true
end

function Entity:setStatus(status)
    if status == Status.idle then
        if self.status == Status.run then
            self:stopActionByTag(ANIMATE_TYPE.run)
            self:setStandDirection(self.dir)
        end
        -- 定时播放空闲动作
        if self:getActionByTag(ANIMATE_TYPE.idle) == nil and self.idleScheduleID == nil then
            local cb = function ()
                if self.status == Status.idle and self:getActionByTag(ANIMATE_TYPE.idle) == nil then
                    local _dir = self:getAnimDir(self.dir, ANIMATE_TYPE.idle)
                    local repeatForever = cc.RepeatForever:create(cc.Animate:create(
                        cc.Animation:createWithSpriteFrames(self.idleAnimationFrames[_dir], RunAnimDelay)))
                    repeatForever:setTag(ANIMATE_TYPE.idle)
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
        self:stopActionByTag(ANIMATE_TYPE.idle)
        if self.idleScheduleID ~= nil then
            local scheduler = cc.Director:getInstance():getScheduler()
            scheduler:unscheduleScriptEntry(self.idleScheduleID)
            self.idleScheduleID = nil
        end
    end
    self:stopActionByTag(ANIMATE_TYPE.attack)
    self:stopActionByTag(ANIMATE_TYPE.hurt)
    self.status = status
end

-- 飘血，播死亡或受击动画
function Entity:showHurt(deltaHp, isCritial)
    if isCritial == nil then
        isCritial = false
    end
    
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
        if not isCritial then
            color = cc.c3b(255, 0, 0)
        else
            color = cc.c3b(255, 255, 0)
        end
    end

    local pos = cc.p(self:getPositionX(), self:getPositionY() + const.TILESIZE * 2)

    helper.jumpMsg(self:getParent(), msg, color, pos, fontSize)

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
        self:setStatus(Status.dying)
        self:stopActionByTag(ANIMATE_TYPE.run)
        self:playAnimation(self.dyingAnimationFrames, cb, false, RunAnimDelay)
        self:playSoundEffect(ANIMATE_TYPE.die)
    elseif deltaHp > 0 then
        local cb = function ()
            if self.status == Status.hurt then
                self:setStatus(Status.idle)
                self:setStandDirection(self.dir)
            end
        end
        self:setStatus(Status.hurt)
        self:playAnimation(self.hitAnimationFrames, cb, false, RunAnimDelay * 0.5, self, ANIMATE_TYPE.hurt)
        performWithDelay(self, function() self:playSoundEffect(ANIMATE_TYPE.hurt) end, 0.05)
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
        if self._model.dir ~= self.dir or self:getActionByTag(ANIMATE_TYPE.run) == nil then
            self.dir = self._model.dir
            local dir = self:getAnimDir(self.dir, ANIMATE_TYPE.run)
            self:stopActionByTag(ANIMATE_TYPE.run)
            local repeatForever = cc.RepeatForever:create(
                cc.Animate:create(cc.Animation:createWithSpriteFrames(self.runAnimationFrames[dir], RunAnimDelay)))
            repeatForever:setTag(ANIMATE_TYPE.run)
            self:runAction(repeatForever)
        end
    elseif self.status == Status.run then
        self:setStatus(Status.idle)
        self:stopActionByTag(ANIMATE_TYPE.run)
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
    -- 显示或隐藏怪物警戒范围
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
    item:onObtain()
    -- 显示
    local msg = helper.getRewardInfoByItemInfo(info)
    local rect = self:getTextureRect()
    local pos = cc.p(self:getPositionX(), self:getPositionY() + const.TILESIZE * 2)
    helper.jumpMsg(self:getParent(), msg, cc.c3b(0, 255, 0), pos, 20)
end

function Entity:playAtkAnimate()
    self:stopActionByTag(ANIMATE_TYPE.run)
    self._model.runFlag = false
    self:setStatus(Status.attack)
    local cb = function ()
        if self.status == Status.attack then
            self:setStandDirection(self.dir)
            self:setStatus(Status.idle)
        end
    end

    self:playAnimation(self.attackAnimationFrames, cb, false, AtkAnimDelay, self, ANIMATE_TYPE.attack)

    --技能特效
    if self.atkEffectAnimationFrames ~= nil then
        local rect = self:getTextureRect()
        local effect = cc.Sprite:create()
        local cb = function ()
            effect:removeFromParent(true)
        end
        self:playAnimation(self.atkEffectAnimationFrames, cb, true, RunAnimDelay, effect)
        local v = DirectionToVec[self.dir]
        local r = const.TILESIZE * 0.8
        local dx, dy = v[1] * r, v[2] * r -- * INVSQRT2
        local moveBy = cc.MoveBy:create(0.3, cc.p(dx, dy))
        effect:runAction(moveBy)
        self:addChild(effect,-1)
        effect:setPosition(rect.width * 0.8 + 0.5 * r * v[1], rect.height * 0.5 + 0.5 * r * v[2])
    end

    -- 技能音效
    self:playSoundEffect(ANIMATE_TYPE.attack)
end

function Entity:findTarget(enemys)
    local range = self._model.detectRange
    -- TODO: 若要拓展自动战斗，得改这里
    if self._model.type == const.ENTITY_TYPE.Hero then
        range = self.atkRange
    end
    return self._model:findTarget(enemys, range)
end

-- 设置洞察的怪物
function Entity:watchTarget(enemys)
    local target = self._model:findTarget(enemys, self.detectRange)
    self:setTarget(target)
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

-- 打招呼
function Entity:showDialog()
    if self.dialog == nil then
         -- 显示
        local msg = helper.getDisplayText(self._model:getDialog())
        if msg == nil then
            return
        end
        local fontSize = 20
        self.label = cc.Label:createWithSystemFont(msg, const.DEFAULT_FONT, fontSize)

        local rect = self:getTextureRect()
        self.label:setPosition(24, 5)
        self.label:setAnchorPoint(cc.p(0, 0))
        self.label:setColor(cc.c3b(0,0,0))
        self.label:setWidth(fontSize * 7)
        -- self.label:enableGlow(cc.c4b(0,0,255,255))

        local labelBox = self.label:getBoundingBox()
        self.dialog = ccui.Scale9Sprite:create(cc.rect(33,37.5,77,24), "conversationUI.png")
        self.dialog:setAnchorPoint(cc.p(0,0))
        self.dialog:setPreferredSize(cc.size(labelBox.width + 32, labelBox.height + 15))
        self.dialog:setPosition(const.TILESIZE, const.TILESIZE)

        self.dialog:addChild(self.label)
        -- 字体缩放回去，不然太难看
        self.dialog:setScale(1.0 / self:getScale())
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
        if self.runDirs == 4 then
            return const.FullToDiagDir[dir]
        else
            return dir
        end
    elseif anim_type == ANIMATE_TYPE.idle then
        if self.standDirs == 4 then
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

function Entity:getMeetConversationID()
    return self._model.meetConversationID
end

function Entity:getDieConversationID()
    return self._model.dieConversationID
end

function Entity:init(data)
    self._model = data
    self.roleID = data.roleID
    self.dir = data.dir
    self.status = Status.idle

    -- TODO: 这里应该缩放资源的...但积重难返了
    self:setScale(0.8)

    local pos = self._model.pos
    self:setPosition(pos.x, pos.y)
    
    self.aiComp = nil
    self.dialogComp = nil

    -- 初始化动画相关资源
    self:_initAnimData(data)

    self:setStandDirection(self.dir)

    self:setStatus(Status.idle)

    self:setAnchorPoint(cc.p(0.5, 0.25))

    -- 警戒范围
    self.drawNode = nil
    self.showDetectRange = false

    self.targetEntity = nil

    self:_initSoundEffect()
end

function Entity:_initSoundEffect()
    if self._model.soundID == nil then
        return
    end

    local soundData = require "data.soundData"
    local data = soundData[self._model.soundID]

    local audioEngine = cc.SimpleAudioEngine:getInstance()
    if data.attack ~= nil then
        self.atkEffectPath = const.EFFECT_ROOT .. data.attack .. const.EFFECT_POSIX
        audioEngine:preloadEffect(self.atkEffectPath)
    end

    if data.hurt ~= nil then
        self.hurtEffectPath = const.EFFECT_ROOT .. data.hurt .. const.EFFECT_POSIX
        audioEngine:preloadEffect(self.hurtEffectPath)
    end

    if data.die ~= nil then
        self.dieEffectPath = const.EFFECT_ROOT .. data.die .. const.EFFECT_POSIX
        audioEngine:preloadEffect(self.dieEffectPath)
    end
end

function Entity:_initAnimData(data)
    self.runActionTag = 10
    self.idleScheduleID = nil

    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames(self._model.texturePath)

    if self._model.type ~= const.ENTITY_TYPE.NPC then
        local runAnimData = flashData[tonumber(self.roleID .. ANIMATE_TYPE.run)]
        self.runDirs = runAnimData.direction
        self.runAnimationFrames = self:createAnimationFrames(runAnimData.direction, self.roleID .. ANIMATE_TYPE.run, runAnimData.count)

        local attackAnimData = flashData[tonumber(self.roleID .. ANIMATE_TYPE.attack)]
        self.attackAnimationFrames = self:createAnimationFrames(attackAnimData.direction, self.roleID .. ANIMATE_TYPE.attack, attackAnimData.count)

        local hitAnimData = flashData[tonumber(self.roleID .. ANIMATE_TYPE.hurt)]
        self.hitAnimationFrames = self:createAnimationFrames(hitAnimData.direction, self.roleID .. ANIMATE_TYPE.hurt, hitAnimData.count)

        local dyingAnimData = flashData[tonumber(self.roleID .. ANIMATE_TYPE.die)]
        self.dyingAnimationFrames = self:createAnimationFrames(dyingAnimData.direction, self.roleID .. ANIMATE_TYPE.die, dyingAnimData.count)
    end

    local idleAnimData = flashData[tonumber(self.roleID .. ANIMATE_TYPE.idle)]
    self.standDirs = idleAnimData.direction
    self.idleFrameCnt = idleAnimData.count
    self.idleAnimationFrames = self:createAnimationFrames(idleAnimData.direction, self.roleID .. ANIMATE_TYPE.idle, idleAnimData.count)

    local effectPath = data.effectPath
    self.atkEffectAnimationFrames = nil
    if effectPath ~= nil then
        spriteFrameCache:addSpriteFrames(effectPath)
        self.atkEffectAnimationFrames = self:createAnimationFrames(8, 'effect-skill1', 8)
    end
end

function Entity:getRoleID()
    return self._model.roleID
end

return Entity