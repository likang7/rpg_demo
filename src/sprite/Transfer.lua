
Transfer = class("Transfer")--,
	-- function (  )
		-- return cc.Node:create()
	-- end)

Transfer.__index = Transfer

function Transfer:create(dict)
	local transfer = Transfer.new()
	transfer:init(dict)

	return transfer
end

function Transfer:init(dict)
	self.rect = dict.rect
	-- self:retain()
	self.dir = dict.dir
end