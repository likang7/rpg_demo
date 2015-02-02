
GameMap = class("GameMap")

local table = table
local ipairs = ipairs
local math = math

function GameMap:create(map, width, height)
    local gameMap = GameMap.new()
    gameMap:init(map, width, height)

    return gameMap
end

function GameMap:ctor()
end

function GameMap:init(map, width, height)
    self.map = map
    self.width = width
    self.height = height
end

function GameMap:pushOpenList(openList, step)
    local curScore = step.score
    local idx = 0
    for idx, node in ipairs(openList) do
        if curScore >= node.score then
            table.insert(openList, idx, step)
            return
        end
    end
    table.insert(openList, step)
end

function GameMap:indexOfList(list, x, y)
    for idx, node in ipairs(list) do
        if node.x == x and node.y == y then
            return idx
        end
    end
    return -1
end

function GameMap:pathTo(from, to, maxd)
    if maxd == nil then
        maxd = 10 * 26 * 17
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
        return 10 * (math.abs(to.x - x) + math.abs(to.y - y))
    end

    local function Node(x, y, parent)
        local gscore = gScore(x, y, parent)
        local hscore = hScore(x, y, to)
        local score = gscore + hscore
        return {["x"]=x, ["y"]=y, ["parent"]=parent, ["gscore"]=gscore,
                ["hscore"]=hscore, ["score"]=score}
    end

    local openList = {}
    local closeList = {}
    local flag = false

    local step = Node(from.x, from.y, nil)
    self:pushOpenList(openList, step)

    -- 存储以便不能到达时去最近的点
    local min_score = step.hscore
    local min_step = step
    local directions = {{-1,-1}, {-1,0}, {-1,1}, {0,-1}, {0,1}, {1,-1}, {1,0}, {1,1}}
    while openList[1] ~= nil do
        local step = table.remove(openList)
        -- closeList[step.x * self.width + step.y] = true
        table.insert(closeList, step)

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
            if tx < 0 or tx >= self.width or ty < 0 or ty >= self.height or 
                self.map[tx][ty] ~= 0 or 
                -- closeList[tx * self.width + step.y] == true then
                self:indexOfList(closeList, tx, ty) ~= -1 then
                -- continue
            else
                local new_step = Node(tx, ty, step)
                local idx = self:indexOfList(openList, tx, ty)
                if new_step.score >= maxd then
                    --continue
                elseif idx == -1 then
                    self:pushOpenList(openList, new_step)
                elseif new_step.score < openList[idx].score then
                    table.remove(openList, idx)
                    self:pushOpenList(openList, new_step)
                end
            end
        end -- for end
    end -- while end

    if flag == false then
        return self:pathTo(from, cc.p(min_step.x, min_step.y), maxd)
    end

    local paths = {}
    step = min_step
    while not (step.x == from.x and step.y == from.y) do
        table.insert(paths, {x=step.x, y=step.y})
        step = step.parent
    end

    local function reverse(t)
        local len = #t+1
        for i=1, (len-1)/2 do
            t[i], t[len-i] = t[len-i], t[i]
        end
    end

    reverse(paths)

    --debug
    -- print(from.x, from.y)
    -- for _, node in ipairs(paths) do
    --     print(node.x, node.y)
    -- end

    return paths, flag
end

