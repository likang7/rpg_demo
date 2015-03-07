local const = require "const"
local Globals = require "model.Globals"
local helper = require "utils.helper"

GameUILayer = class("GameUILayer",
	function ()
		return cc.Layer:create()
	end
)

GameUILayer.__index = GameUILayer

function GameUILayer:create(dict)
	local layer = GameUILayer.new()
	layer:init(dict)

	return layer
end

function GameUILayer:init(dict)
	self:initUI(dict)
end

function GameUILayer:initUI(dict)
    self.ui = cc.CSLoader:createNode("gameUI.csb")
    self:addChild(self.ui, const.DISPLAY_PRIORITY.UI)

    local panel = self.ui:getChildByName("InfoPanel")
    local saveRecordBtn = panel:getChildByName("saveRecordBtn")

    local responseLabel = panel:getChildByName("responseLabel")
    local onSaveRecordClick = function ()
        Globals.gameScene:getGameLayer():saveRecord()

        responseLabel:setVisible(true)
        responseLabel:setOpacity(255)

        local tag = 22
        responseLabel:stopActionByTag(tag)
        local act = helper.createHintMsgAction(responseLabel)
        act:setTag(tag)

        responseLabel:runAction(act)
    end
    saveRecordBtn:addClickEventListener(onSaveRecordClick)

    local returnBtn = panel:getChildByName("returnBtn")
    returnBtn:setTitleText("回主界面")
    local onReturnClick = function()
        require "WelcomeScene"
        local scene = WelcomeScene:create()
        cc.Director:getInstance():replaceScene(scene)
    end
    returnBtn:addClickEventListener(onReturnClick)

    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames(const.HEAD_ICON_PLIST)

    self:updateHeroInfo() 
end

function GameUILayer:step(dt)
	self:updateHeroInfo()
end

function GameUILayer:updateHeroInfo()
    local ui = self.ui

    local panel = ui:getChildByName("InfoPanel")
    local heroInfoPanel = panel:getChildByName("heroInfo")

    local heroNameLabel = heroInfoPanel:getChildByName("heroName")
    heroNameLabel:setString(Globals.player.name)

    local heroLevelLabel = heroInfoPanel:getChildByName("heroLevel")
    heroLevelLabel:setString('Lv.' .. Globals.player.level)

    local expLabel = heroInfoPanel:getChildByName("expLabel")
    expLabel:setString(Globals.player.exp)

    local coinLabel = heroInfoPanel:getChildByName("coinLabel")
    coinLabel:setString(Globals.player.coin)

    local heroData = Globals.player:getHeroData()
    self:updateEntityInfo(heroInfoPanel, heroData)
   
    local monsterInfoPanel = panel:getChildByName("monsterInfo")
    local gameLayer = Globals.gameScene:getGameLayer()
    local target = gameLayer:getPlayerEntity():getTarget()
    if target == nil then
        monsterInfoPanel:setVisible(false)
    else 
        local targetData = target:getData()
        self:updateEntityInfo(monsterInfoPanel, targetData)
        local heroNameLabel = monsterInfoPanel:getChildByName("heroName")
        heroNameLabel:setString(targetData.name)
        local heroLevelLabel = monsterInfoPanel:getChildByName("heroLevel")
        heroLevelLabel:setString('Lv.' .. targetData.level)
        monsterInfoPanel:setVisible(true)
    end
end

function GameUILayer:updateEntityInfo(panel, info)
    local heroHead = panel:getChildByName("heroHead")
    heroHead:loadTexture(info.headIcon, ccui.TextureResType.plistType)

    local attackLabel = panel:getChildByName("attackLabel")
    attackLabel:setString(math.floor(info.atk))

    local defenseLabel = panel:getChildByName("defenseLabel")
    defenseLabel:setString(math.floor(info.def))

    local hpLabel = panel:getChildByName("hpLabel")
    hpLabel:setString(math.floor(info.hp))

    local criticalLabel = panel:getChildByName("criticalLabel")
    criticalLabel:setString(math.floor(info.criRate * 100) .. '%')

    local antiCriticalLabel = panel:getChildByName("antiCriticalLabel")
    antiCriticalLabel:setString(math.floor(info.antiCriRate * 100) .. '%')
end

