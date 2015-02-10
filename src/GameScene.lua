
GameScene = class("GameScene",
    function()
        return cc.Scene:create()  
    end
)

GameScene.__index = GameScene

function GameScene:createGameLayer()
    require "GameLayer"
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
    local origin = cc.Director:getInstance():getVisibleOrigin()
    local gameLayer = self:createGameLayer()
    gameLayer:setPosition(origin.x, origin.y)
    self:addChild(gameLayer)
end