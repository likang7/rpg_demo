local const = require('const')
local Globals = require("model.Globals")

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

	self.everPopMeet = false
	self.everPopDie = false

	self.cnt = 1
end

function DialogComp:step()
	if self.enabled == false then
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
		local meetConversationID = self.entity:getMeetConversationID()
		if self.everPopMeet == false and meetConversationID ~= nil then
			self.everPopMeet = true
			self:popConversation(meetConversationID)
		else
			self.entity:showDialog()
		end
	else
		self.entity:hideDialog()
	end

	if self.entity:getLifeState() == const.LifeState.Die then
		local dieConversationID = self.entity:getDieConversationID()
		if self.everPopDie == false and dieConversationID ~= nil then
			self.everPopDie = true
			self:popConversation(dieConversationID)
		end
	end
end

function DialogComp:popConversation(conversationID)
	if Globals.player:getCurStageId() == Globals.player:getMaxStageId() then
		Globals.gameScene:popConversation(conversationID)
	end
end