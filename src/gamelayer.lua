require "const"
require "entity"

local Direction = Direction
local math = math
local ipairs = ipairs

GameLayer = class("GameLayer",
    function()
        return cc.Layer:create()  
    end
)

GameLayer.__index = GameScene

function GameLayer:createGameLayer()
	
end

function GameLayer:create()
	local scene = GameLayer.new()
	scene:init()

	return scene
end

function GameLayer:initEntity(objects)
	local playerPoint = objects:getObject("bornPoint")
	local x, y = playerPoint["x"], playerPoint["y"]
	local player = Entity:create('bgj')
	player:setPosition(x, y)
	self.player = player
	self:addChild(player)

	self:setViewPointCenter(x, y)
end

function GameLayer:initTileMap(tilemapPath)
	local origin = cc.Director:getInstance():getVisibleOrigin()

	local tilemap = ccexp.TMXTiledMap:create(tilemapPath)
    self.tilemap = tilemap
    tilemap:setPosition(origin.x, origin.y)
    -- self:addChild(tilemap)

    self.mapSize = tilemap:getMapSize()
    self.tileSize = tilemap:getTileSize()
    
    blockLayer = tilemap:getLayer("block")
    -- blockLayer:setVisible(false)

    local block = {}
    for x = 0, self.mapSize.width - 1 do
    	block[x] = {}
    	for y = 0, self.mapSize.height - 1 do
    		local gid = blockLayer:getTileGIDAt(cc.p(x, y))
    		block[x][y] = gid
    	end
    end

    require "model.gamemap"
    self.gameMap = GameMap:create(block, self.mapSize.width, self.mapSize.height)

    self.map_w = self.mapSize.width * self.tileSize.width
    self.map_h = self.mapSize.height * self.tileSize.height

    local objects = tilemap:getObjectGroup("object")
    self:initEntity(objects)
end

function GameLayer:init()
	self.sceneTexturePath = "scene.jpg"
	self.tilemapPath = "sample.tmx"

    local origin = cc.Director:getInstance():getVisibleOrigin()

    self:initTileMap(self.tilemapPath)

    -- add bg
    local bg = cc.Sprite:create(self.sceneTexturePath)
    bg:setAnchorPoint(0, 0)
    -- 高度补偿
    bg:setPosition(origin.x, origin.y + self.map_h - bg:getTextureRect().height)
    self:addChild(bg, -1)

    local last_dir = Direction.S
    local function tick()
        local px, py = self.player:getPosition()
        self:setViewPointCenter(px, py)      
    end

    local schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)
    local function onNodeEvent(event)
       if "exit" == event then
           cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)
       end
    end
    self:registerScriptHandler(onNodeEvent)

    self:initTouchEvent()

    self:initKeyboardEvent()
end

function GameLayer:initTouchEvent()
    -- handing touch events
    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local location = touch:getLocation()
        location = self:convertToNodeSpace(location)

        local tox, toy = self:clampEntityPos(location.x, location.y)

        local px, py = self.player:getPosition()

        local path = self.gameMap:pathTo(cc.p(self:convertToTiledSpace(px, py)), cc.p(self:convertToTiledSpace(tox, toy)))
        for i, step in ipairs(path) do
            step.x, step.y = self:reverseTiledSpace(step.x, step.y)
        end
        self.player:runPath(path)
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function GameLayer:initKeyboardEvent()
    local KEYW, KEYA, KEYS, KEYD = 1, 2, 4, 8

    local function getDirection(keysum)
        if keysum == KEYW then
            return Direction.N
        elseif keysum == KEYA then
            return Direction.W
        elseif keysum == KEYS then
            return Direction.S
        elseif keysum == KEYD then
            return Direction.E
        elseif keysum == KEYW + KEYA then
            return Direction.NW
        elseif keysum == KEYW + KEYD then
            return Direction.NE
        elseif keysum == KEYS + KEYA then
            return Direction.WS
        elseif keysum == KEYS + KEYD then
            return Direction.ES
        else
            return nil
        end
    end

    local function moveOneStep()
        local dir = getDirection(self.pressSum)
        local d = {[Direction.S]={0, 1}, [Direction.WS]={-1, 1}, 
                    [Direction.W]={-1, 0}, [Direction.NW]={-1, -1}, 
                    [Direction.N]={0, -1}, [Direction.NE]={1, -1}, 
                    [Direction.E]={1, 0}, [Direction.ES]={1, 1}}
        if dir ~= nil and d[dir] ~= nil then
            local px, py = self.player:getPosition()
            px, py = self:convertToTiledSpace(px, py)
            local delta = d[dir]
            local new_x, new_y = px + delta[1], py + delta[2]
            if self.gameMap:isAvailable(new_x, new_y) then
                px, py = new_x, new_y
            end
            px, py = self:reverseTiledSpace(px, py)
            px, py = self:clampEntityPos(px, py)
        
            self.player:runOneStep(cc.p(px, py), moveOneStep, dir)
        else
            self.player:stopRuning()
        end
    end

    local function onKeyPressed(keyCode, event)
        -- TOFIX: 这里要偏移3才对的上，Lua的Bug?
        keyCode = keyCode - 3
        -- cclog(string.format("Key with keycode %d pressed", keyCode))
        if keyCode == cc.KeyCode.KEY_W or keyCode == cc.KeyCode.KEY_CAPITAL_W then
            self.pressSum = self.pressSum + KEYW
        elseif keyCode == cc.KeyCode.KEY_A or keyCode == cc.KeyCode.KEY_CAPITAL_A then
            self.pressSum = self.pressSum + KEYA
        elseif keyCode == cc.KeyCode.KEY_S or keyCode == cc.KeyCode.KEY_CAPITAL_S then
            self.pressSum = self.pressSum + KEYS
        elseif keyCode == cc.KeyCode.KEY_D or keyCode == cc.KeyCode.KEY_CAPITAL_D then
            self.pressSum = self.pressSum + KEYD
        end
        moveOneStep()
    end

    local function onKeyReleased(keyCode, event)
        keyCode = keyCode - 3
        -- cclog(string.format("Key with keycode %d released", keyCode))
        if keyCode == cc.KeyCode.KEY_W or keyCode == cc.KeyCode.KEY_CAPITAL_W then
            self.pressSum = self.pressSum - KEYW
        elseif keyCode == cc.KeyCode.KEY_A or keyCode == cc.KeyCode.KEY_CAPITAL_A then
            self.pressSum = self.pressSum - KEYA
        elseif keyCode == cc.KeyCode.KEY_S or keyCode == cc.KeyCode.KEY_CAPITAL_S then
            self.pressSum = self.pressSum - KEYS
        elseif keyCode == cc.KeyCode.KEY_D or keyCode == cc.KeyCode.KEY_CAPITAL_D then
            self.pressSum = self.pressSum - KEYD
        end
        moveOneStep()
    end

    self.pressSum = 0

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function GameLayer:setViewPointCenter(x, y)
    local win_size = cc.Director:getInstance():getWinSize()

    local x = math.max(x, win_size.width / 2)
    local y = math.max(y, win_size.height / 2)

    newx = math.min(x, self.map_w - win_size.width / 2)
    newy = math.min(y, self.map_h - win_size.height / 2)
    
    viewx = win_size.width / 2 - newx
    viewy = win_size.height / 2 - newy

    self:setPosition(viewx, viewy)
end

function GameLayer:convertToTiledSpace(x, y)
    -- print('origin', x, y)
    local tx = math.floor(x / self.tileSize.width)
    local mapHeight = self.mapSize.height * self.tileSize.height
    local ty = math.ceil((mapHeight - y) / self.tileSize.height)
    -- print('convert to', tx, ty)
    return tx, ty
end

function GameLayer:reverseTiledSpace(x, y)
    x = (x + 0.5) * self.tileSize.width
    local mapHeight = self.mapSize.height * self.tileSize.height
    y = mapHeight - y * self.tileSize.height
    return x, y
end

function GameLayer:clampEntityPos(x, y)
    local px = math.max(self.tileSize.width / 2, 
            math.min(x, self.mapSize.width * self.tileSize.width - self.tileSize.width / 2))
    local py = math.max(self.tileSize.height / 2, 
            math.min(y, self.mapSize.height * self.tileSize.height - self.tileSize.height / 2))
    return px, py
end
