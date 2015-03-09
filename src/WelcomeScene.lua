require "model.Player"
require "GameScene"
local const = require "const"
local stageData = require "data.stageData"
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
    ctnBtn:addClickEventListener(function() self:onCtnJourneyTap() end)

    local newBtn = self.ui:getChildByName("newJourneyBtn")
    newBtn:addClickEventListener(function() self:onNewJourneyTap() end)

    local aboutBtn = self.ui:getChildByName("aboutBtn")
    aboutBtn:addClickEventListener(function() self:onAboutTap() end)

    local helpPanel = self.ui:getChildByName("helpPanel")
    helpPanel:setVisible(false)
    
    local confirmBtn = helpPanel:getChildByName("confirmBtn")
    confirmBtn:addClickEventListener(function ()
        helpPanel:setVisible(false)
    end)

    cc.SimpleAudioEngine:getInstance():playMusic(const.MUSIC_ROOT .. stageData[0].musicPath, true)
end

function WelcomeScene:onCtnJourneyTap()
    local dict = {}
    Globals.player:initWithRecord()
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

function WelcomeScene:onAboutTap()
    local panel = self.ui:getChildByName("helpPanel")
    panel:setVisible(true)
end
