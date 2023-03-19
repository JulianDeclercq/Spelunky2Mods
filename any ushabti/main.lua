ITEM_USHABTI = 442

set_callback(
  function()
    -- Check on transition into hatch level
    if state.world_next == 6 and state.level_next == 3 then
      -- If the player is holding an Ushabti, make it the correct one
      if players[1].holding_uid then
        held_entity = get_entity(players[1].holding_uid)
        if held_entity and held_entity.type.id == ITEM_USHABTI then
          state:set_correct_ushabti(held_entity.animation_frame)
        end
      end
    end
  end, ON.TRANSITION)
