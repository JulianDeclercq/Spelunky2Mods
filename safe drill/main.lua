meta.name = "Safe Drill"
meta.version = "1.0"
meta.description = "The drill will always have a clear path: no lava, no shopkeepers, no kali altars."
meta.author = "Jools"

local rooms_to_replace = {
  [65] = "SHOP", -- names are just for readability
  [66] = "SHOP_LEFT",
  [67] = "SHOP_ENTRANCE_UP",
  [68] = "SHOP_ENTRANCE_UP_LEFT",
  [69] = "SHOP_ENTRANCE_DOWN",
  [70] = "SHOP_ENTRANCE_DOWN_LEFT",
  [71] = "SHOP_ATTIC",
  [72] = "SHOP_ATTIC_LEFT",
  [73] = "SHOP_BASEMENT",
  [74] = "SHOP_BASEMENT_LEFT",
  [75] = "DICESHOP",
  [76] = "DICESHOP_LEFT",
  [115] = "ALTAR"
}

DRILL_ZONE = { startX = 0, endX = 0, column = 0}
is_drill_level = false

set_callback(function(room_gen_ctx)
  is_drill_level = test_flag(state.presence_flags, PRESENCE_FLAG.DRILL)
  if not is_drill_level then
    return
  end

  local tiles_margin, room_width, bleed = 2, 10, 1 -- TODO: Test without bleed
  for x = 0, state.width - 1 do
        for y = 0, state.height - 1 do
          local room_template_here = get_room_template(x, y, 0)
          --print(F'{x} {y}: {get_room_template_name(room_template_here)}({room_template_here})')
          if room_template_here == ROOM_TEMPLATE.VLAD_DRILL then
            print(F'DRILL LEVEL! DRILL AT {x},{y}')
            local startX = tiles_margin + room_width * x - bleed
            DRILL_ZONE.startX = startX
            DRILL_ZONE.endX = startX + room_width + bleed
            DRILL_ZONE.column = x
          end

          -- drill always spawns in highest row, so ignore the first row (y = 0)
          if y > 0 and x == DRILL_ZONE.column then
            local target = rooms_to_replace[room_template_here]
            if target ~= nil then
              room_gen_ctx:set_room_template(x, y, 0, ROOM_TEMPLATE.CHUNK_AIR) -- check if this needs to be done in the context
              print(F'REPLACED {target} at {x}, {y}')
            end
          end
        end
    end  
end, ON.POST_ROOM_GENERATION)

set_pre_tile_code_callback(function(x, y, l)
  if not is_drill_level then
    return
  end

  if x < DRILL_ZONE.startX or x > DRILL_ZONE.endX then
    return
  end    

  --print(F'Replacing lava at {x}, {y}')
  spawn_liquid(ENT_TYPE.LIQUID_WATER, x, y)
  return true -- prevents the original tile (lava) from being spawned
end, "lava")

-- REMOVE
set_callback(function()
  players[1]:give_powerup(ENT_TYPE.ITEM_POWERUP_UDJATEYE)
  god(true)
end, ON.LEVEL)

--[[

1. ON.POST_ROOM_GENERATION
2. ON.PRE_HANDLE_ROOM_TILES
3. PROBABLY (depends on chunk?) callback, if wrong it's 2nd instead--]]
