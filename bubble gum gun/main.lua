meta.name = "Julle Development"
meta.version = "0.1"
meta.description = "Sandbox"
meta.author = "Jools"

local bubbleGumColor = { r = 255, g = 105, b = 180, a = 255 }

local currentCooldown = 0
local maxCooldown = 24 -- X frames cooldown between 2 bubbles
local heldLastFrame = false
local hasReleasedSinceLast = false
set_callback(function()
  local player = players[1]
  local input = player.input.buttons_gameplay
  local holdCurrentFrame = test_flag(input, INPUT_FLAG.WHIP)

  local mounted = player:topmost_mount().uid ~= player.uid

  local canWhip = player.state ~= CHAR_STATE.DUCKING and
      player.state ~= CHAR_STATE.THROWING and
      player.state ~= CHAR_STATE.SITTING and
      player.holding_uid < 0 and
      not mounted

  if holdCurrentFrame and canWhip then
    if hasReleasedSinceLast and currentCooldown <= 0 then
      local facingLeft = player.rendering_info.facing_left
      local direction = 1
      if facingLeft then
        direction = -1
      end

      print("spawning bubble!")
      local spawned = get_entity(spawn_critical(ENT_TYPE.ITEM_AXOLOTL_BUBBLESHOT, player.x + 1 * direction, player.y,
        LAYER.FRONT, 0, 0))
      spawned.velocityx = 0.5 * direction
      spawned.color:set_rgba(bubbleGumColor.r, bubbleGumColor.g, bubbleGumColor.b, bubbleGumColor.a)

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

local toRecolor = {
  PARTICLEEMITTER.AXOLOTL_SMALLBUBBLEKILL,
  PARTICLEEMITTER.AXOLOTL_BIGBUBBLEKILL
}

set_callback(function()
  for i = 1, #toRecolor do
    local particle = get_particle_type(toRecolor[i])
    particle.red = bubbleGumColor.r
    particle.green = bubbleGumColor.g
    particle.blue = bubbleGumColor.b
  end
end, ON.START)

-- Color normal axolotls bubbles too :)
set_post_entity_spawn(function(bubble)
  bubble.color:set_rgba(bubbleGumColor.r, bubbleGumColor.g, bubbleGumColor.b, bubbleGumColor.a)
end, SPAWN_TYPE.SYSTEMIC, MASK.ITEM, ENT_TYPE.ITEM_AXOLOTL_BUBBLESHOT)
