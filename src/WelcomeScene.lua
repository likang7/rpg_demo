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
    -- ctnBtn:registerScriptTapHandler(self.onCtnJourneyTap)
end

function WelcomeScene:onCtnJourneyTap()
	require "GameScene"
	local gameScene = GameScene:create()

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end
end
