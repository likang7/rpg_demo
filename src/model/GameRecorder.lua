local json = json
local pairs = pairs
local const = require("const")

GameRecorder = class("GameRecorder")

GameRecorder.__index = GameRecorder

function GameRecorder:ctor()
	self.recordPath = const.RECORD_PATH
	self.isNewPlayer = true
	self.record = {}
end

function GameRecorder:create()
	local recorder = GameRecorder.new()
	recorder:init()
	return recorder
end

function GameRecorder:getStageInfo()
	return self.record.stageInfo
end

function GameRecorder:getStageState(stageId)
	local stageState = self:getStageInfo().stageState
	local state = stageState[stageId]
	return state
end

function GameRecorder:updateStageState(stageId, stageState)
	local stageInfo = self:getStageInfo()
	stageInfo.curStageId = stageId
	if stageId > stageInfo.maxStageId then
		stageInfo.maxStageId = stageId
	end

	stageInfo.stageState[stageId] = stageState
end

function GameRecorder:getHeroInfo()
	return self.record.heroInfo
end

function GameRecorder:updateHeroInfo(info)
	local heroInfo = self:getHeroInfo()

	for k, v in pairs(info) do
		heroInfo[k] = v 
	end
end

function GameRecorder:getPlayerInfo()
	return self.record.playerInfo
end

function GameRecorder:updatePlayerInfo(info)
	local playerInfo = self:getPlayerInfo()

	for k, v in pairs(info) do
		playerInfo[k] = v 
	end
end

function GameRecorder:init()
	local jsonStr = self:loadRecord()

	self.record = json.decode(jsonStr)
end

function GameRecorder:initWithDefaultRecord()
	local jsonStr = self:loadDefaultRecord()

	self.record = json.decode(jsonStr)
end

function GameRecorder:loadDefaultRecord( )
	self.isNewPlayer = true
	local file = io.open(const.DEFAULT_RECORD)
	local jsonStr = nil
	if file == nil then
		error("cannot read data through " .. const.DEFAULT_RECORD)
	else
		jsonStr = file:read('*a')
		file:close()
	end
	assert(jsonStr ~= nil and jsonStr ~= '')
	return jsonStr
end

function GameRecorder:loadRecord()
	local file = io.open(self.recordPath, 'r')
	local jsonStr = nil

	if file == nil then
		return self:loadDefaultRecord()
	else
		self.isNewPlayer = false
		jsonStr = file:read('*a')
		file:close()
		assert(jsonStr ~= nil and jsonStr ~= '')
		return jsonStr
	end
end

function GameRecorder:saveRecord()
	local file = io.open(self.recordPath, 'w')
	if file == nil then
		os.execute("mkdir " .. const.RECORD_DIR)
		file = io.open(const.RECORD_PATH, 'w')
		if file == nil then
			error("cannot create record file " .. const.RECORD_PATH)
		end
	end

	local jsonStr = json.encode(self.record)
	file:write(jsonStr)
	file:flush()
	file:close()
end