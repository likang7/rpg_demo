:: arg[1]:csv路径, arg[2]:lua输出路径, arg[3]:主键
set XLSXFilePath=../../comment/gameCouple-p1.xlsx 
set CSV_ROOT=../../comment/sheet/
set LUA_ROOT=../../src/data/

python xlsx2csv.py -a %XLSXFilePath% %CSV_ROOT%

lua csv2lua.lua %CSV_ROOT%item.csv %LUA_ROOT%itemData.lua itemID

lua csv2lua.lua %CSV_ROOT%role.csv %LUA_ROOT%roleData.lua roleID

lua csv2lua.lua %CSV_ROOT%flash.csv %LUA_ROOT%flashData.lua flashID 

lua csv2lua.lua %CSV_ROOT%shop.csv %LUA_ROOT%shopData.lua shopID 

lua csv2lua.lua %CSV_ROOT%goods.csv %LUA_ROOT%goodsData.lua goodsID

lua csv2lua.lua %CSV_ROOT%conversation.csv %LUA_ROOT%conversationData.lua conversationID

::python ansi2utf8.py %LUA_ROOT%
pause