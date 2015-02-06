local const = require "const"
require "entity"
require "aicomp"

local Direction = const.Direction
local math = math
local ipairs = ipairs
local helper = require "utils.helper"

GameLayer = class("GameLayer",
    function()
        return cc.Layer:create()  
    end
)

GameLayer.__index = GameLayer

function GameLayer:createGameLayer()
    
end

function GameLayer:create()
    local layer = GameLayer.new()

    layer:clearAll()

    layer:init()

    return layer
end

function GameLayer:initEntity(objectGroup)
    local playerPoint = objectGroup:getObject("bornPoint")
    local x, y = playerPoint.x, playerPoint.y
    local player = Entity:create('bgj', 1)
    player:setPosition(x, y)
    self.player = player
    self:addChild(player, 5)

    self.monsterEntity = {}
    local objects = objectGroup:getObjects()
    for _, object in pairs(objects) do
        if object['name'] == 'monsterPoint' then
            local monster = Entity:create('bgj', 2)
            monster:setPosition(object.x, object.y)
            self:addChild(monster, 1)
            table.insert(self.monsterEntity, monster)

            --ai
            local dict = {
                ['entity'] = monster,
                ['gameMap'] = self.gameMap,
                ['bornPoint'] = cc.p(object.x, object.y),
                ['enemyEntity'] = {self.player},
                ['atkRange'] = 32,
                ['detectRange'] = 100,
                ['catchRange'] = 200,
            }
            local aiComp = AIComp:create(dict, true)
            monster:setAIComp(aiComp)
        end
    end

    self:setViewPointCenter(x, y)
end

function GameLayer:clearAll()
    if self.tryMoveOneStepID ~= nil then
        scheduler:unscheduleScriptEntry(self.tryMoveOneStepID)
        self.tryMoveOneStepID = nil
    end

    if self.schedulerTickID ~= nil then
        scheduler:unscheduleScriptEntry(self.schedulerTickID)
        self.schedulerTickID = nil
    end

    self.player = nil
    self.monsterEntity = {}
    self.gameMap = nil
    self.pressSum = 0

    self:removeAllChildren()
end

function GameLayer:initTileMap(tilemapPath)
    local origin = cc.Director:getInstance():getVisibleOrigin()

    require "GameMap"
    self.gameMap = GameMap:create(tilemapPath)

    local tilemap = self.gameMap.tilemap
    tilemap:setPosition(origin.x, origin.y)
    self:addChild(tilemap)

    local objects = tilemap:getObjectGroup("object")
    self:initEntity(objects)
end

function GameLayer:init()
    local sceneTexturePath = "scene.jpg"
    local tilemapPath = "sample.tmx"

    local origin = cc.Director:getInstance():getVisibleOrigin()

    self:initTileMap(tilemapPath)

    -- add bg
    local bg = cc.Sprite:create(sceneTexturePath)
    bg:setAnchorPoint(0, 0)
    -- 高度补偿
    bg:setPosition(origin.x, origin.y + self.gameMap.map_h - bg:getTextureRect().height)
    self:addChild(bg, -1)

    local last_dir = Direction.S
    local function tick()
        if self.player ~= nil and self.player.status ~= const.Status.die then
            local px, py = self.player:getPosition()
            self:setViewPointCenter(px, py)   
            local gid = self.gameMap.skyLayer:getTileGIDAt(cc.p(self.gameMap:convertToTiledSpace(px, py)))
            if gid ~= 0 then
                self.player:setOpacity(200)
            else
                self.player:setOpacity(255)
            end 
        end
    end

    local scheduler = cc.Director:getInstance():getScheduler()
    self.schedulerTickID = scheduler:scheduleScriptFunc(tick, 0, false)

    local function onNodeEvent(event)
        if "exit" == event then
           self:clearAll()
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

        local tox, toy = self.gameMap:clampEntityPos(location.x, location.y)

        local px, py = self.player:getPosition()

        local path = self.gameMap:pathTo(cc.p(px, py), cc.p(tox, toy))
        
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

    local function tryMoveOneStep()
        local dir = getDirection(self.pressSum)
        local d = const.DirectionToVec
        if dir ~= nil and d[dir] ~= nil then
            local px, py = self.player:getPosition()
            px, py = self.gameMap:convertToTiledSpace(px, py)
            local delta = d[dir]
            local new_x, new_y = px + delta[1], py - delta[2]
            if self.gameMap:isAvailable(new_x, new_y) then
                px, py = new_x, new_y
            end
            px, py = self.gameMap:reverseTiledSpace(px, py)
            px, py = self.gameMap:clampEntityPos(px, py)
        
            self.player:runOneStep(cc.p(px, py), nil, dir)
            if self.tryMoveOneStepID == nil then
                local scheduler = cc.Director:getInstance():getScheduler()
                self.tryMoveOneStepID = scheduler:scheduleScriptFunc(tryMoveOneStep, 0, false)
            end
        else
            self.player:stopRuning()
            if self.tryMoveOneStepID ~= nil then
                local scheduler = cc.Director:getInstance():getScheduler()
                scheduler:unscheduleScriptEntry(self.tryMoveOneStepID)
                self.tryMoveOneStepID = nil
            end
        end
    end

    local function onKeyPressed(keyCode, event)
        -- TOFIX: 这里要偏移3才对的上，quick Lua的Bug?
        keyCode = keyCode - 3
        cclog(string.format("Key with keycode %d pressed", keyCode))
        if keyCode == cc.KeyCode.KEY_W or keyCode == cc.KeyCode.KEY_CAPITAL_W then
            self.pressSum = self.pressSum + KEYW
        elseif keyCode == cc.KeyCode.KEY_A or keyCode == cc.KeyCode.KEY_CAPITAL_A then
            self.pressSum = self.pressSum + KEYA
        elseif keyCode == cc.KeyCode.KEY_S or keyCode == cc.KeyCode.KEY_CAPITAL_S then
            self.pressSum = self.pressSum + KEYS
        elseif keyCode == cc.KeyCode.KEY_D or keyCode == cc.KeyCode.KEY_CAPITAL_D then
            self.pressSum = self.pressSum + KEYD
        end
        tryMoveOneStep()

        if keyCode == cc.KeyCode.KEY_I or keyCode == cc.KeyCode.KEY_CAPITAL_I then
            local can_attack = self.player:tryAttack()
            if can_attack == true then
                self:attack(self.player)
            end
        end
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
        tryMoveOneStep()
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function GameLayer:attack(entity)
    local theta = 90 / 2
    local r = 64
    local rSQ = r * r
    local cosTheta = math.cos(theta)
    local ex, ey = entity:getPosition()
    local rmIdx = {}
    for idx, monster in pairs(self.monsterEntity) do
        local mx, my = monster:getPosition()
        local u = const.DirectionToVec[entity.dir]
        if helper.isPointInCircularSector(ex, ey, u[1], u[2], mx, my, rSQ, cosTheta) then
            monster:onHurt(entity.atk)
            if monster.hp == nil or monster.hp <= 0 then
                table.insert(rmIdx, idx)
            end
        end
    end

    for _, idx in ipairs(rmIdx) do
        self.monsterEntity[idx] = nil
    end
end

function GameLayer:setViewPointCenter(x, y)
    local win_size = cc.Director:getInstance():getWinSize()

    x = cc.clampf(x, win_size.width / 2, self.gameMap.map_w - win_size.width / 2)
    y = cc.clampf(y, win_size.height / 2, self.gameMap.map_h - win_size.height / 2)
    
    viewx = win_size.width / 2 - x
    viewy = win_size.height / 2 - y

    self:setPosition(viewx, viewy)
end


