require "model.Player"
require "GameScene"

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
    self.ui = cc.CSLoader:createNode("welcomeUI.csb")
    self:addChild(self.ui) 

    local ctnBtn = self.ui:getChildByName("ctnBtn")
    ctnBtn:addTouchEventListener(function() self:onCtnJourneyTap() end)

    local newBtn = self.ui:getChildByName("newJourneyBtn")
    newBtn:addTouchEventListener(function() self:onNewJourneyTap() end)
end

function WelcomeScene:onCtnJourneyTap()
    local player = Player:create()
    local dict = {['player']=player}

	self:enterGameScene(dict)
end

function WelcomeScene:onNewJourneyTap()
    local player = Player:create()
    player:initWithDefaultRecord()

    local dict = {['player']=player}
    self:enterGameScene(dict)
end

function WelcomeScene:enterGameScene(dict)
    local gameScene = GameScene:create(dict)
    cc.Director:getInstance():replaceScene(gameScene)
end
