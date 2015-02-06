
AIComp = class("AIComp")

AIComp.__index = AIComp

function AIComp:ctor()
	
end

function AIComp:create(info)
	
end

function AIComp:init(info)
	self.entity = info.entity
	self.gameMap = info.gameMap
	self.bornPoint = info.bornPoint
	self.enemyEntity = info.enemyEntity
	self.atkRange = info.atkRange
	self.detectRange = info.detectRange
	self.enabled = false
end