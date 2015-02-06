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

return {
	isPointInCircularSector = isPointInCircularSector,
	getDirection = getDirection,
}