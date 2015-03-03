local const = require('const')

DialogComp = class("DialogComp")

DialogComp.__index = DialogComp

function DialogComp:create(dict, enabled)
	local comp = DialogComp.new()
	comp:init(dict, enabled)

	return comp
end

function DialogComp:init(dict, enabled)
	self.enabled = enabled
	self.entity = dict.entity
	self.target = dict.target
	self.detectRange = dict.detectRange

	self.cnt = 1
end

function DialogComp:step()
	if self.enabled == false or self.entity:getLifeState() == const.LifeState.Die then
		return
	end

	if self.target == nil or self.target:getLifeState() == const.LifeState.Die then
		self.enabled = false
	end

	self.cnt = self.cnt + 1
	if self.cnt % 6 == 0 then
		return
	end

	local ex, ey = self.entity:getPosition()
	local tx, ty = self.target:getPosition()

	local dis = cc.pGetDistance(cc.p(ex, ey), cc.p(tx, ty))
	if dis <= self.detectRange then
		self.entity:showDialog()
	else
		self.entity:hideDialog()
	end
end