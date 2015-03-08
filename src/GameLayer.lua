local const = require "const"
local Globals = require "model.Globals"
require "Entity"
require "model.EntityData"
require "model.AIComp"
require "model.DialogComp"
require "Transfer"
require "Item"
require "GameMap"

local Direction = const.Direction
local math = math
local ipairs = ipairs
local pairs = pairs
local helper = require "utils.helper"
local tonumber = tonumber
local table = table
local next = next

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
    self.items = {}
    -- key:rangeId, value:boolean. 为true时可以捡取道具
    self.rangeFlags = {}
    self.npcs = {}

    local stageState = self.player:getStageState(self.stageId)
    local px, py = nil, nil
    if stageState == nil then
        self.deadMonsterIds = {}
        self.deadItemIds = {}
    else
        self.deadMonsterIds = stageState.deadMonsterIds
        self.deadItemIds = stageState.deadItemIds
        if stageState.heroPosition ~= nil then
            px, py = stageState.heroPosition[1], stageState.heroPosition[2]
        end
    end

    self.playerEntity = nil
    --先初始化玩家
    local object = objectGroup:getObject("bornPoint")
    local entityData = self.player:getHeroData() --EntityData:create(1)
    if px == nil or py == nil then
        entityData:setBornPoint(cc.p(object.x+const.TILESIZE/2, object.y+const.TILESIZE/2), true)
    else
        entityData:setBornPoint(cc.p(px, py), true)
    end
    local playerEntity = Entity:create(entityData)
    self.playerEntity = playerEntity
    self:addChild(playerEntity, const.DISPLAY_PRIORITY.Hero)

    local objects = objectGroup:getObjects()
    for _, object in pairs(objects) do
        local otype = tonumber(object['type'])
        if otype == const.TILEMAP_TYPE.Transfer then
            -- 初始化传送点
            local x, y, w, h = object.x, object.y, object.width, object.height
            local dict = {rect = cc.rect(x, y, w, h), dir = object.direction}
            local transfer = Transfer:create(dict)
            table.insert(self.transfers, transfer) 
        elseif otype == const.TILEMAP_TYPE.NPC then
            -- 初始化NPC
            local entityData = EntityData:create(tonumber(object.name))
            local px, py = object.x+const.TILESIZE/2, object.y+const.TILESIZE/2
            px, py = px+object.width/2, py+object.height/2
            entityData:setBornPoint(cc.p(px, py))
            local npc = Entity:create(entityData)
            self:addChild(npc, const.DISPLAY_PRIORITY.NPC)
            table.insert(self.npcs, npc)
            self.gameMap:addBlock(px, py, const.BLOCK_TYPE.NPC)

            --comp
            local dict = {
                ['entity'] = npc,
                ['target'] = self.playerEntity,
                ['detectRange'] = object.width/2,
            }
            local dialogComp = DialogComp:create(dict, true)
            npc:setDialogComp(dialogComp)
        elseif otype == const.TILEMAP_TYPE.Item then
            -- 初始化道具
            local viewx, viewy = object.x, object.y
            local hashId = tostring(self.gameMap:hashViewCoord(viewx, viewy))
            if self.deadItemIds[hashId] == nil then
                local fakeDict = {itemId=tonumber(object.name), rangeId=tonumber(object.rangeID), x=object.x, y=object.y}
                local item = Item:create(fakeDict)
                self:addChild(item, const.DISPLAY_PRIORITY.Item)
                self.items[hashId] = item
            end
        elseif otype == const.TILEMAP_TYPE.Monster then
            -- 初始化monster
            local viewx, viewy = object.x+object.width/2, object.y+object.height/2
            local hashId = tostring(self.gameMap:hashViewCoord(viewx, viewy))
            if self.deadMonsterIds[hashId] == nil then
                local entityData = EntityData:create(tonumber(object.name))
                entityData:setBornPoint(cc.p(viewx, viewy))
                entityData.rangeId = tonumber(object.rangeID)
                entityData.detectRange = object.width/2
                if entityData.rangeId ~= nil then
                    self.rangeFlags[entityData.rangeId] = false
                end
                local monster = Entity:create(entityData)
                self:addChild(monster, const.DISPLAY_PRIORITY.Monster)
                self.monsterEntity[hashId] = monster

                --ai
                local dict = {
                    ['entity'] = monster,
                    ['gameMap'] = self.gameMap,
                    ['enemyEntity'] = {self.playerEntity},
                    ['catchRange'] = object.width/2,
                }
                local aiComp = AIComp:create(dict, true)
                monster:setAIComp(aiComp)

                --diag
                if entityData.meetConversationID ~= nil or 
                    entityData.dieConversationID ~= nil or
                    entityData.dialog ~= nil then
                    local dict = {
                        ['entity'] = monster,
                        ['target'] = self.playerEntity,
                        ['detectRange'] = object.width/2,
                    }
                    local dialogComp = DialogComp:create(dict, true)
                    monster:setDialogComp(dialogComp)
                end
            end
        end
    end
end

function GameLayer:clearAll()
    local scheduler = cc.Director:getInstance():getScheduler()
    if self.tryMoveOneStepID ~= nil then
        scheduler:unscheduleScriptEntry(self.tryMoveOneStepID)
        self.tryMoveOneStepID = nil
    end

    self.playerEntity = nil
    self.monsterEntity = {}
    self.transfers = {}
    self.gameMap = nil
    Globals.gameMap = nil
    self.deadMonsterIds = {}
    self.deadItemIds = {}

    if self.pressSum == nil then
        self.pressSum = 0
    end

    self:removeAllChildren()

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeEventListenersForTarget(self, true)
end

function GameLayer:initTileMap(tilemapPath)
    local tilemap = cc.TMXTiledMap:create(tilemapPath)
    self.gameMap = GameMap:create(tilemap)
    Globals.gameMap = self.gameMap

    self:addChild(tilemap)

    -- 天空层
    local skys = self.gameMap:getSkyLayers(tilemap)
    for _, sky in ipairs(skys) do
        sky:retain()
        tilemap:removeChild(sky)
        self:addChild(sky, const.DISPLAY_PRIORITY.Sky)
        sky:release()
    end

    local objects = tilemap:getObjectGroup("object")
    self:initEntity(objects)
end

function GameLayer:toggleShowDetectRange(  )
    self.showDetectRange = not self.showDetectRange
end

function GameLayer:init(dict)
    self:clearAll()
    
    Globals.gameState = const.GAME_STATE.Playing

    local tilemapPath = string.format("map/map-%d.tmx", dict.stageId)

    self.player = Globals.player
    self.stageId = dict.stageId

    self:initTileMap(tilemapPath)

    self.showDetectRange = false

    -- add bg
    -- local sceneTexturePath = "scene.jpg"
    -- local bg = cc.Sprite:create(sceneTexturePath)
    -- bg:setAnchorPoint(0, 0)
    -- -- -- 高度补偿
    -- bg:setPosition(origin.x, origin.y + self.gameMap.map_h - bg:getTextureRect().height)
    -- self:addChild(bg, -1)

    self:initTouchEvent()

    self:initKeyboardEvent()

    -- self:initUI()
end

function GameLayer:step(dt)
    if Globals.gameState ~= const.GAME_STATE.Playing then
        return
    end

    -- 更新玩家
    if self.playerEntity ~= nil and self.playerEntity:getLifeState() ~= const.LifeState.Die then
        self.playerEntity:step(dt)
    end

    -- 更新monster
    for k, monster in pairs(self.monsterEntity) do
        if monster.status == const.Status.die then
            local rangeId = monster:getRangeId()
            if rangeId ~= nil then
                self.rangeFlags[rangeId] = true
            end
            if self.playerEntity:getTarget() == monster then
                self.playerEntity:setTarget(nil)
            end
            self.monsterEntity[k] = nil
            self.deadMonsterIds[k] = monster:getRoleID()
            self:removeChild(monster, true)
        else
            monster:setDetectRangeShow(self.showDetectRange)
            monster:step(dt)
        end
    end

    -- 更新npc
    for _, npc in ipairs(self.npcs) do
        npc:step(dt)
    end
end

function GameLayer:saveRecord()
    local gameInfo = {stageId=self.stageId, stageState=self:getStageState()}
    self.player:saveRecord(gameInfo)
end

function GameLayer:updateRecord()
    local gameInfo = {stageId=self.stageId, stageState=self:getStageState()}
    self.player:updateRecord(gameInfo)
end

function GameLayer:onNextStage()
    --1. 保存当前关卡记录
    self:updateRecord()
    --2. 切换到下一关
    local nextStageId = self.stageId + 1
    local dict = {stageId=nextStageId, player=self.player}
    self:init(dict)
    self:updateRecord()
end

function GameLayer:onPrevStage()
    self:updateRecord()
    local prevStageId = self.stageId - 1
    local dict = {stageId=prevStageId, player=self.player}
    self:init(dict)
    self:updateRecord()
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

        local px, py = self.playerEntity:getPosition()

        local path = self.gameMap:pathTo(cc.p(px, py), cc.p(tox, toy))
        
        self.playerEntity:runPath(path)
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
        if Globals.gameState ~= const.GAME_STATE.Playing then
            self.playerEntity:stopRuning()
            return
        end

        local dir = getDirection(self.pressSum)
        local d = const.DirectionToVec
        self.playerEntity:runOneStep(dir)
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
        -- cclog(string.format("Key with keycode %d pressed", keyCode))
        if keyCode == cc.KeyCode.KEY_W then
            self.pressSum = self.pressSum + KEYW
        elseif keyCode == cc.KeyCode.KEY_A then
            self.pressSum = self.pressSum + KEYA
        elseif keyCode == cc.KeyCode.KEY_S then
            self.pressSum = self.pressSum + KEYS
        elseif keyCode == cc.KeyCode.KEY_D then
            self.pressSum = self.pressSum + KEYD
        end

        if Globals.gameState ~= const.GAME_STATE.Playing then
            return 
        end
        tryMoveOneStep()

        if keyCode == cc.KeyCode.KEY_I or keyCode == cc.KeyCode.KEY_CAPITAL_I or keyCode == cc.KeyCode.KEY_J then
            self:OnAttackPressed()
        elseif keyCode == cc.KeyCode.KEY_TAB then
            self:toggleShowDetectRange()
        elseif keyCode == cc.KeyCode.KEY_H then
            self.playerEntity:watchTarget(self.monsterEntity)
        end
    end

    local function onKeyReleased(keyCode, event)
        -- cclog(string.format("Key with keycode %d released", keyCode))
        if self.pressSum <= 0 then
            return
        end

        if keyCode == cc.KeyCode.KEY_W then
            self.pressSum = self.pressSum - KEYW
        elseif keyCode == cc.KeyCode.KEY_A then
            self.pressSum = self.pressSum - KEYA
        elseif keyCode == cc.KeyCode.KEY_S then
            self.pressSum = self.pressSum - KEYS
        elseif keyCode == cc.KeyCode.KEY_D then
            self.pressSum = self.pressSum - KEYD
        end

        if Globals.gameState ~= const.GAME_STATE.Playing then
            return 
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
    if self.playerEntity:getLifeState() == const.LifeState.Die then
        return
    end

    -- 1. 检查是否碰到传送阵
    local px, py = self.playerEntity:getPosition()
    local pRect = cc.rect(px, py, 1, 1)
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

    -- 2. 检查是否有商人在前面
    local dir = self.playerEntity:getDir()
    local r = self.playerEntity:getAtkRange()
    local theta = 120
    local npcs = self.gameMap:searchTargetsInFan(px, py, dir, r, theta, self.npcs)
    if next(npcs) ~= nil then
        for _, npc in ipairs(npcs) do
            local funcType = npc:getFuncionType()
            if funcType ~= nil then
                Globals.gameScene:popShopLayer(funcType)
                return
            end
        end
    end

    -- 3. 检查是否有道具 TODO: 可以优化，检查下脚下坐标里的是不是道具就可以了
    for k, item in pairs(self.items) do
        local rangeId = item.rangeId
        if item.isObtained == false and (rangeId == nil or self.rangeFlags[rangeId] ~= false) then
            local ix, iy = item:getPosition()
            local tRect = cc.rect(ix, iy, const.TILESIZE, const.TILESIZE)
            if cc.rectIntersectsRect(pRect, tRect) then
                local itemInfo = item:getItemInfo()
                if itemInfo.coin ~= nil then
                    self.player:obtainCoin(itemInfo.coin)
                end
                self.playerEntity:obtainItem(item)
                self.items[k] = nil
                self:removeChild(item, true)
                self.deadItemIds[k] = true
                return
            end
        end
    end
    -- 4. 攻击打怪
    local can_attack = self.playerEntity:tryAttack()
    if can_attack == true then
        self.playerEntity:attack(self.monsterEntity)
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

function GameLayer:getStageState()
    local px, py = self.playerEntity:getPosition()
    return {
        ['deadMonsterIds'] = self.deadMonsterIds,
        ['deadItemIds'] = self.deadItemIds,
        ['heroPosition'] = {px, py}
    }
end

function GameLayer:getPlayerEntity()
    return self.playerEntity
end

