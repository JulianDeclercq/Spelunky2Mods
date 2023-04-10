meta.name = '__JULLE DEVELOPMENT'
meta.version = '1.0'
meta.description = ''
meta.author = 'Jools'

local skip = { World = 5, Level = 3, Theme = THEME.TIDE_POOL }
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
    { 0,                                 "None" },
    { ENT_TYPE.ITEM_JETPACK,             "Jetpack" },
    { ENT_TYPE.ITEM_VLADS_CAPE,          "Vlad's Cape" },
    { ENT_TYPE.ITEM_CAPE,                "Cape" },
    { ENT_TYPE.ITEM_HOVERPACK,           "Hoverpack" },
    { ENT_TYPE.ITEM_TELEPORTER_BACKPACK, "Telepack" },
    { ENT_TYPE.ITEM_POWERPACK,           "Powerpack" },
}

local backwearOptions = ""
for _, backwear in pairs(backwear) do
    backwearOptions = backwearOptions .. backwear[2] .. "\0"
end
register_option_combo(OrderedName("backwear"), "Backwear", "", backwearOptions .. "\0", 2)

register_option_int(OrderedName("bombs"), "Bombs", "", 4, 1, 99)
register_option_int(OrderedName("ropes"), "Ropes", "", 4, 1, 99)
register_option_bool(OrderedName("bomb_paste"), "Bomb Paste", "", false)
register_option_bool(OrderedName("pitchers_mitt"), "Pitcher's Mitt", "", false)
register_option_bool(OrderedName("climbing_gloves"), "Climbing Gloves", "", false)

set_callback(function()
    if state.loading == 1 and state.screen_next == ON.LEVEL
        and state.world_next == 1 and state.level_next == 1 and state.theme_next == THEME.DWELLING then
        state.world_next = skip.World
        state.level_next = skip.Level
        state.theme_next = skip.Theme

        -- for instant restart
        state.world_start = skip.World
        state.level_start = skip.Level
        state.theme_start = skip.Theme
    end
end, ON.LOADING)

set_callback(function()
    if state.world ~= skip.World and state.level ~= skip.Level then
        return
    end

    local player = get_player(1, false)

    --put the player on top the idol
    player:set_position(22.5, 81)

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

    local selectedBackwear = backwear[options[OrderedName("backwear")]][1]
    if selectedBackwear > 0 then
        pick_up(player.uid, spawn(selectedBackwear, 0, 0, LAYER.PLAYER, 0, 0))
    end
end, ON.LEVEL)
