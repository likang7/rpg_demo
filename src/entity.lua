require "const"
local helper = require "utils.helper"

local Direction = Direction
local DiagDirection = DiagDirection
local DirectionToVec = DirectionToVec
local math = math
local Status = Status

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
		print("xxx")
		-- self.runAnimationFrames:release()
	end
end

function Entity:create(name)
	local sprite = Entity.new()
	sprite:init(name)

	print('self.name', sprite.name)
	return sprite
end

function Entity:ctor()
end

function Entity:getRunAnimationName(dir)
	return self.name .. string.format('-run-%d', dir)
end

function Entity:createHitEffectAnimationFrames()
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
        dir = FullToDiagDir[self.dir]
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
	self:stopActionByTag(self.runActionTag)
	self:stopActionByTag(self.runAnimateTag)
    self:setStandDirection(self.dir)
    self:setStatus(Status.idle)
end

function Entity:_run(path, idx, cb_end, dir)
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
	self:stopActionByTag(self.runActionTag)	

    self:setStatus(Status.run)
	self:_run(path, 1, cb_end, dir)
end

function Entity:runOneStep(p, cb, dir)
    if self.status ~= Status.idle then
        return
    end

    local cb_end = function ()
        if cb ~= nil then
            cb()
        end
        self:setStatus(Status.idle)
    end
    
    self:runPath({p}, cb_end, dir)
end

function Entity:releaseCache()
end

function Entity:tryAttack()
    if self.status == Status.attack then
        return false
    end

	self:stopRuning()
    self:setStatus(Status.attack)
	local cb = function ()
        self:setStandDirection(self.dir)
        self:setStatus(Status.idle)
	end

    self:playAnimation(self.attackAnimationFrames, cb, false, self.runAnimDelay * 0.5)

    --技能特效
    local rect = self:getTextureRect()
    local effect = cc.Sprite:create()
    local cb = function ()
        effect:removeFromParent(true)
    end
    self:playAnimation(self.atkEffectAnimationFrames, cb, true, self.runAnimDelay * 0.5, effect)
    local v = DirectionToVec[self.dir]
    local r = 32
    local dx, dy = v[1] * r, v[2] * r
    local moveBy = cc.MoveBy:create(0.3, cc.p(dx, dy))
    effect:runAction(moveBy)
    self:addChild(effect,-1)
    effect:setPosition(rect.width * 0.8 + 0.5 * r * v[1], rect.height * 0.5 + 0.5 * r * v[2])
    return true
end

function Entity:setStatus(status)
    if status == Status.idle then
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

function Entity:onHurt(atk)
    -- self:stopRuning()
    self:setStatus(Status.hurt)
    local nhurt = atk - self.def
    self.hp = self.hp - nhurt
    
    -- 飘血
    local bloodLabel = cc.Label:createWithSystemFont(tostring(nhurt), "fonts/Marker Felt.ttf", 24)
    self:getParent():addChild(bloodLabel, 10)
    local rect = self:getTextureRect()
    bloodLabel:setPosition(self:getPositionX(), self:getPositionY() + rect.height)
    bloodLabel:setColor(cc.c3b(255, 0, 0))
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
    if self.hp <= 0 then
        local cb = function ()
            self:removeFromParent(true)
        end
        self:setStatus(Status.die)
        self:playAnimation(self.dyingAnimationFrames, cb, false, self.runAnimDelay)
    else
        local cb = function ()
            if self.status == Status.hurt then
                self:setStatus(Status.idle)
                self:setStandDirection(self.dir)
            end
        end
        self:playAnimation(self.hitAnimationFrames, cb, false, self.runAnimDelay)
    end
end

function Entity:init(name, camp)
	self.name = name
	self.speed = 200
	self.dir = Direction.S
	self.runAnimDelay = 0.1
	self.runActionTag = 10
	self.runAnimateTag = 11
    self.idleActionTag = 12
    self.idleScheduleID = nil
	self.texturePlist = self.name .. ".plist"
    self.status = Status.idle
    self.camp = camp
    self.atk = 100
    self.def = 10
    self.hp = 300
    print('atk', self.atk)

	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	spriteFrameCache:addSpriteFrames(self.texturePlist)
    local effectPath = 'effect.plist'
    spriteFrameCache:addSpriteFrames(effectPath)

	self.runAnimationFrames = self:createAnimationFrames(true, self.name, 'run', 8)

	self.attackAnimationFrames = self:createAnimationFrames(false, self.name, 'skill1', 16)

    self.hitAnimationFrames = self:createAnimationFrames(false, self.name, 'hit', 2)

    self.dyingAnimationFrames = self:createAnimationFrames(false, self.name, 'die', 10)

    self.idleAnimationFrames = self:createAnimationFrames(true, self.name, 'stand', 8)

    self.atkEffectAnimationFrames = self:createAnimationFrames(true, 'effect', 'skill1', 8)

	self:setStandDirection(Direction.S)

    self:setStatus(Status.idle)

	self:setAnchorPoint(cc.p(0.5, 0))

	self:registerScriptHandler(onNodeEvent)
end

return Entity