require "GameLayer"
require "model.Player"

GameScene = class("GameScene",
    function()
        return cc.Scene:create()  
    end
)

GameScene.__index = GameScene

function GameScene:createGameLayer()
    
    local dict = {stageId = 1}
    local gameLayer = GameLayer:create(dict)
    return gameLayer
end


function GameScene:create()
    local scene = GameScene.new()
    scene:init()

    return scene
end

function GameScene:init()
    local player = Player:create()

    local origin = cc.Director:getInstance():getVisibleOrigin()
    local gameLayer = self:createGameLayer()
    gameLayer:setPosition(origin.x, origin.y)
    -- gameLayer:setScale(2)
    self:addChild(gameLayer)
end