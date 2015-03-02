require "GameLayer"
require "model.Player"

GameScene = class("GameScene",
    function()
        return cc.Scene:create()  
    end
)

GameScene.__index = GameScene

function GameScene:createGameLayer()
    local curStageId = self.player:getCurStageId()
    local dict = {stageId = curStageId, player = self.player}
    local gameLayer = GameLayer:create(dict)
    return gameLayer
end


function GameScene:create()
    local scene = GameScene.new()
    scene:init()

    return scene
end

function GameScene:init()
    self.player = Player:create()

    local origin = cc.Director:getInstance():getVisibleOrigin()
    local gameLayer = self:createGameLayer()
    gameLayer:setPosition(origin.x, origin.y)
    -- gameLayer:setScale(2)
    self:addChild(gameLayer)

    local function onNodeEvent(event)
        if "exit" == event then
           self:clearAll()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    self.ui = cc.CSLoader:createNode("welcomeUI.csb")
    self:addChild(self.ui) 
end

function clearAll()
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:removeUnusedSpriteFrames()
end