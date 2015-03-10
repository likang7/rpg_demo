local const = require "const"
local roleData = require "data.roleData"
local conversationData = require "data.conversationData"

ConversationLayer = class("ConversationLayer",
    function ()
        return cc.Layer:create()
    end
)

ConversationLayer.__index = ConversationLayer

function ConversationLayer:create(dict)
    local layer = ConversationLayer.new()
    layer:init(dict)

    return layer
end

function ConversationLayer:init(dict)
    Globals.gameState = const.GAME_STATE.Talking

    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames(const.HEAD_ICON_PLIST)

    self.ui = cc.CSLoader:createNode("conversationUI.csb")
    local ui = self.ui
    self:addChild(ui)

    local conversationID = dict.conversationID
    local data = conversationData[conversationID]

    self.roleIDList = data['roleList']
    self.contentList = data['contentList']
    self.idx = 1

    local listenerKeyBoard = cc.EventListenerKeyboard:create()
    listenerKeyBoard:registerScriptHandler(function(keyCode, event) self:_onKeyPressed(keyCode, event) end, cc.Handler.EVENT_KEYBOARD_PRESSED)
    
    local listenerMouse = cc.EventListenerMouse:create()
    listenerMouse:registerScriptHandler(function(event) self:showNextConversation() end, cc.Handler.EVENT_MOUSE_DOWN )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenerKeyBoard, self)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenerMouse, self)
    
    -- 延迟0.5s后才允许结束，避免误按
    self.can_close = false
    local delayClose = function()
        self.can_close = true
    end
    performWithDelay(self, delayClose, 0.5)

    self:showNextConversation()
end

function ConversationLayer:_onKeyPressed(keyCode, event)
    if self.can_close == true then
        self:showNextConversation()
    end
end

function ConversationLayer:showNextConversation()
    local id = self.roleIDList[self.idx]
    if id ~= nil then
        local panel = self.ui:getChildByName("rootPanel")

        -- 设置头像
        local headIcon = panel:getChildByName("headIcon")
        local _roleData = roleData[id]
        headIcon:loadTexture(_roleData.headIcon, ccui.TextureResType.plistType)
        
        -- 设置内容
        local content = self.contentList[self.idx]
        if content == nil then
            error('incorrect number of content found')
        else
            local contentLabel = panel:getChildByName("contentLabel")
            contentLabel:setString(content)
        end

        self.idx = self.idx + 1
    else
        Globals.gameState = const.GAME_STATE.Playing
        self:removeFromParent()
    end
end