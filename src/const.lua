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

const.DEFAULT_FONT = "fonts/Marker Felt.ttf"

const.BLOCK_TYPE = {BLOCK=1, NPC=2}

const.RECORD_DIR = "record"
const.RECORD_PATH = const.RECORD_DIR .. "/record.json"
const.DEFAULT_RECORD = "res/default_record.json"

const.DISPLAY_PRIORITY = {UI=80, Conversation=70, Shop=64, JumpWord=30, Sky=20, Hero=10, NPC=8, Monster=6, Item=4}

const.GAME_STATE = {Playing=0, Shopping=1, Talking=2}

const.SHOP_PRICE = 30
const.SHOP_ITEM = {Atk=5, Def=5, Hp=100}

const.ITEM_TYPE = {Undefined=0, Atk=1, Def=2, Hp=3, Critial=4, Block=5, Coin=6}

const.TILEMAP_TYPE = {Transfer=1, Hero=2, NPC=3, Item=4, Monster=5}

const.ENTITY_TYPE = {Hero=1, NPC=2, Monster=3}

const.SHOP_TYPE = {CoinShop=1, ExpShop=2}

const.HERO_ID = 1000

const.COST_TYPE = {Coin=1, Exp=2}

const.GOODS_FUNC = {Level=0, Atk=1, Def=2, Hp=3}

const.HEAD_ICON_PLIST = 'headIcon.plist'

const.MUSIC_ROOT = 'music/'
const.EFFECT_ROOT = 'effect/'
const.MAP_ROOT = 'map/'

const.ITEM_OBTAIN_EFFECT_PATH = const.EFFECT_ROOT .. 'obtain_item.wav'

return const