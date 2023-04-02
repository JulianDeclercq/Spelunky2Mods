meta.name = "Safe Drill"
meta.version = "0.1"
meta.description = "The drill will always have a clear path, no lava, no shopkeepers and no kali altars."
meta.author = "Jools"

DRILL_PRESENCE = 3
WATER_ID = 909

is_drill_level = false

set_callback(
  function()
    is_drill_level = test_flag(state.presence_flags, DRILL_PRESENCE)
  end, ON.PRE_HANDLE_ROOM_TILES)

set_pre_tile_code_callback(function(x, y, l)
  if is_drill_level then
    spawn_liquid(WATER_ID, x, y)
    return true -- prevents the original tile (lava) from being spawned
  end
end, "lava")