local json = require("utils.json")
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

function GameRecorder:getHeroInfo()
	return self.record.heroInfo
end

function GameRecorder:getPlayerInfo()
	return self.record.playerInfo
end

function GameRecorder:init()
	local jsonStr = self:loadRecord()

	self.record = json.Marshal(jsonStr)
end

function GameRecorder:loadRecord()
	local file = io.open(self.recordPath, 'r')
	local jsonStr = nil

	if file == nil then
		self.isNewPlayer = true

		file = io.open(const.DEFAULT_RECORD)
		if file == nil then
			error("cannot read data through " .. const.DEFAULT_RECORD)
		else
			jsonStr = file:read('*a')
			file:close()
		end
	else
		self.isNewPlayer = false
		jsonStr = file:read('*a')
		file:close()
	end

	assert(jsonStr ~= nil and jsonStr ~= '')
	return jsonStr
end

function GameRecorder:saveRecord()
	-- local file = io.open(self.recordPath, 'w')
	-- if file == nil then
	-- 	os.execute("mkdir " .. const.RECORD_DIR)
	-- 	file = io.open(const.RECORD_PATH, 'w')
	-- 	if file == nil then
	-- 		error("cannot create record file " .. const.RECORD_PATH)
	-- 	end
	-- end
	-- print('bit32', bit32)
	-- print(1<<2)
	-- local jsonStr = json.Unmarshal(self.record)
	-- print(bit32, jsonStr)
	-- file:write(jsonStr)
	-- file:flush()
	-- file:close()
end