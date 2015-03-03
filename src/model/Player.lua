require ("Entity")
require ("model.GameRecorder")

Player = class("Player")

Player.__index = Player

function Player:ctor()
	self.recorder = nil
end

function Player:create()
	local player = Player.new()
	player:init()
	return player
end

function Player:init()
	self.recorder = GameRecorder:create()
	if self.recorder.isNewPlayer then
		self:initWithRecord()
	else
		self:initWithRecord()
	end
end

function Player:initWithDefaultRecord()
	self.recorder:initWithDefaultRecord()
	self:initWithRecord()
end

function Player:getPersistent()
	return {
		name = self.name,
		level = self.level,
		exp = self.exp,
		coin = self.coin,
		package = {},
	}
end

function Player:initWithRecord()
	local playerInfo = self.recorder:getPlayerInfo()
	if next(playerInfo) ~= nil then
		self.name = playerInfo.name
		self.level = playerInfo.level
		self.exp = playerInfo.exp
		self.coin = playerInfo.coin
		self.package = playerInfo.package
	else
		self.name = '白晶晶'
		self.level = 1
		self.heroData = nil
		self.exp = 0
		self.coin = 0
		self.package = {}
	end

	local heroInfo = self.recorder:getHeroInfo()
	self:initHeroData(heroInfo)
end

function Player:getHeroData()
	assert(self.heroData ~= nil, "玩家的战斗角色为空")
	return self.heroData
end

function Player:initHeroData(info)
	if next(info) == nil then
		local heroData = EntityData:create(1)
		self.heroData = heroData
	else
		self.heroData = EntityData:createWithDict(info)
	end
end

function Player:updateRecord(gameInfo)
	local playerInfo = self:getPersistent()
	self.recorder:updatePlayerInfo(playerInfo)

	local heroInfo = self.heroData:getPersistent()
	self.recorder:updateHeroInfo(heroInfo)

	-- get map info
	self.recorder:updateStageState(gameInfo.stageId, gameInfo.stageState)
end

function Player:saveRecord(gameInfo)                                               
	self:updateRecord(gameInfo)

	self.recorder:saveRecord()
end

function Player:getStageState(stageId)
	return self.recorder:getStageState(stageId)
end

function Player:getCurStageId()
	local stageInfo = self.recorder:getStageInfo()
    local curStageId = stageInfo.curStageId
    return curStageId
end

function Player:obtainCoin(num)
	self.coin = self.coin + num
end

function Player:obtainExp(num)
	self.exp = self.exp + num
end

function Player:onUpgradeLevel()
	self.level = self.level + 1
end