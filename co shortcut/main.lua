meta.name = "Julle Development"
meta.version = "0.1"
meta.description = "Sandbox"
meta.author = "Jools"

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

local backwearOptions = ""
for _, item in pairs(backwear) do
  backwearOptions = backwearOptions .. item[2] .. "\0"
end
register_option_combo("backwear", "Backwear", "", backwearOptions .. "\0", 1)

local heldItemOptions = ""
for _, item in pairs(heldItems) do
  heldItemOptions = heldItemOptions .. item[2] .. "\0"
end
register_option_combo("heldItem", "Held item", "", heldItemOptions .. "\0", 1)

register_option_bool("kapala", "Kapala", "", true)
register_option_bool("spike_shoes", "Spike Shoes", "", true)
register_option_bool("ankh", "Ankh", "", true)
register_option_bool("elixir", "Elixir", "", true)
register_option_bool("alien_compass", "Alien Compass", "", true)
register_option_bool("eggplant_crown", "Eggplant Crown", "", true)
register_option_bool("climbing_gloves", "Climbing Gloves", "", false)
register_option_bool("true_crown", "True Crown", "", false)
register_option_bool("pitchers_mitt", "Pitcher's Mitt", "", false)
register_option_bool("bomb_paste", "Bomb Paste", "", false)
register_option_bool("spring_shoes", "Spring Shoes", "", false)

register_option_int("health", "Health", "", 20, 1, 99)
register_option_int("bombs", "Bombs", "", 20, 1, 99)
register_option_int("ropes", "Ropes", "", 20, 1, 99)

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

      -- reset the hitbox to avoid collision detection every frame until ON.CAMP happens again
      spawnPortalHitbox = nil
    end
  end
end, ON.GAMEFRAME)

set_callback(function()
  levelCounter = 0
end, ON.RESET)

set_callback(function()
  if levelCounter ~= 0 then -- only spawn items in case the shortcut was taken, not when CO was reached legitimately
    return
  end

  if state.world_next == 7 and state.level_next == 5 then
    print(F 'backwear on index {inspect(backwear[options.backwear])}')

    local player = get_player(1, false)
    if options.kapala then player:give_powerup(ENT_TYPE.ITEM_POWERUP_KAPALA) end
    if options.spike_shoes then player:give_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES) end
    if options.ankh then player:give_powerup(ENT_TYPE.ITEM_POWERUP_ANKH) end
    if options.alien_compass then player:give_powerup(ENT_TYPE.ITEM_POWERUP_SPECIALCOMPASS) end
    if options.eggplant_crown then player:give_powerup(ENT_TYPE.ITEM_POWERUP_EGGPLANTCROWN) end
    if options.climbing_gloves then player:give_powerup(ENT_TYPE.ITEM_POWERUP_CLIMBING_GLOVES) end
    if options.true_crown then player:give_powerup(ENT_TYPE.ITEM_POWERUP_TRUECROWN) end
    if options.pitchers_mitt then player:give_powerup(ENT_TYPE.ITEM_POWERUP_PITCHERSMITT) end
    if options.bomb_paste then player:give_powerup(ENT_TYPE.ITEM_POWERUP_PASTE) end
    if options.spring_shoes then player:give_powerup(ENT_TYPE.ITEM_POWERUP_SPRING_SHOES) end
    if options.elixir then pick_up(player.uid, spawn(ENT_TYPE.ITEM_PICKUP_ELIXIR, 0, 0, LAYER.FRONT, 0, 0)) end

    local selectedBackwear = backwear[options.backwear][1]
    if selectedBackwear > 0 then
      pick_up(player.uid, spawn(selectedBackwear, 0, 0, LAYER.PLAYER, 0, 0))
    end

    local selectedHeldItem = heldItems[options.heldItem][1]
    if selectedHeldItem > 0 then
      pick_up(player.uid, spawn(selectedHeldItem, 0, 0, LAYER.PLAYER, 0, 0))
    end

    player.health = options.health
    player.inventory.bombs = options.bombs
    player.inventory.ropes = options.ropes
  end
  levelCounter = levelCounter + 1
end, ON.LEVEL)
