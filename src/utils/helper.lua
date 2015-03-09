local math = math
local const = require "const"
local Direction = const.Direction

local function isPointInCircularSector(cx, cy, ux, uy, px, py, rSQ, cosTheta)
    local dx, dy = px - cx, py - cy
    local disSQ = dx * dx + dy * dy
    if disSQ > rSQ then
        return false
    else
        local dis = math.sqrt(disSQ)
        return dx * ux + dy * uy > dis * cosTheta;
    end
end

local function calDegreeToSouth(p)
    local h = p.y
    local w = p.x

    if w == 0 and h == 0 then
        return 0
    end

    local deg = math.deg(math.atan2(math.abs(h), math.abs(w)))

    if w >= 0 and h >= 0 then
        deg = 270 - deg
    elseif w <= 0 and h >= 0 then
        deg = 90 + deg
    elseif w <= 0 and h <= 0 then
        deg = 90 - deg
    else
        deg = 270 + deg
    end

    -- the same but cannot avoid sqrt
    -- local theta = math.deg(math.acos(-h / math.sqrt(h*h+w*w)))
    -- if w > 0 then
    --     theta = 360 - theta 
    -- end

    return (deg + 360) % 360
end

local function getDirectionByDegree(deg)
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

local function getDirection(p1, p2)
    local deg = calDegreeToSouth(cc.pSub(p2, p1))
    return getDirectionByDegree(deg)
end

local function getItemInfoByItemId(itemId)
    local data = require("data.itemData")
    return data[itemId]
end

local function getRewardInfoByItemInfo(itemInfo)
    s = ""
    if itemInfo['function'] == const.ITEM_TYPE.Special then
        s = itemInfo.name
    elseif itemInfo.attack ~= nil then
        s = "攻击力+" .. itemInfo.attack
    elseif itemInfo.defense ~= nil then
        s = "防御力+" .. itemInfo.defense
    elseif itemInfo.hp ~= nil then
        s = "HP+" .. itemInfo.hp
    elseif itemInfo.critical ~= nil then
        s = "暴击率+" .. itemInfo.critical .. "%"
    elseif itemInfo.block ~= nil then
        s = "防暴击率+" .. itemInfo.block .. "%"
    elseif itemInfo.coin ~= nil then
        s = "金币+" .. itemInfo.coin
    end
    return s
end

local function jumpMsg(parent, msg, color, pos, fontSize)
    local label = cc.Label:createWithSystemFont(msg, const.DEFAULT_FONT, fontSize)
    label:enableShadow()
    label:setPosition(pos)
    label:setColor(color)
    local moveup = cc.MoveBy:create(0.6, cc.p(0, 100))
    local scaleBy = cc.ScaleBy:create(0.3, 1.5)
    local scaleBack = scaleBy:reverse()
    local spawn = cc.Spawn:create(moveup, cc.Sequence:create(scaleBy, scaleBack))
    local callFunc = cc.CallFunc:create(function ()
        label:removeFromParent(true)
    end)
    parent:addChild(label, const.DISPLAY_PRIORITY.JumpWord)
    local seq = cc.Sequence:create(spawn, callFunc)
    label:runAction(seq)
end

local function createHintMsgAction(target)
    local delay = cc.DelayTime:create(1)
    local fadeOut = cc.FadeOut:create(1)
    local callback = cc.CallFunc:create(function ()
        target:setVisible(false)
    end)
    local seq = cc.Sequence:create(delay, fadeOut, callback)

    return seq
end

local function getDisplayText(s)
    local new_str = string.gsub(s, '#r', '\n')
    return new_str
end

return {
	isPointInCircularSector = isPointInCircularSector,
	getDirection = getDirection,
    getItemInfoByItemId = getItemInfoByItemId,
    getRewardInfoByItemInfo = getRewardInfoByItemInfo,
    jumpMsg = jumpMsg,
    createHintMsgAction = createHintMsgAction,
    getDisplayText = getDisplayText,
}