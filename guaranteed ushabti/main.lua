meta.name = "Guaranteed Ushabti"
meta.version = "1.0"
meta.description = "Any ushabti you pick up will be the correct one that hatches into Qilin."
meta.author = "Jools"

set_callback(
  function()
    -- Check on transition into hatch level
    if state.world_next == 6 and state.level_next == 3 then
      -- If any player is holding an Ushabti, make it the correct one
        for _, player in pairs(players) do
            if player.holding_uid then
                held_entity = get_entity(player.holding_uid)
                if held_entity and held_entity.type.id == ENT_TYPE.ITEM_USHABTI then
                    state:set_correct_ushabti(held_entity.animation_frame)
                    break
                end
            end
        end
    end
  end, ON.TRANSITION)
