NEO_BABYLON_THEME = 8
TIAMAT_THEME = 14

ITEM_USHABTI = 442

bSkipped = false
local function skip()
  -- Jump to 1-1 from any screen before menu
  if state.screen >= 0 and state.screen < 4 then
    state.items.player_select[1].activated = true
    state.items.player_select[1].character = ENT_TYPE.CHAR_ANA_SPELUNKY + savegame.players[1]
    state.items.player_select[1].texture = TEXTURE.DATA_TEXTURES_CHAR_YELLOW_0 + savegame.players[1]
    state.items.player_count = 1
    state.screen_next = 12
    state.world_start = 6
    state.level_start = 2
    state.theme_start = NEO_BABYLON_THEME
    state.world_next = 6
    state.level_next = 2
    state.theme_next = NEO_BABYLON_THEME
    state.quest_flags = 1
    state.loading = 1
    bSkipped = true
  end
end

set_callback(
  function()
    skip()
    if (bSkipped) then
      clear_callback()
    end
  end, ON.SCREEN)

set_callback(
  function()
    --print(F'{state:get_correct_ushabti()}')
    --print(F'{state.first_damage_cause}')

    --clear_callback()
  end, ON.FRAME)

-- TODO: Maybe this is too late and needs to be done on level transition instead of on level
set_callback(
  function()
    print(F'ON.TRANSITION: state.world {state.world}, state.level {state.level}')
    print(F'ON.TRANSITION: state.world_next {state.world_next}, state.level_next {state.level_next}')
    if state.world_next == 6 and state.level_next == 3 then
      print("correct world")
      if players[1].holding_uid then
        print(F'Player is holding {players[1].holding_uid}')
        held_entity = get_entity(players[1].holding_uid)
        if held_entity and held_entity.type.id == ITEM_USHABTI then
          print(F'Player is holding an ushabti {held_entity.animation_frame}')
          print(F'Correct ushabti BEFORE {state:get_correct_ushabti()}')
          state:set_correct_ushabti(held_entity.animation_frame)
          print(F'Correct ushabti AFTER {state:get_correct_ushabti()}')
        end
      end
    end
  end, ON.TRANSITION)
