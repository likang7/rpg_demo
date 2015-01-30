
cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")

-- CC_USE_DEPRECATED_API = true
require "cocos.init"

-- cclog
cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local math = math
local Direction = {S=0, WS=1, W=2, NW=3, N=4, NE=5, E=6, ES=7}

local function calDegree(p1, p2)
    local h = p2.y - p1.y
    local w = p2.x - p1.x
    if w == 0 then
        if h ~= 0 then
            return h/math.abs(h) * 90
        else
            return nil
        end
    end

    local deg = math.deg(math.atan(math.abs(h/w)))

    if w >= 0 and h >= 0 then
        deg = 270 - deg
    elseif w <= 0 and h >= 0 then
        deg = 90 + deg
    elseif w <= 0 and h <= 0 then
        deg = 90 - deg
    else
        deg = 270 + deg
    end
    return (deg + 360) % 360
end

local function getDirectionByDegree(deg)
    local dir = nil

    if deg >= 22.5 and deg < 67.5 then
        dir = Direction.WS
    elseif deg >= 67.5 and deg < 112.5 then
        dir = Direction.W
    elseif deg >= 112.5 and deg < 157.5 then
        dir = Direction.NW
    elseif deg >= 157.5 and deg < 202.5 then
        dir = Direction.N
    elseif deg >= 202.5 and deg < 247.5 then
        dir = Direction.NE
    elseif deg >= 247.5 and deg < 292.5 then
        dir = Direction.E
    elseif deg >= 292.5 and deg < 337.5 then
        dir = Direction.ES
    else
        dir = Direction.S
    end

    return dir
end

local function _getDirection(p1, p2)
    local deg = calDegree(p1, p2)
    return getDirectionByDegree(deg)
end

local function createPlayerAnims(spriteFrameCache)
    runAnimates = {}
    for k, v in pairs(Direction) do
        local frames = {}
        for i = 0, 7 do
            -- print(string.format("bgj-run-%d%d.tga", v, i))
            table.insert(frames, spriteFrameCache:getSpriteFrame(string.format("bgj-run-%d%d.tga", v, i)))
        end
        local runAnimation = cc.Animation:createWithSpriteFrames(frames, 0.1)
        local runAnimate = cc.Animate:create(runAnimation)
        runAnimates[v] = runAnimate
    end

    return runAnimates
end

local function createStandFrames(spriteFrameCache)
    local frames = {}
    for k, v in pairs(Direction) do
        frames[v] = spriteFrameCache:getSpriteFrame(string.format("bgj-stand-%d0.tga", v))
    end
    return frames
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    -- initialize director
    local director = cc.Director:getInstance()
    local glview = director:getOpenGLView()
    if nil == glview then
        glview = cc.GLViewImpl:createWithRect("HelloLua", cc.rect(0,0,900,640))
        director:setOpenGLView(glview)
    end

    glview:setDesignResolutionSize(800, 600, cc.ResolutionPolicy.NO_BORDER)

    --turn on display FPS
    director:setDisplayStats(true)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)

    local schedulerID = 0
    --support debug
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or
       (cc.PLATFORM_OS_ANDROID == targetPlatform) or (cc.PLATFORM_OS_WINDOWS == targetPlatform) or
       (cc.PLATFORM_OS_MAC == targetPlatform) then
        cclog("result is ")
        --require('debugger')()

    end
    require "hello2"
    cclog("result is " .. myadd(1, 1))

    ---------------

    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()

    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames("bgj.plist")
    local spriteSheet = cc.SpriteBatchNode:create("bgj.png")
    local runAnimates = createPlayerAnims(spriteFrameCache)
    local standFrames = createStandFrames(spriteFrameCache)
    local function createPlayer()
        print('dsdsa', standFrames[Direction.S])
        local sprite = cc.Sprite:createWithSpriteFrame(standFrames[Direction.S])
        sprite:runAction(cc.RepeatForever:create(runAnimates[Direction.E]))
        return sprite
    end    

    -- add the moving dog
    local function createDog()
        local frameWidth = 105
        local frameHeight = 95

        -- create dog animate
        local textureDog = cc.Director:getInstance():getTextureCache():addImage("dog.png")
        local rect = cc.rect(0, 0, frameWidth, frameHeight)
        local frame0 = cc.SpriteFrame:createWithTexture(textureDog, rect)
        rect = cc.rect(frameWidth, 0, frameWidth, frameHeight)
        local frame1 = cc.SpriteFrame:createWithTexture(textureDog, rect)

        local spriteDog = cc.Sprite:createWithSpriteFrame(frame0)
        spriteDog.isPaused = false
        spriteDog:setPosition(origin.x, origin.y + visibleSize.height / 4 * 3)
--[[
        local animFrames = CCArray:create()

        animFrames:addObject(frame0)
        animFrames:addObject(frame1)
]]--

        local animation = cc.Animation:createWithSpriteFrames({frame0,frame1}, 0.5)
        local animate = cc.Animate:create(animation);
        spriteDog:runAction(cc.RepeatForever:create(animate))

        -- moving dog at every frame
        local function tick()
            if spriteDog.isPaused then return end
            local x, y = spriteDog:getPosition()
            if x > origin.x + visibleSize.width then
                x = origin.x
            else
                x = x + 1
            end

            spriteDog:setPositionX(x)
        end

        -- schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)

        return spriteDog
    end

    local function setViewPointCenter(x, y, map_w, map_h, scenelayer)
        local win_size = cc.Director:getInstance():getWinSize()

        local x = math.max(x, win_size.width / 2)
        local y = math.max(y, win_size.height / 2)

        newx = math.min(x, map_w - win_size.width / 2)
        newy = math.min(y, map_h - win_size.height / 2)
        
        viewx = win_size.width / 2 - newx
        viewy = win_size.height / 2 - newy

        scenelayer:setPosition(viewx, viewy)
    end

    local function convertToTiledSpace(x, y, tilemap)
        -- print('origin', x, y)
        local tileSize = tilemap:getTileSize()
        local tx = math.floor(x / tileSize.width)
        local mapHeight = tilemap:getMapSize().height * tileSize.height
        local ty = math.ceil((mapHeight - y) / tileSize.height)
        -- print('convert to', tx, ty)
        return tx, ty
    end

    -- create farm
    local function createLayerFarm()
        local layerFarm = cc.LayerColor:create(cc.c4b(255, 255, 255, 255))
        -- add in farm background
        local bg = cc.Sprite:create("scene.jpg")
        -- bg:setAnchorPoint(cc.p(0.5,0.5))
        bg:setPosition(origin.x + bg:getTextureRect().width/2, origin.y + visibleSize.height/2+32)
        layerFarm:addChild(bg)

        local tilemap = cc.TMXTiledMap:create("sample.tmx")
        tilemap:setPosition(origin.x, origin.y)
        layerFarm:addChild(tilemap)

        local blockLayer = tilemap:getLayer("block")
        blockLayer:setVisible(false)

        local objects = tilemap:getObjectGroup("object")
        local spawnPoint = objects:getObject("bornPoint")
        local x, y = spawnPoint["x"], spawnPoint["y"]
        
        local player = createPlayer()--cc.Sprite:create("Player.png")
        player:setAnchorPoint(cc.p(0.5, 0))
        spriteSheet:addChild(player)
        layerFarm:addChild(spriteSheet)

        -- local player = cc.Sprite:create("Player.png")
        -- layerFarm:addChild(player)
        player:setPosition(x, y)
        local map_w = tilemap:getMapSize().width * tilemap:getTileSize().width
        local map_h = tilemap:getMapSize().height * tilemap:getTileSize().height
        setViewPointCenter(x, y, map_w, map_h, layerFarm)

        local lastx = 0
        local lasty = 0
        local last_dir = Direction.S
        local function tick()
            local px, py = player:getPosition()
            local tx, ty = convertToTiledSpace(px, py, tilemap)
            local gid = blockLayer:getTileGIDAt(cc.p(tx, ty))
            if(gid ~= 0) then
                print('stop')
                player:stopAllActions()
                player:setPosition(lastx, lasty)
                player:setSpriteFrame(standFrames[last_dir])
            else
                lastx = px
                lasty = py
                setViewPointCenter(px, py, map_w, map_h, layerFarm)
            end
            -- local properties = tilemap:getPropertiesForGID(gid) 
            -- print(tostring(properties.collidable))  
            
        end

        schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)

        -- add moving dog
        local spriteDog = createDog()
        layerFarm:addChild(spriteDog)

        -- handing touch events
        local touchBeginPoint = nil
        local function onTouchBegan(touch, event)
            local location = touch:getLocation()
            cclog("onTouchBegan: %0.2f, %0.2f", location.x, location.y)
            touchBeginPoint = {x = location.x, y = location.y}
            spriteDog.isPaused = true
            -- CCTOUCHBEGAN event must return true
            return true
        end

        local function onTouchMoved(touch, event)
            -- local location = touch:getLocation()
            -- cclog("onTouchMoved: %0.2f, %0.2f", location.x, location.y)
            -- if touchBeginPoint then
            --     local cx, cy = layerFarm:getPosition()
            --     layerFarm:setPosition(cx + location.x - touchBeginPoint.x,
            --                           cy + location.y - touchBeginPoint.y)
            --     touchBeginPoint = {x = location.x, y = location.y}
            -- end
        end

        local function setPlayerPosition(x, y, dir)
            -- player:setPosition(x, y)
            local distance = cc.pDistanceSQ(cc.p(player:getPosition()), cc.p(x,y)) ^ 0.5
            local speed = 250.0
            local moveTo = cc.MoveTo:create(distance/speed, cc.p(x, y))
            local f = function ()
                player:stopAllActions()
                player:setSpriteFrame(standFrames[dir])
            end
            local cb = cc.CallFunc:create(f)
            local seq = cc.Sequence:create(moveTo, cb, nil)
            player:stopAllActions()
            local runAnimates = createPlayerAnims(spriteFrameCache)
            player:runAction(cc.RepeatForever:create(runAnimates[dir]))
            player:runAction(seq)
            last_dir = dir
        end

        local function onTouchEnded(touch, event)
            local location = touch:getLocation()
            -- cclog("onTouchEnded: %0.2f, %0.2f", location.x, location.y)
            touchBeginPoint = nil
            spriteDog.isPaused = false

            --
            location = layerFarm:convertToNodeSpace(location)
            local px, py = player:getPosition()
            local diff = cc.p(location.x - px, location.y - py)
            local mapSize = tilemap:getMapSize()
            local tileSize = tilemap:getTileSize()

            newx = math.floor(location.x / tileSize.width) * tileSize.width + tileSize.width / 2
            newy = math.floor(location.y / tileSize.height) * tileSize.height + tileSize.height / 2

            px = newx
            py = newy
            
            px = math.max(tilemap:getTileSize().width / 2, 
                math.min(px, mapSize.width * tileSize.width - tileSize.width / 2))
            py = math.max(tilemap:getTileSize().height / 2, 
                math.min(py, mapSize.height * tileSize.height - tileSize.height / 2))

            local dir = _getDirection(cc.p(player:getPosition()), cc.p(location.x, location.y))

            setPlayerPosition(px, py, dir)
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = layerFarm:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layerFarm)

        local function onNodeEvent(event)
           if "exit" == event then
               cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)
           end
        end
        layerFarm:registerScriptHandler(onNodeEvent)

        return layerFarm
    end


    -- create menu
    local function createLayerMenu()
        local layerMenu = cc.Layer:create()

        local menuPopup, menuTools, effectID

        local function menuCallbackClosePopup()
            -- stop test sound effect
            cc.SimpleAudioEngine:getInstance():stopEffect(effectID)
            menuPopup:setVisible(false)
        end

        local function menuCallbackOpenPopup()
            -- loop test sound effect
            local effectPath = cc.FileUtils:getInstance():fullPathForFilename("effect1.wav")
            effectID = cc.SimpleAudioEngine:getInstance():playEffect(effectPath)
            menuPopup:setVisible(true)
        end

        -- add a popup menu
        local menuPopupItem = cc.MenuItemImage:create("menu2.png", "menu2.png")
        menuPopupItem:setPosition(0, 0)
        menuPopupItem:registerScriptTapHandler(menuCallbackClosePopup)
        menuPopup = cc.Menu:create(menuPopupItem)
        menuPopup:setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2)
        menuPopup:setVisible(false)
        layerMenu:addChild(menuPopup)

        -- add the left-bottom "tools" menu to invoke menuPopup
        local menuToolsItem = cc.MenuItemImage:create("menu1.png", "menu1.png")
        menuToolsItem:setPosition(0, 0)
        menuToolsItem:registerScriptTapHandler(menuCallbackOpenPopup)
        menuTools = cc.Menu:create(menuToolsItem)
        local itemWidth = menuToolsItem:getContentSize().width
        local itemHeight = menuToolsItem:getContentSize().height
        menuTools:setPosition(origin.x + itemWidth/2, origin.y + itemHeight/2)
        layerMenu:addChild(menuTools)

        return layerMenu
    end

    -- play background music, preload effect
    local bgMusicPath = cc.FileUtils:getInstance():fullPathForFilename("background.mp3")
    cc.SimpleAudioEngine:getInstance():playMusic(bgMusicPath, true)
    local effectPath = cc.FileUtils:getInstance():fullPathForFilename("effect1.wav")
    cc.SimpleAudioEngine:getInstance():preloadEffect(effectPath)

    -- run
    local sceneGame = cc.Scene:create()
    sceneGame:addChild(createLayerFarm())
    -- sceneGame:addChild(createLayerMenu())

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(sceneGame)
    else
        cc.Director:getInstance():runWithScene(sceneGame)
    end

end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
