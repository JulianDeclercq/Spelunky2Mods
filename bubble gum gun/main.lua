-- set_pre_entity_spawn(function(type, x, y, l, overlay)
--   print(F 'type in callback {type}')
--   return spawn_entity(ENT_TYPE.ITEM_AXOLOTL_BUBBLESHOT, x, y, l, 0, 0)
-- end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_BULLET, ENT_TYPE.ITEM_FIREBALL)

local currentCooldown = 0
local maxCooldown = 16 -- every 60 frames you can fire
local heldLastFrame = false
local hasReleasedSinceLast = false
set_callback(function()
  local player = players[1]
  local input = player.input.buttons_gameplay
  local holdCurrentFrame = test_flag(input, INPUT_FLAG.WHIP)

  local canWhip = player.state ~= CHAR_STATE.DUCKING and
      player.state ~= CHAR_STATE.THROWING and
      player.holding_uid < 0

  --print(F 'last: {heldLastFrame}, current: {holdCurrentFrame}, cd {currentCooldown}')
  if holdCurrentFrame and canWhip then
    if hasReleasedSinceLast and currentCooldown <= 0 then
      print("spawning!")
      local facingLeft = player.rendering_info.facing_left
      local direction = 1
      if facingLeft then
        direction = -1
      end

      local spawned = get_entity(spawn_critical(ENT_TYPE.ITEM_FREEZERAYSHOT, player.x + 1 * direction, player.y,
        LAYER.FRONT, 0, 0))
      spawned.velocityx = 0.5 * direction

      spawned.owner_uid = player.uid

      currentCooldown = maxCooldown
      hasReleasedSinceLast = false
    end
  end

  currentCooldown = currentCooldown - 1

  -- mimic whip behaviour, can't keep whipping when just holding the input button
  if heldLastFrame and not holdCurrentFrame then
    hasReleasedSinceLast = true
  end

  heldLastFrame = holdCurrentFrame
end, ON.FRAME)
