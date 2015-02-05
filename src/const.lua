Direction = {S=0, WS=1, W=2, NW=3, N=4, NE=5, E=6, ES=7}

DirectionToVec = {  [Direction.S]={0, -1}, [Direction.WS]={-1, -1}, 
                    [Direction.W]={-1, 0}, [Direction.NW]={-1, 1}, 
                    [Direction.N]={0, 1}, [Direction.NE]={1, 1}, 
                    [Direction.E]={1, 0}, [Direction.ES]={1, -1}}

Status = {idle=0, run=1, attack=2, hurt=3}