Direction = {S=0, WS=1, W=2, NW=3, N=4, NE=5, E=6, ES=7}
DiagDirection = {WS=1, NW=3, NE=5, ES=7}

FullToDiagDir = {	[Direction.S]=7, [Direction.WS]=1, 
					[Direction.W]=1, [Direction.NW]=3, 
					[Direction.N]=3, [Direction.NE]=5,
					[Direction.E]=5, [Direction.ES]=7}

DirectionToVec = {  [Direction.S]={0, -1}, [Direction.WS]={-1, -1}, 
                    [Direction.W]={-1, 0}, [Direction.NW]={-1, 1}, 
                    [Direction.N]={0, 1}, [Direction.NE]={1, 1}, 
                    [Direction.E]={1, 0}, [Direction.ES]={1, -1}}

Status = {idle=0, run=1, attack=2, hurt=3, die=4}