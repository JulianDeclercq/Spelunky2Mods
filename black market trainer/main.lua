meta.name = "__Julle dev"
meta.version = "1.0"
meta.description =
""
meta.author = "Jools"

local WORLD_JUNGLE = 2
local firstPossibleBlackMarketLevel = 2
local currentLevel = firstPossibleBlackMarketLevel

local blackMarket = { x = 30, y = 86 }

local orderPrefix = 1
local optionNameLookup = {}
function OrderedName(name)
    -- return existing
    local existing = optionNameLookup[name]
    if existing ~= nil then
        return existing
    end

    -- add new
    local orderedName = string.format("%03i_%s", orderPrefix, name)
    optionNameLookup[name] = orderedName
    orderPrefix = orderPrefix + 1
    return orderedName
end

local backwear <const> = {
    { ent_type = 0,                                 name = "None" },
    { ent_type = ENT_TYPE.ITEM_JETPACK,             name = "Jetpack" },
    { ent_type = ENT_TYPE.ITEM_CAPE,                name = "Cape" },
    { ent_type = ENT_TYPE.ITEM_HOVERPACK,           name = "Hoverpack" },
    { ent_type = ENT_TYPE.ITEM_TELEPORTER_BACKPACK, name = "Telepack" },
    { ent_type = ENT_TYPE.ITEM_POWERPACK,           name = "Powerpack" },
}

local heldItems <const> = {
    { ent_type = 0,                          name = "None" },
    { ent_type = ENT_TYPE.ITEM_SHOTGUN,      name = "Shotgun" },
    { ent_type = ENT_TYPE.ITEM_FREEZERAY,    name = "Freeze Ray" },
    { ent_type = ENT_TYPE.ITEM_MACHETE,      name = "Machete" },
    { ent_type = ENT_TYPE.ITEM_TELEPORTER,   name = "Teleporter" },
    { ent_type = ENT_TYPE.ITEM_METAL_SHIELD, name = "Metal Shield" },
    { ent_type = ENT_TYPE.ITEM_CROSSBOW,     name = "Crossbow" },
    { ent_type = ENT_TYPE.ITEM_BOOMERANG,    name = "Boomerang" },
    { ent_type = ENT_TYPE.ITEM_MATTOCK,      name = "Mattock" },
    { ent_type = ENT_TYPE.ITEM_CAMERA,       name = "Camera" },
    { ent_type = ENT_TYPE.ITEM_WEBGUN,       name = "Web gun" },
    { ent_type = ENT_TYPE.ITEM_HOUYIBOW,     name = "Hou Yi's Bow" },
}

function RedWhiteLerp(t)
    local from = { r = 139, g = 0, b = 0 }   -- red
    local to = { r = 255, g = 255, b = 255 } -- white

    local r = math.floor(from.r + (to.r - from.r) * t)
    local g = math.floor(from.g + (to.g - from.g) * t)
    local b = math.floor(from.b + (to.b - from.b) * t)

    return { r = r, g = g, b = b, a = 255 }
end

function Lerp(a, b, t)
    return a + (b - a) * t
end

function GenerateOptions(input)
    local options = ""
    for _, item in pairs(input) do
        options = options .. item.name .. "\0"
    end
    return options .. "\0"
end

register_option_combo(OrderedName("backwear"), "Backwear", "", GenerateOptions(backwear), 2)
register_option_combo(OrderedName("held_item"), "Held item", "", GenerateOptions(heldItems), 2)

register_option_int(OrderedName("money"), "Money", "", 20000, 0, 1000000)
register_option_int(OrderedName("bombs"), "Bombs", "", 4, 0, 99)
register_option_int(OrderedName("ropes"), "Ropes", "", 4, 0, 99)
register_option_bool(OrderedName("bomb_paste"), "Bomb Paste", "", false)
register_option_bool(OrderedName("pitchers_mitt"), "Pitcher's Mitt", "", false)
register_option_bool(OrderedName("climbing_gloves"), "Climbing Gloves", "", false)

set_callback(function()
    -- on going through the main door in camp
    if state.loading == 1 and state.screen_next == ON.LEVEL
        and state.world_next == 1 and state.level_next == 1 and state.theme_next == THEME.DWELLING then
        state.world_next = WORLD_JUNGLE
        state.level_next = firstPossibleBlackMarketLevel
        state.theme_next = THEME.JUNGLE

        -- for instant restart
        state.world_start = WORLD_JUNGLE
        state.level_start = firstPossibleBlackMarketLevel
        state.theme_start = THEME.JUNGLE
    end
end, ON.LOADING)

function GearPlayer()
    local player = get_player(1, false)
    player.inventory.money = options[OrderedName("money")]
    player.inventory.bombs = options[OrderedName("bombs")]
    player.inventory.ropes = options[OrderedName("ropes")]

    if options[OrderedName("bomb_paste")] then
        player:give_powerup(ENT_TYPE.ITEM_POWERUP_PASTE)
    end

    if options[OrderedName("pitchers_mitt")] then
        player:give_powerup(ENT_TYPE.ITEM_POWERUP_PITCHERSMITT)
    end

    if options[OrderedName("climbing_gloves")] then
        player:give_powerup(ENT_TYPE.ITEM_POWERUP_CLIMBING_GLOVES)
    end

    local selectedBackwear = backwear[options[OrderedName("backwear")]].ent_type
    if selectedBackwear > 0 then
        pick_up(player.uid, spawn(selectedBackwear, 0, 0, LAYER.PLAYER, 0, 0))
    end

    local selectedHeldItem = heldItems[options[OrderedName("held_item")]].ent_type
    if selectedHeldItem > 0 then
        pick_up(player.uid, spawn(selectedHeldItem, 0, 0, LAYER.PLAYER, 0, 0))
    end
end

set_callback(function()
    if state.world ~= WORLD_JUNGLE or state.theme ~= THEME.JUNGLE then
        return
    end

    if currentLevel == firstPossibleBlackMarketLevel then
        GearPlayer()
    end

    if test_flag(state.presence_flags, PRESENCE_FLAG.BLACK_MARKET) then
        local player = get_player(1, false)
        player:set_layer(LAYER.BACK)
        player:set_position(blackMarket.x, blackMarket.y)
    else
        -- warp to the next level and check for the black market there
        currentLevel = currentLevel + 1
        warp(WORLD_JUNGLE, currentLevel, THEME.JUNGLE)
    end
end, ON.LEVEL)

local lastAggro = 0
local currentAggro = 0
local drawBiggerDurationInSeconds = 2
local framesToDrawBigger = 0.0
local framesToDrawBiggerStart = 0.0 -- used to calculate progression in animation
local animationProgression = 0.0
set_callback(function(draw_ctx)
    local color = { r = 255, g = 255, b = 255, a = 255 } -- white
    local size = 25

    if framesToDrawBigger > 0 then
        color = RedWhiteLerp(animationProgression)
        size = Lerp(35, 25, animationProgression)
    end

    local text = F 'Shop keeper aggro {state.shoppie_aggro_next}'
    local w, h = draw_text_size(size, text)
    draw_ctx:draw_text(1 - w, -1 - h, size, text, rgba(color.r, color.g, color.b, color.a)) -- right bottom corner
    --draw_ctx:draw_text(1 - w, -1 - h, size, text, Color:lime():get_ucolor()) -- right bottom corner
end, ON.GUIFRAME)

set_callback(function()
    local engineFps = 60
    currentAggro = state.shoppie_aggro_next
    if currentAggro > lastAggro then
        framesToDrawBigger = drawBiggerDurationInSeconds * engineFps
        framesToDrawBiggerStart = framesToDrawBigger
        lastAggro = currentAggro
    end

    if framesToDrawBigger > 0 then
        framesToDrawBigger = framesToDrawBigger - 1
        animationProgression = 1 - (framesToDrawBigger / framesToDrawBiggerStart)
    else --reset animation progression
        --animationProgression = 0
    end
end, ON.GAMEFRAME)

set_callback(function()
    currentLevel = firstPossibleBlackMarketLevel
    lastAggro = 0
    currentAggro = 0
    framesToDrawBigger = 0.0
    framesToDrawBiggerStart = 0.0
    animationProgression = 0.0
end, ON.RESET)
