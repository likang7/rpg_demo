local const = require "const"
local Globals = require "model.Globals"
local helper = require "utils.helper"
local shopData = require "data.shopData"
local goodsData = require "data.goodsData"

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

	self:initUI(dict)
	self:initKeyboardEvent()
end

function ShopLayer:initUI(dict)
	self.shopID = dict.shopID
	self.ui = cc.CSLoader:createNode("shopUI.csb")
	local ui = self.ui
	self:addChild(ui)

	local panel = ui:getChildByName("shopPanel")

	local hintLabel = panel:getChildByName("hintLabel")
	hintLabel:setVisible(false)

	local shopPanel
	if self.shopID == const.SHOP_TYPE.CoinShop then
		shopPanel = panel:getChildByName("coinShopPanel")
	else
		shopPanel = panel:getChildByName("expShopPanel")
	end

	shopPanel:setVisible(true)

	local data = shopData[self.shopID]

	local contentLabel = panel:getChildByName("contentLabel")
	contentLabel:setString(helper.getDisplayText(data['content']))
	contentLabel:setTextAreaSize(cc.size(528, 72))

	local goodsList = data['shopList']
	for idx, goodsID in ipairs(goodsList) do
		local gData = goodsData[goodsID]
		local btn = shopPanel:getChildByName("btn" .. idx)
		btn:setTitleText(gData['desc'])
		btn:addClickEventListener(function() self:onBuyBtnClick(goodsID) end)
	end
end

function ShopLayer:onBuyBtnClick(goodsID)
	local ret = Globals.player:buyGoods(goodsID)
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
		if self.shopID == const.SHOP_TYPE.CoinShop then
			hintLabel:setString('金币不足!')
		else
			hintLabel:setString('经验不足!')
		end
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