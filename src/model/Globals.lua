
if Globals == nil then
	Globals = {}

	local Globals = Globals

	Globals.player = nil
	Globals.gameMap = nil

	local const = require "const"
	Globals.gameState = const.GAME_STATE.Playing

	Globals.gameScene = nil
end

local Globals = Globals

return Globals