const = {}

const.TILESIZE = 32

const.Direction = {S=0, WS=1, W=2, NW=3, N=4, NE=5, E=6, ES=7}

local d = const.Direction

const.DiagDirection = {WS=1, NW=3, NE=5, ES=7}

const.FullToDiagDir = {	[d.S]=7, [d.WS]=1, 
					[d.W]=1, [d.NW]=3, 
					[d.N]=3, [d.NE]=5,
					[d.E]=5, [d.ES]=7}

const.DirectionToVec = {  [d.S]={0, -1}, [d.WS]={-1, -1}, 
                    [d.W]={-1, 0}, [d.NW]={-1, 1}, 
                    [d.N]={0, 1}, [d.NE]={1, 1}, 
                    [d.E]={1, 0}, [d.ES]={1, -1}}

const.Status = {idle=0, run=1, attack=2, hurt=3, dying=4, die=5}

const.ControlType = {Keyboard=0, Click=1}

const.LifeState = {Alive=0, Protected=1, Die=3}

return const