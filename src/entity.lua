require "const"
local helper = require "utils.helper"

local Direction = Direction
local DiagDirection = DiagDirection
local math = math
local Status = Status

Entity = class("Entity",
    function()
        return cc.Sprite:create()  
    end
)

Entity.__index = Entity

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

function Entity:createRunAnimationFrames()
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	-- local animationCache = cc.AnimationCache:getInstance()
    runAnimationFrames = {}
    for _, dir in pairs(Direction) do
        local frames = {}
        for i = 0, 7 do
            table.insert(frames, spriteFrameCache:getSpriteFrame(self.name .. string.format("-run-%d%d.tga", dir, i)))
        end
        -- local runAnimation = cc.Animation:createWithSpriteFrames(frames, delay)
        -- animationCache:addAnimation(runAnimation, self:getRunAnimationName(dir))
        runAnimationFrames[dir] = frames
    end

    return runAnimationFrames
end

function Entity:createAttackAnimationFrames()
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    -- local animationCache = cc.AnimationCache:getInstance()
    local attackAnimationFrames = {}
    for _, dir in pairs(Direction) do
        local frames = {}
        for i = 0, 7 do
            table.insert(frames, spriteFrameCache:getSpriteFrame(self.name .. string.format("-stand-%d%d.tga", dir, i)))
        end
        -- local runAnimation = cc.Animation:createWithSpriteFrames(frames, delay)
        -- animationCache:addAnimation(runAnimation, self:getRunAnimationName(dir))
        attackAnimationFrames[dir] = frames
    end

    return attackAnimationFrames
end

function Entity:createHitAnimationFrames()
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    local frames = {}
    for _, dir in pairs(DiagDirection) do
        frames[dir] = {}
        for i = 0, 1 do 
            table.insert(frames[dir], spriteFrameCache:getSpriteFrame("bgj" .. string.format("-hit-%d%d.tga", dir, i)))
        end
    end
    return frames
end

function Entity:createHitEffectAnimationFrames()
end

function Entity:createDyingAnimationFrames()
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    local frames = {}
    for _, dir in pairs(DiagDirection) do
        frames[dir] = {}
        for i = 0, 9 do 
            table.insert(frames[dir], spriteFrameCache:getSpriteFrame("bgj" .. string.format("-die-%d%d.tga", dir, i)))
        end
    end
    return frames
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
    self.status = Status.idle
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

    self.status = Status.run
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
        self.status = Status.idle
    end
    
    self:runPath({p}, cb_end, dir)
end

function Entity:releaseCache()
	-- local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	-- spriteFrameCache:removeSpriteFramesFromFile(self.texturePlist)

	-- for _, dir in pairs(Direction) do
 --        animationCache:removeAnimation(self:getRunAnimationName(dir))
 --    end
end

function Entity:tryAttack()
    if self.status == Status.attack then
        return false
    end

	self:stopRuning()
    self.status = Status.attack
	local animate = cc.Animate:create(cc.Animation:createWithSpriteFrames(self.attackAnimationFrames[self.dir], self.runAnimDelay / 2))
	local cb = function ()
        self.status = Status.idle
	end
	local callFunc = cc.CallFunc:create(cb)
	local seq = cc.Sequence:create(animate, callFunc)
	self:runAction(seq)

    return true
end

function Entity:onHurt(atk)
    -- self:stopRuning()
    self.status = Status.attack
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

    -- 死亡
    if self.hp <= 0 then
        local animate = cc.Animate:create(cc.Animation:createWithSpriteFrames(self.dyingAnimationFrames[FullToDiagDir[self.dir]], self.runAnimDelay))
        -- local animate = cc.Animate:create(cc.Animation:createWithSpriteFrames(self.attackAnimationFrames[self.dir], self.runAnimDelay))
        local cb = function ()
            self.status = Status.die
            self:removeFromParent(true)
        end
        local callFunc = cc.CallFunc:create(cb)
        local seq = cc.Sequence:create(animate, callFunc)
        self:runAction(seq)
    else
        local animate = cc.Animate:create(cc.Animation:createWithSpriteFrames(self.hitAnimationFrames[FullToDiagDir[self.dir]], self.runAnimDelay * 2))
        -- local animate = cc.Animate:create(cc.Animation:createWithSpriteFrames(self.attackAnimationFrames[self.dir], self.runAnimDelay))
        local cb = function ()
            self.status = Status.idle
            self:setStandDirection(self.dir)
        end
        local callFunc = cc.CallFunc:create(cb)
        local seq = cc.Sequence:create(animate, callFunc)
        self:runAction(seq)
    end
end

function Entity:init(name, camp)
	self.name = name
	self.speed = 200
	self.dir = Direction.S
	self.runAnimDelay = 0.1
	self.runActionTag = 10
	self.runAnimateTag = 11
	self.texturePlist = self.name .. ".plist"
    self.status = Status.idle
    self.camp = camp
    self.atk = 100
    self.def = 10
    self.hp = 300
    print('atk', self.atk)

	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	spriteFrameCache:addSpriteFrames(self.texturePlist)

	self.runAnimationFrames = self:createRunAnimationFrames()

	self.attackAnimationFrames = self:createAttackAnimationFrames()

    self.hitAnimationFrames = self:createHitAnimationFrames()

    self.dyingAnimationFrames = self:createDyingAnimationFrames()

	self:setStandDirection(Direction.S)

	self:setAnchorPoint(cc.p(0.5, 0))

	self:registerScriptHandler(onNodeEvent)
end

return Entity