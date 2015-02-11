require "Entity"

Player = class("Player")

Player.__index = Player

function Player:ctor()
	self.name = 'demo'
	self.level = 1
	self.entity = nil
	self.exp = 0
	self.maxExp = 0
	self.coin = 0
	self.package = {}
end

function Player:create()
	local player = Player.new()

	return player
end

function Player:initWithRecord()
	local record = self:loadRecord()
end

function Player:getEntity()
	assert(self.entity ~= nil, "玩家的战斗角色为空")
	return self.entity
end

function Player:initEntity(dict)
	local entityData = EntityData:create(1, dict.gameMap)
	self.entity = Entity:create(entityData)
end

function Player:loadRecord()
	-- return record
end

function Player:saveRecord(gameInfo)
	-- body
end