require ("sprite.Entity")
require ("model.GameRecorder")
local const = require "const"

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
		self:_initWithRecord()
	else
		self:_initWithRecord()
	end
end

function Player:initWithDefaultRecord()
	self.recorder:initWithDefaultRecord()
	self:_initWithRecord()
end

function Player:getPersistent()
	return {
		name = self.name,
		level = self.level,
		exp = self.exp,
		coin = self.coin,
		package = self.package,
	}
end

function Player:initWithRecord()
	self.recorder:initWithRecord()
	self:_initWithRecord()
end

function Player:_initWithRecord()
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
		local heroData = EntityData:create(const.HERO_ID)
		heroData.camp = 0
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

function Player:getMaxStageId()
	local stageInfo = self.recorder:getStageInfo()
    local maxStageId = stageInfo.maxStageId
    return maxStageId
end

function Player:obtainCoin(num)
	self.coin = self.coin + num
end

function Player:obtainExp(num)
	self.exp = self.exp + num
end

function Player:onUpgradeLevel()
	self.level = self.level + 1
	local heroData = self.heroData
	heroData:setAtk(heroData.atk + 5)
	heroData:setDef(heroData.def + 5)
	heroData:setHp(heroData.hp + 100)
	heroData:setCriRate(heroData.criRate + 0.5)
	heroData:setAntiCriRate(heroData.antiCriRate + 0.3)
end

function Player:costCoin(num)
	if self.coin < num then
		return false
	else
		self.coin = self.coin - num
		return true
	end
end

function Player:costExp(num)
	if self.exp < num then
		return false
	else
		self.exp = self.exp - num
		return true
	end
end

function Player:buyAtk(price, addition)
	if self:costCoin(price) then
		self.heroData:setAtk(self.heroData.atk + addition)
		return true
	else
		return false
	end
end

function Player:buyDef(price, addition)
	if self:costCoin(price) then
		self.heroData:setDef(self.heroData.def + addition)
		return true
	else
		return false
	end
end

function Player:buyHp(price, addition)
	if self:costCoin(price) then
		self.heroData:setHp(self.heroData.hp + addition)
		return true
	else
		return false
	end
end

function Player:buyGoods(goodsID)
	local goodsData = require("data.goodsData")
	local data = goodsData[goodsID]
	if data.costType == const.COST_TYPE.Coin then
		if self:costCoin(data.cost) then
			self:promoteWithGoodsData(data)
			return true
		else
			return false
		end
	elseif data.costType == const.COST_TYPE.Exp then
		if self:costExp(data.cost) then
			self:promoteWithGoodsData(data)
			return true
		else
			return false
		end
	else
		error('undefined goods cost type')
	end
	return false
end

function Player:promoteWithGoodsData(data)
	local goodsType = data['function']
	local heroData = self.heroData

	if goodsType == const.GOODS_FUNC.Level then
		self:onUpgradeLevel()
	elseif goodsType == const.GOODS_FUNC.Atk then
		heroData:setAtk(heroData.atk + data.attack)
	elseif goodsType == const.GOODS_FUNC.Def then
		heroData:setDef(heroData.def + data.defense)
	elseif goodsType == const.GOODS_FUNC.Hp then
		heroData:setHp(heroData.hp + data.hp)
	else
		error('undefined goods function type')
	end
end

function Player:onKillMonster(targetData)
	if targetData.coinDrop ~= nil then
		self:obtainCoin(targetData.coinDrop)
	end

	if targetData.expDrop ~= nil then
		self:obtainExp(targetData.expDrop)
	end
end

function Player:isTaskFinished()
	return self.package[const.NEIDAN_ID] == true
end

function Player:obtainItem(playerEntity, item)
	local itemInfo = item:getItemInfo()

	local func = itemInfo['function']
	if func == const.ITEM_TYPE.Special then
		self.package[itemInfo.itemID] = true
	elseif func == const.ITEM_TYPE.Coin then
		self:obtainCoin(itemInfo.coin)
	end

	self.heroData:onObtainItem(itemInfo)
	playerEntity:obtainItem(item)
end
