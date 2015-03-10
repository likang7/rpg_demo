require "view.GameLayer"
require "model.Player"
require "view.GameUILayer"
local Globals = require "model.Globals"

GameScene = class("GameScene",
    function()
        return cc.Scene:create()  
    end
)

GameScene.__index = GameScene

function GameScene:createGameLayer()
    local curStageId = self.player:getCurStageId()
    local dict = {stageId = curStageId}
    local gameLayer = GameLayer:create(dict)
    return gameLayer
end


function GameScene:create(dict)
    local scene = GameScene.new()

    Globals.gameScene = scene

    scene:init(dict)

    return scene
end

function GameScene:getGameLayer()
    return self:getChildByTag(self.gameLayerTag)
end

function GameScene:init(dict)
    self.player = Globals.player

    local origin = cc.Director:getInstance():getVisibleOrigin()
    local gameLayer = self:createGameLayer()
    gameLayer:setPosition(origin.x, origin.y)
    -- gameLayer:setScale(2)
    self.gameLayerTag = 10
    gameLayer:setTag(self.gameLayerTag)
    self:addChild(gameLayer)

    local gameUILayer = GameUILayer:create()
    self:addChild(gameUILayer)

    local tick = function(dt)
        gameLayer:step(dt)
        gameUILayer:step(dt)
    end

    local scheduler = cc.Director:getInstance():getScheduler()
    local schedulerTickID = scheduler:scheduleScriptFunc(tick, 0, false)

    local function onNodeEvent(event)
        if "exit" == event then
            gameLayer:clearAll()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerTickID)
            
            Globals.gameScene = nil
            Globals.gameMap = nil
            -- local spriteFrameCache = cc.SpriteFrameCache:getInstance()
            -- spriteFrameCache:removeUnusedSpriteFrames()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function GameScene:popConversation(conversationID)
    require "view.ConversationLayer"
    local layer = ConversationLayer:create({['conversationID']=conversationID})
    self:addChild(layer, const.DISPLAY_PRIORITY.Conversation)
end

function GameScene:popShopLayer(shopID)
    require "view.ShopLayer"
    local shopLayer = ShopLayer:create({['shopID']=shopID})
    self:addChild(shopLayer, const.DISPLAY_PRIORITY.Shop)
end

function GameScene:transferToFailScene()
    require "view.FailScene"
    local scene = FailScene:create()
    cc.Director:getInstance():replaceScene(scene)
end

function GameScene:transferToWelcomeScene()
    require "view.WelcomeScene"
    local scene = WelcomeScene:create()
    cc.Director:getInstance():replaceScene(scene)
end

