meta.name = "Olmec Trainer"
meta.version = "1.0"
meta.description =
"Lets you practise every phase of Olmec. Can also be used to practise Olmec skip. Includes all backwear, paste, pitcher's mitt and teleporter."
meta.author = "Jools"

local skip = { World = 3, Level = 1, Theme = THEME.OLMEC }
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
    { 0,                                 name = "None" },
    { ENT_TYPE.ITEM_JETPACK,             name = "Jetpack" },
    { ENT_TYPE.ITEM_VLADS_CAPE,          name = "Vlad's Cape" },
    { ENT_TYPE.ITEM_CAPE,                name = "Cape" },
    { ENT_TYPE.ITEM_HOVERPACK,           name = "Hoverpack" },
    { ENT_TYPE.ITEM_TELEPORTER_BACKPACK, name = "Telepack" },
    { ENT_TYPE.ITEM_POWERPACK,           name = "Powerpack" },
}

local phases <const> = {
    {
        olmecPosition = { x = 24.5, y = 112.5 },
        playerPosition = { x = 46, y = 120 },
        name = "Skip"
    },
    {
        olmecPosition = { x = 24.5, y = 112.5 },
        playerPosition = { x = 5, y = 111 },
        name = "First"
    },

    {
        olmecPosition = { x = 15, y = 100 },
        playerPosition = { x = 5, y = 95 },
        name = "Second"
    },
    {
        olmecPosition = { x = 24.5, y = 80.5 },
        playerPosition = { x = 5, y = 79 },
        name = "Third"
    }
}

function GenerateDropdownOptions(input)
    local dropdownOptions = ""
    for _, item in pairs(input) do
        dropdownOptions = dropdownOptions .. item.name .. "\0"
    end
    return dropdownOptions .. "\0"
end

register_option_combo(OrderedName("backwear"), "Backwear", "", GenerateDropdownOptions(backwear), 2)
register_option_combo(OrderedName("phase"), "Phase", "Phase to start at", GenerateDropdownOptions(phases), 2)

register_option_int(OrderedName("bombs"), "Bombs", "", 4, 1, 99)
register_option_int(OrderedName("ropes"), "Ropes", "", 4, 1, 99)
register_option_bool(OrderedName("bomb_paste"), "Bomb Paste", "", false)
register_option_bool(OrderedName("pitchers_mitt"), "Pitcher's Mitt", "", false)
register_option_bool(OrderedName("climbing_gloves"), "Climbing Gloves", "", false)
register_option_bool(OrderedName("teleporter"), "Teleporter", "", false)

set_callback(function()
    -- on going through the main door in camp
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

function SkipCutscene()
    local cutsceneDuration = 809
    if state.logic.olmec_cutscene and state.logic.olmec_cutscene.timer then
        state.logic.olmec_cutscene.timer = cutsceneDuration
    end

    -- clear the cavemen so they don't show up for the first frame
    local cavemen = get_entities_by({ ENT_TYPE.MONS_CAVEMAN }, MASK.ANY, LAYER.FRONT)
    for _, uid in pairs(cavemen) do
        local caveman = get_entity(uid)
        caveman:set_position(0, 0)
    end
end

function LoadPhase(phase)
    -- global timeout is needed since the cutscene interferes with things the first 2 frames
    set_global_timeout(function()
        local olmec = get_entity(get_entities_by({ ENT_TYPE.ACTIVEFLOOR_OLMEC }, MASK.ANY, LAYER.FRONT)[1])
        local player = get_player(1, false)

        olmec:set_position(phase.olmecPosition.x, phase.olmecPosition.y)
        player:set_position(phase.playerPosition.x, phase.playerPosition.y)

        -- fixes olmec being stuck to the ground when loading phase 2
        if phase.name == "Second" then
            olmec.attack_timer = 50
        end
    end, 2)
end

set_callback(function()
    if state.world ~= skip.World or state.level ~= skip.Level then
        return
    end

    SkipCutscene()

    local selectedPhase = phases[options[OrderedName("phase")]]
    LoadPhase(selectedPhase)

    -- gear the player
    local player = get_player(1, false)
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

    if options[OrderedName("teleporter")] then
        pick_up(player.uid, spawn(ENT_TYPE.ITEM_TELEPORTER, 0, 0, LAYER.PLAYER, 0, 0))
    end
end, ON.LEVEL)
