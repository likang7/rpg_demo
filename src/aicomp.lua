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
	self.bornPoint = dict.bornPoint
	self.enemyEntity = dict.enemyEntity
	self.atkRange = dict.atkRange
	self.detectRange = dict.detectRange
	self.catchRange = dict.catchRange
	self.enabled = enabled
	self.target = nil
	self.status = AIStatus.idle
end

function AIComp:step()
	if self.enabled == false then
		return
	end
	local entity = self.entity
	if self.status == AIStatus.idle then
		self.target = self:findTarget()
		if self.target ~= nil then
			local path = self.gameMap:pathTo(cc.p(entity:getPosition()), cc.p(self.target:getPosition()))
			entity:runPath(path)
			self.status = AIStatus.running
		end
	elseif self.target ~= nil and self.target.status == const.Status.die then
		self.target = nil
		self:returnToBornPoint()
		self.status = AIStatus.backing
	elseif self.status == AIStatus.running then
		if self:canAttack(self.target) then
			self.status = AIStatus.attacking
		end
	elseif self.status == AIStatus.attacking then
		local dis = self:getDistance(entity, self.target)
		if dis < self.atkRange then
			local dir = helper.getDirection(cc.p(entity:getPosition()), cc.p(self.target:getPosition()))
			entity:setStandDirection(dir)
			-- 这里是否需要判断敌人在扇形范围内？
			if entity:tryAttack() then
				self.target:onHurt(entity.atk)
				if self.target.status == const.Status.die then
					self.target = nil
					self:returnToBornPoint()
					self.status = AIStatus.backing
				end
			end
		elseif dis < self.catchRange then
			-- 在追击范围，追杀
			local path = self.gameMap:pathTo(cc.p(entity:getPosition()), cc.p(self.target:getPosition()))
			entity:runPath(path)
		elseif dis >= self.catchRange then
			-- 超出
			self:returnToBornPoint()
			self.status = AIStatus.backing 
		else
			cclog('undefinded in AIStatus:attacking')
		end
	elseif self.status == AIStatus.backing then
		local t= cc.p(entity:getPosition())
		local dis = cc.pGetDistance(cc.p(entity:getPosition()), self.bornPoint)
		if dis < self.gameMap.tileSize.width then
			-- TODO: 恢复HP
			self.status = AIStatus.idle
		end
	end
end

function AIComp:returnToBornPoint()
	-- TODO：设置为无敌状态
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

-- 返回侦查范围内的目标(主动攻击型调用)
function AIComp:findTarget()
	local pos = cc.p(self.entity:getPosition())
	local targets = {}
	for _, enemy in pairs(self.enemyEntity) do
		if enemy.status ~= const.Status.die then
			ex, ey = enemy:getPosition()
			local dis = cc.pGetDistance(cc.p(ex, ey), pos)
			if dis < self.detectRange and enemy.hp > 0 then
				table.insert(targets, {["target"]=enemy, ["dis"]=dis})
			end
		end
	end

	local comp = function (a, b)
		return a.dis < b.dis
	end
	table.sort(targets, comp)
	local r = targets[1]
	if r ~= nil then
		return r.target
	else
		return nil
	end
end