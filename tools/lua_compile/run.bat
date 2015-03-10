set KEY=gzlikang
set SIGN=gzlikangXXTEA
set SRC=../../src
set DST=../../src_c

cocos luacompile -s %SRC% -d %DST% -e -k %KEY% -b %SIGN%

pause