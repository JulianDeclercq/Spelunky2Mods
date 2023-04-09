meta.name = "Julle Development"
meta.version = "0.1"
meta.description = "Sandbox"
meta.author = "Jools"

local orderPrefix = 1
OptionNameLookup = {}
function OrderedName(name)
  -- return existing
  local existing = OptionNameLookup[name]
  if existing ~= nil then
    return existing
  end

  -- add new
  local orderedName = string.format("%03i_%s", orderPrefix, name)
  OptionNameLookup[name] = orderedName
  orderPrefix = orderPrefix + 1
  return orderedName
end

backwear = {
  { 0,                                 "None" },
  { ENT_TYPE.ITEM_JETPACK,             "Jetpack" },
  { ENT_TYPE.ITEM_VLADS_CAPE,          "Vlad's Cape" },
  { ENT_TYPE.ITEM_CAPE,                "Cape" },
  { ENT_TYPE.ITEM_HOVERPACK,           "Hoverpack" },
  { ENT_TYPE.ITEM_TELEPORTER_BACKPACK, "Telepack" },
  { ENT_TYPE.ITEM_POWERPACK,           "Powerpack" },
}

heldItems = {
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

register_option_int(OrderedName("health"), "Health", "", 20, 1, 99)
register_option_int(OrderedName("bombs"), "Bombs", "", 20, 1, 99)
register_option_int(OrderedName("ropes"), "Ropes", "", 20, 1, 99)

local backwearOptions = ""
for _, item in pairs(backwear) do
  backwearOptions = backwearOptions .. item[2] .. "\0"
end
register_option_combo(OrderedName("backwear"), "Backwear", "", backwearOptions .. "\0", 1)

local heldItemOptions = ""
for _, item in pairs(heldItems) do
  heldItemOptions = heldItemOptions .. item[2] .. "\0"
end
register_option_combo(OrderedName("heldItem"), "Held item", "", heldItemOptions .. "\0", 1)

register_option_bool(OrderedName("ankh"), "Ankh", "", true)
register_option_bool(OrderedName("kapala"), "Kapala", "", true)
register_option_bool(OrderedName("alien_compass"), "Alien Compass", "", true)
register_option_bool(OrderedName("elixir"), "Elixir", "", true)

register_option_bool(OrderedName("climbing_gloves"), "Climbing Gloves", "", false)
register_option_bool(OrderedName("spike_shoes"), "Spike Shoes", "", true)
register_option_bool(OrderedName("spring_shoes"), "Spring Shoes", "", false)

register_option_bool(OrderedName("bomb_paste"), "Bomb Paste", "", true)
register_option_bool(OrderedName("pitchers_mitt"), "Pitcher's Mitt", "", false)

register_option_bool(OrderedName("eggplant_crown"), "Eggplant Crown", "", false)
register_option_bool(OrderedName("true_crown"), "True Crown", "", false)

local levelCounter = 0
local spawnPortalHitbox = nil
local playerEntType = nil
set_callback(function()
  levelCounter = 0
  spawnPortalHitbox = AABB:new():offset(56, 109):extrude(5)
  playerEntType = players[1].type.id
end, ON.CAMP)

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
  levelCounter = 0
end, ON.RESET)

set_callback(function()
  -- only spawn items in case the shortcut was taken, not when CO was reached legitimately
  if levelCounter ~= 0 then
    return
  end

  if state.world_next == 7 and state.level_next == 5 then
    --print(F 'backwear on index {inspect(backwear[options[OrderedName("backwear")])}')]

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

    if options[OrderedName("ankh")] then player:give_powerup(ENT_TYPE.ITEM_POWERUP_ANKH) end
    if options[OrderedName("kapala")] then player:give_powerup(ENT_TYPE.ITEM_POWERUP_KAPALA) end
    if options[OrderedName("alien_compass")] then player:give_powerup(ENT_TYPE.ITEM_POWERUP_SPECIALCOMPASS) end
    if options[OrderedName("elixir")] then
      pick_up(player.uid, spawn(ENT_TYPE.ITEM_PICKUP_ELIXIR, 0, 0, LAYER.FRONT, 0, 0))
    end

    if options[OrderedName("climbing_gloves")] then player:give_powerup(ENT_TYPE.ITEM_POWERUP_CLIMBING_GLOVES) end
    if options[OrderedName("spike_shoes")] then player:give_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES) end
    if options[OrderedName("spring_shoes")] then player:give_powerup(ENT_TYPE.ITEM_POWERUP_SPRING_SHOES) end

    if options[OrderedName("bomb_paste")] then player:give_powerup(ENT_TYPE.ITEM_POWERUP_PASTE) end
    if options[OrderedName("pitchers_mitt")] then player:give_powerup(ENT_TYPE.ITEM_POWERUP_PITCHERSMITT) end

    if options[OrderedName("eggplant_crown")] then player:give_powerup(ENT_TYPE.ITEM_POWERUP_EGGPLANTCROWN) end
    if options[OrderedName("true_crown")] then player:give_powerup(ENT_TYPE.ITEM_POWERUP_TRUECROWN) end
  end

  levelCounter = levelCounter + 1
end, ON.LEVEL)
