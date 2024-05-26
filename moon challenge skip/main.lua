meta.name = "Sun Challenge Trainer"
meta.version = "1.0"
meta.description =
"Practise the Sun Challenge. Offers a variety of items to start with."
meta.author = "Jools"

local WORLD_SUNKEN_CITY = 7

-- If sun challenge hasn't spawned yet, the game will force spawn in the last possible level, so start there. (7-2 in case of the Sun challenge)
local targetLevel = 2

local backwear <const> = {
    { ent_type = 0,                                 name = "None" },
    { ent_type = ENT_TYPE.ITEM_JETPACK,             name = "Jetpack" },
    { ent_type = ENT_TYPE.ITEM_VLADS_CAPE,          name = "Vlad's Cape" },
    { ent_type = ENT_TYPE.ITEM_CAPE,                name = "Cape" },
    { ent_type = ENT_TYPE.ITEM_HOVERPACK,           name = "Hoverpack" },
    { ent_type = ENT_TYPE.ITEM_TELEPORTER_BACKPACK, name = "Telepack" },
    { ent_type = ENT_TYPE.ITEM_POWERPACK,           name = "Powerpack" },
}

local heldItems <const> = {
    { ent_type = 0,                             name = "None" },
    { ent_type = ENT_TYPE.ITEM_EXCALIBUR,       name = "Excalibur" },
    { ent_type = ENT_TYPE.ITEM_PLASMACANNON,    name = "Plasma Cannon" },
    { ent_type = ENT_TYPE.ITEM_SCEPTER,         name = "Scepter" },
    { ent_type = ENT_TYPE.ITEM_SHOTGUN,         name = "Shotgun" },
    { ent_type = ENT_TYPE.ITEM_FREEZERAY,       name = "Freeze Ray" },
    { ent_type = ENT_TYPE.ITEM_CROSSBOW,        name = "Crossbow" },
    { ent_type = ENT_TYPE.ITEM_HOUYIBOW,        name = "Hou Yi's Bow" },
    { ent_type = ENT_TYPE.ITEM_MACHETE,         name = "Machete" },
    { ent_type = ENT_TYPE.ITEM_BROKENEXCALIBUR, name = "Broken Sword" },
    { ent_type = ENT_TYPE.ITEM_BOOMERANG,       name = "Boomerang" },
    { ent_type = ENT_TYPE.ITEM_WEBGUN,          name = "Web gun" },
    { ent_type = ENT_TYPE.ITEM_TELEPORTER,      name = "Teleporter" },
    { ent_type = ENT_TYPE.ITEM_MATTOCK,         name = "Mattock" },
    { ent_type = ENT_TYPE.ITEM_CAMERA,          name = "Camera" },
}

local powerups <const> = {
    { "ankh",            "Ankh",            "", true,  ENT_TYPE.ITEM_POWERUP_ANKH },
    { "kapala",          "Kapala",          "", true,  ENT_TYPE.ITEM_POWERUP_KAPALA },
    { "alien_compass",   "Alien Compass",   "", false, ENT_TYPE.ITEM_POWERUP_SPECIALCOMPASS },
    { "climbing_gloves", "Climbing Gloves", "", false, ENT_TYPE.ITEM_POWERUP_CLIMBING_GLOVES },
    { "spike_shoes",     "Spike Shoes",     "", true,  ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES },
    { "spring_shoes",    "Spring Shoes",    "", false, ENT_TYPE.ITEM_POWERUP_SPRING_SHOES },
    { "bomb_paste",      "Bomb Paste",      "", true,  ENT_TYPE.ITEM_POWERUP_PASTE },
    { "pitchers_mitt",   "Pitcher's Mitt",  "", false, ENT_TYPE.ITEM_POWERUP_PITCHERSMITT },
    { "eggplant_crown",  "Eggplant Crown",  "", false, ENT_TYPE.ITEM_POWERUP_EGGPLANTCROWN },
    { "true_crown",      "True Crown",      "", false, ENT_TYPE.ITEM_POWERUP_TRUECROWN },
}

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

function GenerateOptions(input)
    local options = ""
    for _, item in pairs(input) do
        options = options .. item.name .. "\0"
    end
    return options .. "\0"
end

register_option_combo(OrderedName("backwear"), "Backwear", "", GenerateOptions(backwear), 1)
register_option_combo(OrderedName("held_item"), "Held item", "", GenerateOptions(heldItems), 1)
for _, powerup in pairs(powerups) do
    register_option_bool(OrderedName(powerup[1]), powerup[2], powerup[3], powerup[4])
end

register_option_int(OrderedName("money"), "Money", "", 50000, 0, 1000000)
register_option_int(OrderedName("bombs"), "Bombs", "", 4, 0, 99)
register_option_int(OrderedName("ropes"), "Ropes", "", 4, 0, 99)

function GearPlayer(player)
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

    for _, powerup in pairs(powerups) do
        if options[OrderedName(powerup[1])] then
            player:give_powerup(powerup[5])
        end
    end
end

set_callback(function()
    if state.world ~= WORLD_SUNKEN_CITY or state.theme ~= THEME.SUNKEN_CITY or state.level ~= targetLevel or not test_flag(state.presence_flags, PRESENCE_FLAG.SUN_CHALLENGE) then
        return
    end

    local player = get_player(1, false)
    GearPlayer(player)

    local tunX, tunY = get_position(get_entities_by({ ENT_TYPE.TUN }, MASK.ANY, LAYER.FRONT)[1])
    player:set_position(tunX, tunY)
end, ON.LEVEL)

set_callback(function()
    -- on going through the main door in camp
    if state.loading == 1 and state.screen_next == ON.LEVEL
        and state.world_next == 1 and state.level_next == 1 and state.theme_next == THEME.DWELLING then
        state.world_next = WORLD_SUNKEN_CITY
        state.level_next = targetLevel
        state.theme_next = THEME.SUNKEN_CITY

        -- for instant restart
        state.world_start = WORLD_SUNKEN_CITY
        state.level_start = targetLevel
        state.theme_start = THEME.SUNKEN_CITY
    end
end, ON.LOADING)
