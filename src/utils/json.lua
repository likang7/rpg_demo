local string = string
local table = table
local math = math
local ipairs = ipairs
local pairs = pairs
local type = type
-- local assert = assert
local tonumber = tonumber
-- 前向声明
local is_blank
local m_next_chr
local m_next_object
local m_next_string
local m_next_array
local m_next_number
local m_next_true
local m_next_false
local m_next_null
local m_next_value
local m_current_chr
local u_is_array
local u_unmarshal_value
local u_unmarshal_string

local function Marshal(json_str) 
	-- Args:
	--		json_str: json字符串
	-- Return:
	--		lua_val: 对应的lua数据结构
	-- example:
	--		lua_val = json.Marshal('{"number": 1.24, "mixed":["array", [true, null, false]]}')
	--		lua_val -> {number=1.24, mixed={"array", {true, nil, false}}} 
	local lua_val = {}
	local len = string.len(json_str)
	local idx = 0
	
	lua_val, _, error_type = m_next_value(json_str, idx, len)

	return lua_val, error_type
end

local function Unmarshal(lua_val) 
	-- Args:
	--		lua_val: lua基本数据结构
	-- Return:
	--		json_str: 对应的json字串
	-- example:
	--		json_str = json.Unmarshal({number=1.24, mixed={"array", {true, nil, false}}})
	--		print(json_str) -> {"mixed":["array",[true,null,false]],"number":1.24}
	json_str = u_unmarshal_value(lua_val)
	return json_str
end

function u_unmarshal_value(lua_val)
	local json_str = nil
	val_type = type(lua_val)
	if lua_val == nil then
		json_str = "null"
	elseif val_type == 'boolean' then
		json_str = tostring(lua_val)
	elseif val_type == 'string' then
		json_str = u_unmarshal_string(lua_val)
	elseif val_type == 'number' then
		json_str = tostring(lua_val)
	elseif val_type == 'table' then
		local is_array, maxn = u_is_array(lua_val)
		json_str = {}
		if is_array and maxn > 0 then
			for i = 1, maxn do
				json_str[i] = u_unmarshal_value(lua_val[i])
			end
			json_str = '[' .. table.concat(json_str, ',') .. ']'
		else
			for k, v in pairs(lua_val) do
				table.insert(json_str, 
					u_unmarshal_string(k) .. ':' .. u_unmarshal_value(v))
			end
			json_str = '{' .. table.concat(json_str, ',') .. '}'
		end
	end
	return json_str
end

local CHR2ESCAPE = {
	['"'] = '\\"',
	["'"] = "\\'",
	['\\'] = '\\\\',
	['/'] = '\\/',
	['\b'] = '\\b',
	['\f'] = '\\f',
	['\n'] = '\\n',
	['\r'] = '\\r',
	['\t'] = '\\t',
}

local function utf82unicode(s)
	-- utf8编码转换为unicode, 只处理2位和3位的
	local t = {}
	local len = string.len(s)
	for i = 1, len do
		local chr = string.sub(s, i, i)
		local n = string.byte(chr)
		if bit32.band(n, 0x80) == 0 then
			table.insert(t, chr)
		elseif bit32.band(n, 0xe0) == 0xc0 then
			-- 110xxxxx 10xxxxx
			i = i + 1
			local n2 = string.byte(s, i)
			n = bit32.lshift(bit32.band(n, 0x1f), 6)
			n2 = bit32.band(n2, 0x3f)
			table.insert(t, string.format([[\u%04x]], n+n2))
		elseif bit32.band(n, 0xf0) == 0xe0 then
			--1110xxxx 10xxxxxx 10xxxxxx
			local n2 = string.byte(s, i+1)
			local n3 = string.byte(s, i+2)
			i = i + 2
			n = bit32.lshift(bit32.band(n, 0x0f), 12)
			n2 = bit32.lshift(bit32.band(n2, 0x3f), 6)
			n3 = bit32.band(n3, 0x3f)
			table.insert(t, string.format([[\u%04x]],n+n2+n3))
		end
	end
	return table.concat(t, "")
end

function u_unmarshal_string(s)
	-- 接受lua字符串, 处理转义符和\x转为json 字符串格式
	s = string.gsub(s, '["\\/\b\f\n\r\t]', CHR2ESCAPE)
	return '"' .. utf82unicode(s) .. '"'
end

function u_is_array(t)
	-- 检查一个table是否只包含正数的key
	-- Args: table
	-- Return:
	-- 		boolean: is_array
	--  	maxn: 最大非nil的正数索引
	local maxn = 0
	for k, _ in pairs(t) do
		if not (type(k) == 'number' and k >= 1 and math.floor(k) == k) then
			return false, 0
		end
		if k > maxn then
			maxn = k
		end
	end
	return true, maxn
end

function  m_next_value(json_str, idx, len)
	local chr
	chr, idx = m_next_chr(json_str, idx, len, true)

	local lua_val = nil
	local error_type = nil
	if chr == '{' then
		lua_val, idx, error_type = m_next_object(json_str, idx, len)
	elseif chr == '[' then
		lua_val, idx, error_type = m_next_array(json_str, idx, len)
	elseif string.find("-0123456789", chr) ~= nil then
		lua_val, idx, error_type = m_next_number(json_str, idx, len)
	elseif chr == '"' then
		lua_val, idx, error_type = m_next_string(json_str, idx, len)
	elseif chr == 't' then
		lua_val, idx, error_type = m_next_true(json_str, idx, len)
	elseif chr == 'f' then
		lua_val, idx, error_type = m_next_false(json_str, idx, len)
	elseif chr == 'n' then
		lua_val, idx, error_type = m_next_null(json_str, idx, len)
	elseif chr ~= ',' then
		lua_val, idx, error_type = nil, -1, string.format('unexcepted seperator "%s" when parsing value', chr)
	end

	return lua_val, idx, error_type
end

function m_next_object(json_str, idx, len)
	-- 解析形如 {"string":"value",...}串
	-- assert(m_current_chr(json_str, idx) == '{')
	local res = {}
	local key = nil
	local value = nil
	local chr
	local error_type = nil
	while idx <= len do
		chr, idx = m_next_chr(json_str, idx, len, true)

		if chr == '}' then
			return res, idx
		elseif chr == '"' then
			key, idx, error_type = m_next_string(json_str, idx, len)
			if error_type ~= nil then break end
		elseif chr == ':' then
			if key == nil then
				error_type = 'key == null when parsing object.'
				break
			end
			value, idx, error_type = m_next_value(json_str, idx, len)
			if error_type ~= nil then break end
			res[key] = value
			key = nil
		elseif chr == ',' then
			if key ~= nil then
				error_type = 'key/value pair not found when parsing object.'
				break
			end
		else
			error_type = string.format('unexcepted seperator "%s" when parsing object.', chr)
			break
		end
	end
	
	if error_type == nil then
		error_type = 'object end "}" not found when parsing object.'
	end
	return nil, -1, error_type
end

function m_next_array(json_str, idx, len)
	-- 解析形如 [value, .. , value]的串
	-- assert(m_current_chr(json_str, idx) == '[')
	local res = {}
	local chr
	local value
	local cnt = 1
	local error_type
	while idx <= len do
		chr, idx = m_next_chr(json_str, idx, len, true)
		-- assert(chr ~= nil)

		if chr == ']' then
			return res, idx		
		elseif chr == ',' then
			value, idx, error_type = m_next_value(json_str, idx, len)
			if error_type ~= nil then break end
			res[cnt] = value
			cnt = cnt + 1
		else
			value, idx, error_type = m_next_value(json_str, idx - 1, len)
			if error_type ~= nil then break end
			res[cnt] = value
			cnt = cnt + 1
		end
	end

	if error_type == nil then
		error_type = 'array end "]" not found when parsing array.'
	end
	return nil, -1, error_type
end

local NUMBERIC_CHRS = '+-0123456789.eE'
function m_next_number(json_str, idx, len)
	-- assert(string.find(NUMBERIC_CHRS, m_current_chr(json_str, idx))~=nil)
	local res = {}
	local chr = m_current_chr(json_str, idx)
	local error_type = nil
	table.insert(res, chr)
	while idx <= len do
		chr, idx = m_next_chr(json_str, idx, len, true)
		if(string.find(NUMBERIC_CHRS, chr) == nil) then
			break
		end
		table.insert(res, chr)
	end
	-- assert(idx <= len, 'unexpected end parsing number')
	res = table.concat(res, "")

	local n = tonumber(res)
	if n == nil then
		error_type = 'failed to get number when parsing number.'
		return nil, -1, error_type
	end
	return n, idx - 1
end

function m_next_true(json_str, idx, len)
	-- assert(m_current_chr(json_str, idx)=='t')
	local true_str = 'true'
	local str = string.sub(json_str, idx, idx + string.len(true_str) - 1)

	if str ~= true_str then 
		return nil, -1, string.format('get "%s" when parsing true', str)
	end
	return true, idx + string.len(true_str) - 1
end

function m_next_false(json_str, idx, len)
	-- assert(m_current_chr(json_str, idx)=='f')
	local false_str = 'false'
	local str = string.sub(json_str, idx, idx + string.len(false_str) - 1)
	if str ~= false_str then 
		return nil, -1, string.format('get "%s" when parsing false', str)
	end
	return false, idx + string.len(false_str) - 1
end

function m_next_null(json_str, idx, len)
	-- assert(m_current_chr(json_str, idx)=='n')
	local null_str = 'null'
	local str = string.sub(json_str, idx, idx + string.len(null_str) - 1)
	if str ~= null_str then 
		return nil, -1, string.format('get "%s" when parsing null', str)
	end
	return nil, idx + string.len(null_str) - 1
end

local ESCAPE2CHR = {
	['\"'] = '\"',
	['\\'] = '\\',
	['/'] = '/',
	['b'] = '\b',
	['f'] = '\f',
	['n'] = '\n',
	['r'] = '\r',
	['t'] = '\t',
}

local function unicode2utf8(n_unicode)
	local res = ""
	local error_type = nil
	if n_unicode < 0x80 then
		--0xxx xxxx
		res = string.char(n_unicode)
	elseif n_unicode < 0x800 then
		--110xxxxx 10xxxxxx
		res = string.char(0xc0 + bit32.rshift(n_unicode, 6), 
			0x80 + bit32.band(n_unicode, 0x3f))
	elseif n_unicode < 0x10000 then
		--1110xxxx 10xxxxxx 10xxxxxx
		res = string.char(0xe0 + bit32.rshift(n_unicode, 12), 
			0x80 + bit32.rshift(bit32.band(n_unicode, 0x0fff), 6), 
			0x80 + bit32.band(n_unicode, 0x3f))
	else
		error_type = string.format("cannot convert 0x%x to utf-8.", n_unicode)
	end

	return res, error_type
end

function m_next_string(json_str, idx, len)
	-- assert(m_current_chr(json_str, idx) == '"')
	local end_chr = '"'
	local chr
	local error_type = nil
	chr, idx = m_next_chr(json_str, idx, len, false)
	local res = {}
	while idx <= len and chr ~= end_chr do
		if chr == '\\' then
			chr, idx = m_next_chr(json_str, idx, len, false)
			if chr == 'u' then
				local n_unicode = string.sub(json_str, idx + 1, idx + 4)
				idx = idx + 4
				n_unicode = tonumber(n_unicode, 16)
				local str_utf_8
				str_utf_8, error_type = unicode2utf8(n_unicode)
				if error_type ~= nil then break end
				table.insert(res, str_utf_8)
			else
				chr = ESCAPE2CHR[chr]
				if chr == nil then
					error_type = string.format(
						'cannot handle escape "\\%s" when parsing string.', chr) 
					break
				end
				table.insert(res, chr)
			end
		else
			table.insert(res, chr)
		end
		chr, idx = m_next_chr(json_str, idx, len, false)
	end

	if idx > len then
		error_type = 'failed to reach " when pasing string.'
	end
	if error_type ~= nil then
		return nil, -1, error_type
	end
	return table.concat(res, ''), idx
end

--非字符串中碰到直接跳过的字符
local BLANKS = {[" "]=true, ["\t"]=true, ["\r"]=true, ["\n"]=true, ["\f"]=true, ["\v"]=true, ["\\"]=true}
function is_blank(chr)
	return BLANKS[chr] ~= nil
end

function m_current_chr(json_str, idx)
	return string.sub(json_str, idx, idx)
end

function m_next_chr(json_str, idx, len, jump_blanks)
	len = len or string.len(json_str)
	if jump_blanks == nil then
		jump_blanks = true
	end

	if idx >= len then
		return nil, len + 1
	end

	idx = idx + 1
	local chr = string.sub(json_str, idx, idx)
	while idx < len and (jump_blanks and is_blank(chr)) do
		idx = idx + 1
		chr = string.sub(json_str, idx, idx)
	end
	return chr, idx
end

return {
	Marshal = Marshal,
	Unmarshal = Unmarshal
}
