meta.name = "Julle Development"
meta.version = "0.1"
meta.description = "Sandbox"
meta.author = "Jools"

local spawnPortalHitbox = nil
local playerEntType = nil
set_callback(function()
  spawnPortalHitbox = AABB:new():offset(47, 109):extrude(5)
  playerEntType = players[1].type.id
  god(true)
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
    print("spawned portal")
  end
end, ON.GAMEFRAME)

local levelCounter = 0
set_callback(function()
  levelCounter = 0
end, ON.RESET)

set_callback(function()
  if levelCounter ~= 0 then -- only spawn items in case the shortcut was taken, not when CO was reached legitimately
    return
  end

  if state.world_next == 7 and state.level_next == 5 then
    local player = get_player(1, false)
    player:give_powerup(ENT_TYPE.ITEM_POWERUP_KAPALA)
    player:give_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES)
    player:give_powerup(ENT_TYPE.ITEM_POWERUP_ANKH)
    player:give_powerup(ENT_TYPE.ITEM_POWERUP_SPECIALCOMPASS)
    player:give_powerup(ENT_TYPE.ITEM_POWERUP_EGGPLANTCROWN)
    pick_up(players[1].uid, spawn(ENT_TYPE.ITEM_JETPACK, 0, 0, LAYER.PLAYER, 0, 0))
  end
  levelCounter = levelCounter + 1
end, ON.LEVEL)
