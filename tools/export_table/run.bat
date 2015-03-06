:: arg[1]:csv路径, arg[2]:lua输出路径, arg[3]:主键
set CSV_ROOT=../../comment/sheet/
set LUA_ROOT=../../src/data/

lua csv2lua.lua %CSV_ROOT%item.csv %LUA_ROOT%itemData.lua itemID

lua csv2lua.lua %CSV_ROOT%role.csv %LUA_ROOT%roleData.lua roleID

lua csv2lua.lua %CSV_ROOT%flash.csv %LUA_ROOT%flashData.lua flashID 

pause