-- Entity的AI组件

local const = require('const')
local Status = const.Status
local pairs = pairs
local math = math
local helper = require("utils.helper")

AIComp = class("AIComp")

AIComp.__index = AIComp

local AIStatus = {idle=0, attacking=1, running=2, backing=3}

function AIComp:ctor()
	
end

function AIComp:create(dict, enabled)
	local comp = AIComp.new()
	comp:init(dict, enabled)
	return comp
end

function AIComp:init(dict, enabled)
	self.entity = dict.entity
	self.gameMap = dict.gameMap
	self.bornPoint = dict.entity:getBornPoint()
	self.enemyEntity = dict.enemyEntity
	self.atkRange = dict.entity:getAtkRange()
	self.detectRange = dict.entity:getDetectRange()
	self.catchRange = dict.catchRange
	self.enabled = enabled
	self.target = nil
	self.status = AIStatus.idle
	self.i = 0
end

function AIComp:step()
	if self.enabled == false or self.entity:getLifeState() == const.LifeState.Die then
		return
	end
	self.i = self.i + 1
	if self.i % 6 ~= 0 then
		return
	end

	local entity = self.entity
	if self.status == AIStatus.idle then
		-- 空闲->找目标，找到目标后跑向目标并攻击
		self.target = entity:findTarget(self.enemyEntity)
		if self.target ~= nil then
			local path = self.gameMap:pathTo(cc.p(entity:getPosition()), cc.p(self.target:getPosition()))
			entity:runPath(path)
			self.status = AIStatus.attacking
		end
	elseif self.target ~= nil and self.target.status == const.Status.die then
		-- 目标挂掉之后回出生点
		self.target = nil
		self:returnToBornPoint()
		self.status = AIStatus.backing
	elseif self.status == AIStatus.attacking then
		-- 攻击目标
		local dis = self:getDistance(entity, self.target)
		local disToBornPoint = cc.pGetDistance(cc.p(entity:getPosition()), self.bornPoint)
		if dis < self.atkRange then
			local dir = helper.getDirection(cc.p(entity:getPosition()), cc.p(self.target:getPosition()))
			entity:updateDir(dir)
			if entity:tryAttack() then
				entity:attack(self.enemyEntity)
				if self.target:getLifeState() == const.LifeState.Die then
					self.target = nil
					self:returnToBornPoint()
					self.status = AIStatus.backing
				end
			end
		elseif disToBornPoint < self.catchRange then
			-- 在追击范围，追杀
			if entity.status ~= const.Status.run then
				local path = self.gameMap:pathTo(cc.p(entity:getPosition()), cc.p(self.target:getPosition()))
				entity:runPath(path)
			end
		elseif disToBornPoint >= self.catchRange then
			-- 超出
			self:returnToBornPoint()
			self.status = AIStatus.backing 
		else
			cclog('undefinded in AIStatus:attacking')
		end
	elseif self.status == AIStatus.backing then
		local t= cc.p(entity:getPosition())
		local dis = cc.pGetDistance(cc.p(entity:getPosition()), self.bornPoint)
		if dis <= self.gameMap.tileSize.width / 2 or not entity:isRunning() then
			self.status = AIStatus.idle
		end
	end
end

function AIComp:returnToBornPoint()
	-- TODO：设置为无敌状态
	self.entity._model.hp = self.entity._model.maxhp
	local path = self.gameMap:pathTo(cc.p(self.entity:getPosition()), self.bornPoint)
	self.entity:runPath(path)
end

function AIComp:getDistance(spr1, spr2)
	return cc.pGetDistance(cc.p(spr1:getPosition()), cc.p(spr2:getPosition()))
end

function AIComp:canAttack(target)
	local pos = cc.p(self.entity:getPosition())
	local tpos = cc.p(target:getPosition())
	local dis = cc.pGetDistance(tpos, pos)
	return dis < self.atkRange
end