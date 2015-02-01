
GameScene = class("GameScene",
    function()
        return cc.Scene:create()  
    end
)

GameScene.__index = GameScene

function GameScene:createGameLayer()
	require "gamelayer"
	local gameLayer = GameLayer:create()
	return gameLayer
end


function GameScene:create()
	local scene = GameScene.new()
	scene:init()

	return scene
end

function GameScene:init()
	local gameLayer = self:createGameLayer()
	self:addChild(gameLayer)
end