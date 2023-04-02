meta.name = "Safe Drill"
meta.version = "0.2"
meta.description = "The drill will always have a clear path, no lava, no shopkeepers and no kali altars."
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
  [74] = "SHOP_BASEMENT_LEFT"
}

DRILL_PRESENCE = 3
WATER_ID = 909

is_drill_level = false

SAFE_ZONE = { startX = 0, endX = 0 }
set_callback(function(room_gen_ctx)
  is_drill_level = test_flag(state.presence_flags, DRILL_PRESENCE)
  if not is_drill_level then
    return
  end

  local tiles_margin, room_width, bleed = 2, 10, 1
  for x = 0, state.width - 1 do
        for y = 0, state.height - 1 do

          local room_template_here = get_room_template(x, y, 0)
          --print(F'{x} {y}: {get_room_template_name(room_template_here)}({room_template_here})')
          if room_template_here == ROOM_TEMPLATE.VLAD_DRILL then
            print(F'found drill at {x}, {y}')
            local startX = tiles_margin + room_width * x - bleed
            local endX = startX + room_width + bleed
            print(F'drill spans in coords from {startX} to {endX}')
            SAFE_ZONE.startX = startX
            SAFE_ZONE.endX = endX
            print(F'SAFE_ZONE {inspect(SAFE_ZONE)}')
          end

          local target = rooms_to_replace[room_template_here]
          if target ~= nil then
            print(F'REPLACING {target} at {x}, {y}')
            room_gen_ctx:set_room_template(x, y, 0, ROOM_TEMPLATE.CHUNK_AIR) -- check if this needs to be done in the context
          end
        end
    end  
end, ON.POST_ROOM_GENERATION)

set_pre_tile_code_callback(function(x, y, l)
  if not is_drill_level then
    return
  end

  if x < SAFE_ZONE.startX or x > SAFE_ZONE.endX then
    return
  end    

  print(F'Replacing lava at {x}, {y}')
  spawn_liquid(WATER_ID, x, y)
  return true -- prevents the original tile (lava) from being spawned
end, "lava")

-- REMOVE
set_callback(function()
  players[1]:give_powerup(ENT_TYPE.ITEM_POWERUP_UDJATEYE)
end, ON.LEVEL)

--[[

every chunk is 10? wide (42 total - 2x 2 tiles border) x position is 0 indexed]

13 - half tile width (0.5) is the first x pos of the first block of the 2nd chunk

1. ON.POST_ROOM_GENERATION
2. ON.PRE_HANDLE_ROOM_TILES
3. PROBABLY (depends on chunk?) callback, if wrong it's 2nd instead--]]
