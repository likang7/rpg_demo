require "const"

local Direction = Direction
local math = math

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

	
	print('self.runAnimationFrames', sprite.runAnimations)
	print('self.standFrames', sprite.standFrames)
	print('self.name', sprite.name)
	return sprite
end

function Entity:ctor()
end

function Entity:getRunAnimationName(dir)
	return self.name .. string.format('-run-%d', dir)
end

function Entity:createRunAnimationFrames(delay)
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	local animationCache = cc.AnimationCache:getInstance()
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

function Entity:setStandDirection(dir)
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	local frame = spriteFrameCache:getSpriteFrame(string.format("bgj-stand-%d0.tga", dir))
	self:setSpriteFrame(frame)
end

function Entity:calDegree(p1, p2)
    local h = p2.y - p1.y
    local w = p2.x - p1.x
    if w == 0 then
        if h ~= 0 then
            return h/math.abs(h) * 180
        else
            return 0
        end
    end

    local deg = math.deg(math.atan(math.abs(h/w)))

    if w >= 0 and h >= 0 then
        deg = 270 - deg
    elseif w <= 0 and h >= 0 then
        deg = 90 + deg
    elseif w <= 0 and h <= 0 then
        deg = 90 - deg
    else
        deg = 270 + deg
    end
    return (deg + 360) % 360
end

function Entity:getDirectionByDegree(deg)
    local dir = nil

    if deg >= 22.5 and deg < 67.5 then
        dir = Direction.WS
    elseif deg >= 67.5 and deg < 112.5 then
        dir = Direction.W
    elseif deg >= 112.5 and deg < 157.5 then
        dir = Direction.NW
    elseif deg >= 157.5 and deg < 202.5 then
        dir = Direction.N
    elseif deg >= 202.5 and deg < 247.5 then
        dir = Direction.NE
    elseif deg >= 247.5 and deg < 292.5 then
        dir = Direction.E
    elseif deg >= 292.5 and deg < 337.5 then
        dir = Direction.ES
    else
        dir = Direction.S
    end

    return dir
end

function Entity:getDirection(p1, p2)
    local deg = self:calDegree(p1, p2)
    return self:getDirectionByDegree(deg)
end

function Entity:stopRuning()
	self:stopActionByTag(self.runActionTag)
	self:stopActionByTag(self.runAnimateTag)
    self:setStandDirection(self.dir)
end

function Entity:runTo(dest)
	local playerPos = cc.p(self:getPosition())
	local dir = self:getDirection(playerPos, dest)

	local distance = cc.pDistanceSQ(playerPos, dest) ^ 0.5
	local moveTo = cc.MoveTo:create(distance/self.speed, dest)

    local cb = cc.CallFunc:create(function () self:stopRuning() end)
    local seq = cc.Sequence:create(moveTo, cb)
    seq:setTag(self.runActionTag)

    -- 平滑处理一下，避免走同一个方向时有卡住的感觉
    if dir ~= self.dir or self:getActionByTag(self.runAnimateTag) == nil then
        self:stopRuning()
        local repeatForever = cc.RepeatForever:create(
        	cc.Animate:create(cc.Animation:createWithSpriteFrames(self.runAnimationFrames[dir], self.runAnimDelay)))
        repeatForever:setTag(self.runAnimateTag)
        self:runAction(repeatForever)
    else
        self:stopActionByTag(self.runActionTag)
    end
    
    self:runAction(seq)
    self.dir = dir
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
        dir = self:getDirection(playerPos, path[idx])
    end

    -- 同一方向的弄在同一个action里走
    local end_idx = idx + 1
    while path[end_idx] ~= nil do
        local next_dir = self:getDirection(path[end_idx - 1], path[end_idx])
        if next_dir ~= dir then
            break
        end
        end_idx = end_idx + 1
    end
    idx = end_idx - 1

    -- 移动精灵，并递归走剩下的路径
    local distance = cc.pDistanceSQ(playerPos, path[idx]) ^ 0.5
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

	self:_run(path, 1, cb_end, dir)
end

function Entity:runOneStep(p, cb, dir)
    if self.oneStepLock == true then
        return 
    end

    local cb_end = function ()
        if cb ~= nil then
            cb()
        end
        self.oneStepLock = false
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

function Entity:init(name)
	print('xx',self.name)
	self.name = name
	self.speed = 200
	self.dir = Direction.S
	self.runAnimDelay = 0.1
	self.runActionTag = 10
	self.runAnimateTag = 11
	self.texturePlist = self.name .. ".plist"
    self.oneStepLock = false

	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	spriteFrameCache:addSpriteFrames(self.texturePlist)

	self.runAnimationFrames = self:createRunAnimationFrames()

	self:setStandDirection(Direction.S)

	self:setAnchorPoint(cc.p(0.5, 0))

	self:registerScriptHandler(onNodeEvent)
end

return Entity