require "model.Player"
require "GameScene"
local Globals = require "model.Globals"

WelcomeScene = class("WelcomeScene",
    function()
        return cc.Scene:create()  
    end
)

WelcomeScene.__index = WelcomeScene

function WelcomeScene:create()
    local scene = WelcomeScene.new()
    scene:init()

    return scene
end

function WelcomeScene:init()
    if Globals.player == nil then
        Globals.player = Player:create()
    end

    self.ui = cc.CSLoader:createNode("welcomeUI.csb")
    self:addChild(self.ui) 

    local ctnBtn = self.ui:getChildByName("ctnBtn")
    ctnBtn:addTouchEventListener(function() self:onCtnJourneyTap() end)

    local newBtn = self.ui:getChildByName("newJourneyBtn")
    newBtn:addTouchEventListener(function() self:onNewJourneyTap() end)
end

function WelcomeScene:onCtnJourneyTap()
    local dict = {}
	self:enterGameScene(dict)
end

function WelcomeScene:onNewJourneyTap()
    Globals.player:initWithDefaultRecord()

    local dict = {}
    self:enterGameScene(dict)
end

function WelcomeScene:enterGameScene(dict)
    local gameScene = GameScene:create(dict)
    cc.Director:getInstance():replaceScene(gameScene)
end
