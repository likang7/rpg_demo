
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
    spriteFrameCache:addSpriteFrames("bgj-run.plist")
    local spriteSheet = cc.SpriteBatchNode:create("bgj-run.png")
    
    -- local function createBGJ()
    --     local bgjFrames = {}
    --     for i = 0, 3 do
    --         table.insert(bgjFrames, xxx)
    --     end
    -- end
    
    local function createPlayer()
        local sprite = cc.Sprite:createWithSpriteFrame(spriteFrameCache:getSpriteFrame("bgj-run-00.tga"))
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
        local function tick()
            local px, py = player:getPosition()
            local tx, ty = convertToTiledSpace(px, py, tilemap)
            local gid = blockLayer:getTileGIDAt(cc.p(tx, ty))
            if(gid ~= 0) then
                player:stopAllActions()
                player:setPosition(lastx, lasty)
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

        local function setPlayerPosition(x, y)
            -- player:setPosition(x, y)
            local distance = cc.pDistanceSQ(cc.p(player:getPosition()), cc.p(x,y)) ^ 0.5
            local speed = 250.0
            local moveTo = cc.MoveTo:create(distance/speed, cc.p(x, y))
            player:stopAllActions()
            player:runAction(moveTo)
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

            setPlayerPosition(px, py)
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
