local const = require("const")

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

function Item:onObtain(target)
	-- body
	self:setVisible(false)
	self.isObtained = true
end

function Item:init(dict)
	self.itemId = dict.itemId
	self.rangeId = dict.rangeId
	self.isObtained = false

	-- 初始化图标
	self.icon = dict.icon
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	local frame = spriteFrameCache:getSpriteFrame(self.icon)
	if frame == nil then
		frame = cc.SpriteFrame:create(self.icon, cc.rect(0, 0, const.TILESIZE, const.TILESIZE))
		spriteFrameCache:addSpriteFrame(frame, self.icon)
	end
	self:setSpriteFrame(frame)

	-- 坐标
	-- 锚点设置为左下角，和tilemap一致
	self:setAnchorPoint(cc.p(0, 0))
	self:setPosition(dict.x, dict.y)
end