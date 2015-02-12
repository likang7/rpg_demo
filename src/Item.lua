local const = require("const")
local helper = require("utils.helper")

Item = class("Item",
	function ()
		return cc.Sprite:create()
	end)

Item.__index = Item

function Item:create(dict)
	local item = Item.new()
	item:init(dict)

	return item
end

function Item:onObtain()
	-- body
	self:setVisible(false)
	self.isObtained = true
end

function Item:getItemInfo()
	return self.data
end

function Item:init(dict)
	self.itemId = dict.itemId
	self.rangeId = dict.rangeId

	local data = helper.getItemInfoByItemId(self.itemId)
	self.data = data

	self.isObtained = false

	-- 初始化图标
	self.icon = data.icon
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	local frame = spriteFrameCache:getSpriteFrame(data.icon)
	if frame == nil then
		frame = cc.SpriteFrame:create(data.icon, cc.rect(0, 0, const.TILESIZE, const.TILESIZE))
		spriteFrameCache:addSpriteFrame(frame, data.icon)
	end
	self:setSpriteFrame(frame)

	-- 坐标
	-- 锚点设置为左下角，和tilemap一致
	self:setAnchorPoint(cc.p(0, 0))
	self:setPosition(dict.x, dict.y)
end