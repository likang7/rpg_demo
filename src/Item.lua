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
	spriteFrameCache:addSpriteFrames(data.plist)
	local frame = spriteFrameCache:getSpriteFrame(data.icon)

	self:setSpriteFrame(frame)

	-- 这里其实应该直接出合适大小的图才对 = =
	local size = frame:getOriginalSizeInPixels()
	local scale = const.TILESIZE / math.max(size.width, size.height)
	self:setScale(scale)

	-- 坐标
	-- 锚点设置为左下角，和tilemap一致
	self:setAnchorPoint(cc.p(0, 0))
	self:setPosition(dict.x, dict.y)
end