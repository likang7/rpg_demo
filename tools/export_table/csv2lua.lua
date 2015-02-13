local csv = require "csv"
local tonumber = tonumber
local type = type
local pairs = pairs
local assert = assert
local string = string
local io = io

-- 返回table，注意不能有嵌套，除分割符号外不能有额外的','
local function str2table(s)
    local t = {}
    local function repl(w)
        if tonumber(w) ~= nil then
            w = tonumber(w)
        end
        table.insert(t, w)
    end
    string.gsub(s,  '[^,%[%]]+', repl)
    return t
end

local function csv2table(inPath, key)
    local file = io.open(inPath, 'r')
    assert(file ~= nil, "cannot open file " .. inPath)

    -- 跳过第一行注释
    file:read()
    fileContent = file:read('*a')
    file:close()

    local f = csv.openstring(fileContent, {header=true,filename='xx'})

    local t = {}
    for fields in f:lines() do 
        local mainkey = tonumber(fields[key])
        assert(mainkey ~= nil, "main key not exist or is not number")
        t[mainkey] = {}
        for k, v in pairs(fields) do
            if v == '' or k == 'comment' then
                v = nil
            elseif string.find(v, '^%[.*%]$') ~= nil then
                -- 形如[v1, v2]的
                v = str2table(v)
            elseif tonumber(v) ~= nil then
                v = tonumber(v)
            end
            t[mainkey][k] = v
        end
    end

    f:close()
    return t
end

local function unmarshal_value(value)
    local str = nil
    val_type = type(value)

    if val_type == 'boolean' or val_type == "number" or val_type == nil then
        str = tostring(value)
    elseif val_type == 'string' then
        str = '[[' .. value .. ']]'
    elseif val_type == 'number' then
        str = tostring(value)
    elseif val_type == 'table' then
        str = {}
        for i = 1, #value do
            str[i] = u_unmarshal_value(value[i])
        end
        str = '{' .. table.concat(str, ', ') .. '}'
    end
    return str
end

local function table2str(t)
    str = {}
    for k, v in pairs(t) do 
        k = '["' .. k .. '"]'
        v = unmarshal_value(v)
        table.insert(str, k .. ' = ' .. v)
    end
    str = table.concat(str, ", ")
    return '{' .. str ..'}'
end

local function table2lua(t, outPath)
    local file = io.open(outPath, 'w')
    file:write('return {\n')
    for id, list in pairs(t) do
        str = string.format('\t[%d] = %s', id, table2str(list))
        file:write(str)
        file:write(',\n')
    end
    file:write('}')
    file:flush()
    file:close()
end

local function csv2lua(inPath, outPath, key)
    local t = csv2table(inPath, key)
    table2lua(t, outPath)
end

if #arg == 3 then
    local inPath = arg[1]
    local outPath = arg[2]
    local key = arg[3]
    csv2lua(inPath, outPath, key)
end

return {csv2lua = csv2lua}
