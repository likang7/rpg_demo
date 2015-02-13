require ("Entity")
require ("model.GameRecorder")

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
	self.recorder = nil
end

function Player:create()
	local player = Player.new()
	player:init()
	return player
end

function Player:init()
	self.recorder = GameRecorder:create()
	self.recorder:saveRecord()
end

function Player:initWithRecord()
	local playerInfo = self.recorder:getPlayerInfo()

end

function Player:getEntity()
	assert(self.entity ~= nil, "玩家的战斗角色为空")
	return self.entity
end

function Player:initEntity(dict)
	local entityData = EntityData:create(1, dict.gameMap)
	self.entity = Entity:create(entityData)
end

function Player:saveRecord(gameInfo)
	-- body
end