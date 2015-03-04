
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
	self.ui = cc.CSLoader:createNode("shopUI.csb")
	self:addChild(self.ui)
end