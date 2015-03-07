require "GameLayer"
require "model.Player"
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
    scene:init(dict)

    Globals.gameScene = scene
    
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

    local function onNodeEvent(event)
        if "exit" == event then
            -- local spriteFrameCache = cc.SpriteFrameCache:getInstance()
            -- spriteFrameCache:removeUnusedSpriteFrames()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end