require "const"
require "entity"

local Direction = Direction
local math = math

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
    self:addChild(tilemap)

    self.mapSize = tilemap:getMapSize()
    self.tileSize = tilemap:getTileSize()
    
    self.blockLayer = tilemap:getLayer("block")
    -- blockLayer:setVisible(false)
    local block = {}
    for x = 0, self.mapSize.width - 1 do
    	block[x] = {}
    	for y = 0, self.mapSize.height - 1 do
    		local gid = self.blockLayer:getTileGIDAt(cc.p(x, y))
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

    local player = self.player

    -- add bg
    local bg = cc.Sprite:create(self.sceneTexturePath)
    bg:setAnchorPoint(0, 0)
    -- 高度补偿
    bg:setPosition(origin.x, origin.y + self.map_h - bg:getTextureRect().height)
    self:addChild(bg, -1)

    local last_dir = Direction.S
    local function tick()
        local px, py = player:getPosition()
        self:setViewPointCenter(px, py)      
    end

    local schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)

    -- handing touch events
    local function onTouchBegan(touch, event)
        -- local location = touch:getLocation()
        -- cclog("onTouchBegan: %0.2f, %0.2f", location.x, location.y)
        -- CCTOUCHBEGAN event must return true
        return true
    end

    local function onTouchEnded(touch, event)
        local location = touch:getLocation()
        -- cclog("onTouchEnded: %0.2f, %0.2f", location.x, location.y)
        location = self:convertToNodeSpace(location)

        local px = math.max(self.tileSize.width / 2, 
            math.min(location.x, self.mapSize.width * self.tileSize.width - self.tileSize.width / 2))
        local py = math.max(self.tileSize.height / 2, 
            math.min(location.y, self.mapSize.height * self.tileSize.height - self.tileSize.height / 2))

        -- player:runTo(cc.p(px, py))

        x, y = player:getPosition()
        local path = self.gameMap:pathTo(cc.p(self:convertToTiledSpace(x, y)), cc.p(self:convertToTiledSpace(px, py)))
        for i, step in ipairs(path) do
        	step.x = (step.x + 0.5) * self.tileSize.width
        	local mapHeight = self.tilemap:getMapSize().height * self.tileSize.height
        	step.y = mapHeight - step.y * self.tileSize.height
        end
        player:runPath(path)
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    local function onNodeEvent(event)
       if "exit" == event then
           cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)
       end
    end
    self:registerScriptHandler(onNodeEvent)
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
    local mapHeight = self.tilemap:getMapSize().height * self.tileSize.height
    local ty = math.ceil((mapHeight - y) / self.tileSize.height)
    -- print('convert to', tx, ty)
    return tx, ty
end
