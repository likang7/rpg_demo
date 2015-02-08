local table = table
local ipairs = ipairs
local pairs = pairs
local math = math

local _map
local _width
local _height

local function popOpenList(openList)
    local min_idx = 0
    local min_score = 0x1FFFFFFF
    for idx, node in pairs(openList) do
        if node.score < min_score then
            min_idx = idx
            min_score = node.score
        end
    end
    local step = openList[min_idx]
    openList[min_idx] = nil
    return step
end

local function isAvailable(tx, ty)
    return not(tx < 0 or tx >= _width or ty < 0 or 
            ty >= _height or _map[tx][ty] ~= 0)
end

local function reverse(t)
    local len = #t+1
    for i=1, (len-1)/2 do
        t[i], t[len-i] = t[len-i], t[i]
    end
end

local function gScore(x, y, parent)
    if parent == nil then
        return 0
    else
        x, y = parent.x - x, parent.y - y
        local d = 10
        if x ~= 0 and y ~= 0 then 
            d = 14
        end
        return parent.gscore + d
    end 
end

local function hScore(x, y, to)
    local dx, dy = math.abs(to.x - x), math.abs(to.y - y)
    return 10 * (dx + dy) + (14 - 2 * 10) * math.min(dx, dy)
end

-- A star
-- TODO: 调用C++用优先队列来实现
local function pathTo(from, to, maxd, map, width, height)
    _map = map
    _width = width
    _height = height
    
    if maxd == nil then
        maxd = 200
    end

    local function Node(x, y, parent)
        local gscore = gScore(x, y, parent)
        local hscore = hScore(x, y, to)
        local score = gscore + hscore
        return {["x"]=x, ["y"]=y, ["parent"]=parent, ["gscore"]=gscore,
                ["hscore"]=hscore, ["score"]=score}
    end

    local function hashCoord(x,  y)
        return x * height + y
    end

    local openList = {}
    local closeList = {}
    local flag = false

    local step = Node(from.x, from.y, nil)
    openList[hashCoord(step.x, step.y)] = step

    -- 存储以便不能到达时去最近的点
    local min_score = step.hscore
    local min_step = step
    local directions = {{-1,-1}, {-1,0}, {-1,1}, {0,-1}, {0,1}, {1,-1}, {1,0}, {1,1}}
    local d = 0
    while true do
        local step = popOpenList(openList)

        d = d + 1
        if step == nil or d >= maxd then
            break
        end

        closeList[hashCoord(step.x, step.y)] = true

        if step.x == to.x and step.y == to.y then
            min_step = step
            min_score = step.score
            flag = true
            break
        end

        if step.hscore < min_score then
            min_step = step
            min_score = step.hscore
        end

        for _, dir in ipairs(directions) do
            local tx = step.x + dir[1]
            local ty = step.y + dir[2]
            if isAvailable(tx, ty) == false or closeList[hashCoord(tx, ty)] == true then
                -- continue
            else
                local new_step = Node(tx, ty, step)
                local idx = hashCoord(tx, ty)
                if openList[idx] == nil or new_step.score < openList[idx].score then
                    openList[idx] = new_step
                end
            end
        end -- for end
    end -- while end

    -- 找不到时返回一个最近的
    if flag == false then
        return pathTo(from, cc.p(min_step.x, min_step.y), maxd, map, width, height)
    end

    local paths = {}
    step = min_step
    while not (step.x == from.x and step.y == from.y) do
        table.insert(paths, {x=step.x, y=step.y})
        step = step.parent
    end
    table.insert(paths, {x=from.x, y=from.y})
    reverse(paths)

    return paths, flag
end

return {
    pathTo = pathTo
}

