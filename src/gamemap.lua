local pf = require("utils.pathfinding")

GameMap = class("GameMap")

function GameMap:create(tilemapPath)
    local gameMap = GameMap.new()
    gameMap:init(tilemapPath)

    return gameMap
end

function GameMap:ctor()
end

function GameMap:init(tilemapPath)
    self.tilemap = ccexp.TMXTiledMap:create(tilemapPath)
    self.mapSize = self.tilemap:getMapSize()
    self.tileSize = self.tilemap:getTileSize()

    local blockLayer = self.tilemap:getLayer("block")
    blockLayer:setVisible(false)

    local skyLayer = self.tilemap:getLayer("sky")
    -- tilemap:removeChild(skyLayer)
    -- self:addChild(skyLayer, 10)
    -- skyLayer:setPosition(origin.x, origin.y)
    skyLayer:setVisible(false)

    self.skyLayer = skyLayer

    self.map = {}
    for x = 0, self.mapSize.width - 1 do
        self.map[x] = {}
        for y = 0, self.mapSize.height - 1 do
            local gid = blockLayer:getTileGIDAt(cc.p(x, y))
            self.map[x][y] = gid
        end
    end

    self.map_w = self.mapSize.width * self.tileSize.width
    self.map_h = self.mapSize.height * self.tileSize.height
end

function GameMap:isAvailable(tx, ty)
    return not(tx < 0 or tx >= self.mapSize.width or ty < 0 or 
            ty >= self.mapSize.height or self.map[tx][ty] ~= 0)
end

function GameMap:convertToTiledSpace(x, y)
    -- print('origin', x, y)
    local tx = math.floor(x / self.tileSize.width)
    local ty = math.ceil((self.map_h - y) / self.tileSize.height)
    -- print('convert to', tx, ty)
    return tx, ty
end

function GameMap:reverseTiledSpace(x, y)
    x = (x + 0.5) * self.tileSize.width
    y = self.map_h - y * self.tileSize.height
    return x, y
end

function GameMap:clampEntityPos(x, y)
    local px = cc.clampf(x, self.tileSize.width / 2, 
        self.map_w - self.tileSize.width / 2)
    local py = cc.clampf(y, self.tileSize.height / 2, 
        self.map_h - self.tileSize.height / 2)

    return px, py
end

-- A star
-- TODO: 调用C++用优先队列来实现
function GameMap:pathTo(from, to, maxd)
    from.x, from.y = self:convertToTiledSpace(from.x, from.y)
    to = cc.p(self:convertToTiledSpace(to.x, to.y))
    path = pf.pathTo(from, to, maxd, self.map, self.mapSize.width, self.mapSize.height)
    for i, step in ipairs(path) do
        step.x, step.y = self:reverseTiledSpace(step.x, step.y)
    end
    return path
end

function GameMap:pathToArround(from, to, maxd)
    from.x, from.y = self:convertToTiledSpace(from.x, from.y)
    to = cc.p(self:convertToTiledSpace(to.x, to.y))
    path = pf.pathTo(from, to, maxd, self.map, self.mapSize.width, self.mapSize.height)
    table.remove(path)
    for i, step in ipairs(path) do
        step.x, step.y = self:reverseTiledSpace(step.x, step.y)
    end
    return path
end

