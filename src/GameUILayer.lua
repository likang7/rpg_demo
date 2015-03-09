local const = require "const"
local Globals = require "model.Globals"
local helper = require "utils.helper"
local StageData = require "data.stageData"

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
        Globals.gameScene:transferToWelcomeScene()
    end
    returnBtn:addClickEventListener(onReturnClick)

    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames(const.HEAD_ICON_PLIST)

    self:updateHeroInfo() 

    self.curStageId = nil
    
    self:updateStageInfo()
end

function GameUILayer:step(dt)
	self:updateHeroInfo()

    self:updateStageInfo()
end

function GameUILayer:updateStageInfo()
    local curStageId = Globals.player:getCurStageId() 
    if self.curStageId ~= curStageId then
        self.curStageId = curStageId
        local panel = self.ui:getChildByName("InfoPanel")
        local stageTitleLabel = panel:getChildByName("stageTitleLabel")
        local stageData = StageData[curStageId]
        stageTitleLabel:setString(stageData.stageName)
    end
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

    local s = {}
    table.insert(s, '生命:' .. math.floor(info.hp + 0.5))
    table.insert(s, '攻击:' .. math.floor(info.atk + 0.5))
    table.insert(s, '防御:' .. math.floor(info.def + 0.5))
    table.insert(s, string.format('暴击:%.1f%%', info.criRate))
    table.insert(s, string.format('防暴:%.1f%%', info.antiCriRate))
    
    s = table.concat(s, '\n')

    local heroPropLabel = panel:getChildByName("heroPropLabel")
    heroPropLabel:setString(s)
end

