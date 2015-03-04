local const = require "const"
local Globals = require "model.Globals"
local helper = require "utils.helper"

ShopLayer = class("ShopLayer",
	function ()
		return cc.Layer:create()
	end
)

ShopLayer.__index = ShopLayer

function ShopLayer:create(dict)
	local layer = ShopLayer.new()
	layer:init(dict)

	return layer
end

function ShopLayer:init(dict)
	Globals.gameState = const.GAME_STATE.Shopping

	self:initUI()
	self:initKeyboardEvent()
end

function ShopLayer:initUI()
	self.ui = cc.CSLoader:createNode("shopUI.csb")
	local ui = self.ui
	self:addChild(ui)

	local panel = ui:getChildByName("shopPanel")

	local contentLabel = panel:getChildByName("contentLabel")
	local content = '花费金币买属性，世间难得的好事儿，走过路过不\n要错过哟！\n随便挑随便选，每样只要30金币！（ESC键离开）'
	contentLabel:setString(content)

	local buyAtkBtn = panel:getChildByName("buyAtkBtn")
	buyAtkBtn:setTitleText('攻击+' .. const.SHOP_ITEM.Atk)
	buyAtkBtn:addClickEventListener(function() self:onBuyAtkClick() end)

	local buyDefBtn = panel:getChildByName("buyDefBtn")
	buyDefBtn:setTitleText('防御+' .. const.SHOP_ITEM.Def)
	buyDefBtn:addClickEventListener(function() self:onBuyDefClick() end)

	local buyHpBtn = panel:getChildByName("buyHpBtn")
	buyHpBtn:setTitleText('生命+' .. const.SHOP_ITEM.Hp)
	buyHpBtn:addClickEventListener(function() self:onBuyHpClick() end)
end

function ShopLayer:onBuyAtkClick()
	local ret = Globals.player:buyAtk(const.SHOP_PRICE, const.SHOP_ITEM.Atk)
	self:showResultHint(ret)
end

function ShopLayer:onBuyDefClick()
	local ret = Globals.player:buyDef(const.SHOP_PRICE, const.SHOP_ITEM.Def)
	self:showResultHint(ret)
end

function ShopLayer:onBuyHpClick()
	local ret = Globals.player:buyHp(const.SHOP_PRICE, const.SHOP_ITEM.Hp)
	self:showResultHint(ret)
end

function ShopLayer:showResultHint(ret)
	local panel = self.ui:getChildByName("shopPanel")
	local hintLabel = panel:getChildByName("hintLabel")
	hintLabel:setVisible(true)
	hintLabel:setOpacity(255)

	if ret == true then
		hintLabel:setString('购买成功!')
		hintLabel:setColor(cc.c3b(0,255,0))
	else
		hintLabel:setString('金币不足!')
		hintLabel:setColor(cc.c3b(255,0,0))
	end

	local tag = 22

	hintLabel:stopActionByTag(tag)
	local act = helper.createHintMsgAction(hintLabel)
	act:setTag(tag)

	hintLabel:runAction(act)
end

function ShopLayer:initKeyboardEvent()
	local function onKeyPressed(keyCode, event)
		if keyCode == cc.KeyCode.KEY_ESCAPE then
			Globals.gameState = const.GAME_STATE.Playing
			self:removeFromParent()
		end
	end

	local listener = cc.EventListenerKeyboard:create()

	listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
	local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end