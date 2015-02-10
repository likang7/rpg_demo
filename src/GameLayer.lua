local const = require "const"
require "Entity"
require "model.EntityData"
require "AIComp"
require "Transfer"

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

function GameLayer:create(dict)
    local layer = GameLayer.new()

    layer:init(dict)

    return layer
end

function GameLayer:initEntity(objectGroup)
    self.monsterEntity = {}
    self.transfers = {}

    self.player = nil
    --先初始化玩家
    local object = objectGroup:getObject("bornPoint")
    local entityData = EntityData:create(1, self.gameMap)
    entityData.pos = cc.p(object.x+16, object.y)
    local player = Entity:create(entityData)
    self.player = player
    self:addChild(player, 5)

    local objects = objectGroup:getObjects()
    for _, object in pairs(objects) do
        local otype = object['type']
        if otype == '1' then
            -- 初始化传送点
            local x, y, w, h = object.x, object.y, object.width, object.height
            local dict = {rect = cc.rect(x, y, w, h), dir = object.direction}
            local transfer = Transfer:create(dict)
            table.insert(self.transfers, transfer) 
        elseif otype == '3' then
            -- 初始化NPC
            local entityData = EntityData:create(2, self.gameMap)
            entityData.pos = cc.p(object.x+16, object.y)
            local monster = Entity:create(entityData)
            self:addChild(monster, 1)
            -- table.insert(self.monsterEntity, monster)
        elseif otype == '4' then
            -- 初始化道具
        elseif otype == '5' then
            -- 初始化monster
            local entityData = EntityData:create(2, self.gameMap)
            entityData.pos = cc.p(object.x+16, object.y)
            local monster = Entity:create(entityData)
            self:addChild(monster, 1)
            table.insert(self.monsterEntity, monster)

            --ai
            local dict = {
                ['entity'] = monster,
                ['gameMap'] = self.gameMap,
                ['bornPoint'] = cc.p(object.x+16, object.y),
                ['enemyEntity'] = {self.player},
                ['atkRange'] = 64,
                ['detectRange'] = 64,
                ['catchRange'] = 64,
            }
            local aiComp = AIComp:create(dict, true)
            monster:setAIComp(aiComp)
        end
    end
end

function GameLayer:clearAll()
    local scheduler = cc.Director:getInstance():getScheduler()
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
    self.transfers = {}
    self.gameMap = nil
    if self.pressSum == nil then
        self.pressSum = 0
    end

    self:removeAllChildren()

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeAllEventListeners()

end

function GameLayer:initTileMap(tilemapPath)
    local origin = cc.Director:getInstance():getVisibleOrigin()

    require "GameMap"
    self.gameMap = GameMap:create(tilemapPath)

    local tilemap = self.gameMap.tilemap
    -- tilemap:setPosition(origin.x, origin.y)
    self:addChild(tilemap)

    local objects = tilemap:getObjectGroup("object")
    self:initEntity(objects)
end

function GameLayer:init(dict)
    self:clearAll()

    local sceneTexturePath = "scene.jpg"
    local tilemapPath = string.format("map/map-%d.tmx", dict.stageId)

    self.stageId = dict.stageId

    self:initTileMap(tilemapPath)

    -- add bg
    -- local bg = cc.Sprite:create(sceneTexturePath)
    -- bg:setAnchorPoint(0, 0)
    -- -- -- 高度补偿
    -- bg:setPosition(origin.x, origin.y + self.gameMap.map_h - bg:getTextureRect().height)
    -- self:addChild(bg, -1)

    local last_dir = Direction.S
    local function tick(dt)
        if self.player ~= nil and self.player.status ~= const.Status.die then
            self.player:step(dt)
            local px, py = self.player:getPosition()
            -- self:setViewPointCenter(px, py)   
            if self.gameMap.skyLayer ~= nil then
                local gid = self.gameMap.skyLayer:getTileGIDAt(cc.p(self.gameMap:convertToTiledSpace(px, py)))
                local tx, ty = self.gameMap:convertToTiledSpace(px, py)
                -- print('tile', tx, ty)
                if gid ~= 0 then
                    self.player:setOpacity(200)
                else
                    self.player:setOpacity(255)
                end 
            end
        end
        for _, monster in pairs(self.monsterEntity) do
            monster:step(dt)
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

function GameLayer:saveRecord()
    
end

function GameLayer:onNextStage()
    --1. 保存当前关卡记录
    self:saveRecord()
    --2. 切换到下一关
    local nextStageId = self.stageId + 1
    local dict = {stageId=nextStageId}
    self:init(dict)
    print('xxx')
end

function GameLayer:onPrevStage()
    self:saveRecord()
    local prevStageId = self.stageId - 1
    local dict = {stageId=prevStageId}
    self:init(dict)
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
        self.player:runOneStep(dir)
        if dir ~= nil and d[dir] ~= nil then
            if self.tryMoveOneStepID == nil then
                local scheduler = cc.Director:getInstance():getScheduler()
                self.tryMoveOneStepID = scheduler:scheduleScriptFunc(tryMoveOneStep, 0, false)
            end
        else
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
            self:OnAttackPressed()
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

function GameLayer:OnAttackPressed()
    -- 1. 检查是否碰到传送阵
    local pRect = self.player:getTextureRect()
    local px, py = self.player:getPosition()
    pRect.x, pRect.y = px, py
    for _, transfer in ipairs(self.transfers) do
        local tRect = transfer.rect
        if cc.rectIntersectsRect(pRect, tRect) then
            -- 跳到下一个地图
            local dir = tonumber(transfer.dir)
            if dir == 0 then
                self:onNextStage()
            elseif dir == 1 then
                self:onPrevStage()
            end
            return
        end
    end
    -- 2. 检查NPC是否在前面
    -- 3. 攻击打怪
    local can_attack = self.player:tryAttack()
    if can_attack == true then
        self.player:attack(self.monsterEntity)
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


