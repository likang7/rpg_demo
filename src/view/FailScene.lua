
FailScene = class("FailScene",
    function()
        return cc.Scene:create()  
    end
)

FailScene.__index = FailScene

function FailScene:create()
    local scene = FailScene.new()
    scene:init()

    return scene
end

function FailScene:init()
	local ui = cc.CSLoader:createNode("failUI.csb")
	self:addChild(ui)

	local function onKeyPressed(keyCode, event)
		if keyCode == cc.KeyCode.KEY_ESCAPE then
			require "view.WelcomeScene"
	        local scene = WelcomeScene:create()
	        cc.Director:getInstance():replaceScene(scene)
		end
	end

	local listener = cc.EventListenerKeyboard:create()

	listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
	local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end