:: arg[1]:csv·��, arg[2]:lua���·��, arg[3]:����
set CSV_ROOT=../../comment/sheet/
set LUA_ROOT=../../src/data/

lua csv2lua.lua %CSV_ROOT%item.csv %LUA_ROOT%itemData.lua itemID

pause