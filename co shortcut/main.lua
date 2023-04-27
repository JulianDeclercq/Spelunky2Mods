meta.name = "Cosmic Ocean Portal"
meta.version = "1.0"
meta.description =
"Opens a portal to the Cosmic Ocean from the telescope at the Camp. Grants customizable items and power-ups upon entering."
meta.author = "Jools"

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

local heldItems <const> = {
    { 0,                             "None" },
    { ENT_TYPE.ITEM_EXCALIBUR,       "Excalibur" },
    { ENT_TYPE.ITEM_PLASMACANNON,    "Plasma Cannon" },
    { ENT_TYPE.ITEM_SCEPTER,         "Scepter" },
    { ENT_TYPE.ITEM_SHOTGUN,         "Shotgun" },
    { ENT_TYPE.ITEM_FREEZERAY,       "Freeze Ray" },
    { ENT_TYPE.ITEM_CROSSBOW,        "Crossbow" },
    { ENT_TYPE.ITEM_HOUYIBOW,        "Hou Yi's Bow" },
    { ENT_TYPE.ITEM_MACHETE,         "Machete" },
    { ENT_TYPE.ITEM_BROKENEXCALIBUR, "Broken Sword" },
    { ENT_TYPE.ITEM_BOOMERANG,       "Boomerang" },
    { ENT_TYPE.ITEM_WEBGUN,          "Web gun" },
    { ENT_TYPE.ITEM_TELEPORTER,      "Teleporter" },
    { ENT_TYPE.ITEM_MATTOCK,         "Mattock" },
    { ENT_TYPE.ITEM_CAMERA,          "Camera" },
}

local powerups <const> = {
    { "ankh",            "Ankh",            "", true,  ENT_TYPE.ITEM_POWERUP_ANKH },
    { "kapala",          "Kapala",          "", true,  ENT_TYPE.ITEM_POWERUP_KAPALA },
    { "alien_compass",   "Alien Compass",   "", true,  ENT_TYPE.ITEM_POWERUP_SPECIALCOMPASS },
    { "climbing_gloves", "Climbing Gloves", "", false, ENT_TYPE.ITEM_POWERUP_CLIMBING_GLOVES },
    { "spike_shoes",     "Spike Shoes",     "", true,  ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES },
    { "spring_shoes",    "Spring Shoes",    "", false, ENT_TYPE.ITEM_POWERUP_SPRING_SHOES },
    { "bomb_paste",      "Bomb Paste",      "", true,  ENT_TYPE.ITEM_POWERUP_PASTE },
    { "pitchers_mitt",   "Pitcher's Mitt",  "", false, ENT_TYPE.ITEM_POWERUP_PITCHERSMITT },
    { "eggplant_crown",  "Eggplant Crown",  "", false, ENT_TYPE.ITEM_POWERUP_EGGPLANTCROWN },
    { "true_crown",      "True Crown",      "", false, ENT_TYPE.ITEM_POWERUP_TRUECROWN },
}

register_option_int(OrderedName("health"), "Health", "", 20, 1, 99)
register_option_int(OrderedName("bombs"), "Bombs", "", 20, 1, 99)
register_option_int(OrderedName("ropes"), "Ropes", "", 20, 1, 99)

local backwearOptions = ""
for _, backwear in pairs(backwear) do
    backwearOptions = backwearOptions .. backwear[2] .. "\0"
end
register_option_combo(OrderedName("backwear"), "Backwear", "", backwearOptions .. "\0", 2)

local heldItemOptions = ""
for _, item in pairs(heldItems) do
    heldItemOptions = heldItemOptions .. item[2] .. "\0"
end
register_option_combo(OrderedName("heldItem"), "Held item", "", heldItemOptions .. "\0", 1)

for _, powerup in pairs(powerups) do
    register_option_bool(OrderedName(powerup[1]), powerup[2], powerup[3], powerup[4])
end

-- special case since it has to be spawned and picked up rather than added as a powerup
register_option_bool(OrderedName("elixir"), "Elixir", "", true)

local levelCounter = 0
local spawnPortalHitbox = nil
local playerEntType = nil
set_callback(function()
    levelCounter = 0
    spawnPortalHitbox = AABB:new():offset(56, 109):extrude(5)
    playerEntType = players[1].type.id
end, ON.CAMP)

set_callback(function()
    levelCounter = 0
end, ON.RESET)

set_callback(function()
    if spawnPortalHitbox == nil then
        return
    end

    local ents = get_entities_overlapping_hitbox(playerEntType, MASK.PLAYER, spawnPortalHitbox, LAYER.FRONT);
    if #ents > 0 then
        local portal = get_entity(spawn_critical(ENT_TYPE.LOGICAL_PORTAL, 40, 110, LAYER.FRONT, 0, 0))
        if portal then
            portal.world = 7
            portal.level = 5
            portal.theme = THEME.COSMIC_OCEAN

            -- make sure instant restart works
            state.world_start = 7
            state.level_start = 5
            state.theme_start = THEME.COSMIC_OCEAN

            spawnPortalHitbox = nil
        end
    end
end, ON.GAMEFRAME)

set_callback(function()
    -- delete the hitbox
    if spawnPortalHitbox then
        spawnPortalHitbox = nil
    end

    -- only spawn items in case the shortcut was taken, not when CO was reached legitimately
    if levelCounter ~= 0 then
        return
    end

    if state.world_next == 7 and state.level_next == 5 then
        local player = get_player(1, false)

        player.health = options[OrderedName("health")]
        player.inventory.bombs = options[OrderedName("bombs")]
        player.inventory.ropes = options[OrderedName("ropes")]

        local selectedBackwear = backwear[options[OrderedName("backwear")]][1]
        if selectedBackwear > 0 then
            pick_up(player.uid, spawn(selectedBackwear, 0, 0, LAYER.PLAYER, 0, 0))
        end

        local selectedHeldItem = heldItems[options[OrderedName("heldItem")]][1]
        if selectedHeldItem > 0 then
            pick_up(player.uid, spawn(selectedHeldItem, 0, 0, LAYER.PLAYER, 0, 0))
        end

        for _, powerup in pairs(powerups) do
            if options[OrderedName(powerup[1])] then
                player:give_powerup(powerup[5])
            end
        end

        if options[OrderedName("elixir")] then
            local x, y, layer = get_position(player.uid)
            spawn(ENT_TYPE.ITEM_PICKUP_ELIXIR, x, y, layer, 0, 0)

            -- let the player start on the health they selected, so remove the health the elixir gives on pickup
            player.health = player.health - 8
        end
    end

    levelCounter = levelCounter + 1
end, ON.LEVEL)
