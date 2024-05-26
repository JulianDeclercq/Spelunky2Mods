meta.name = "Moon Challenge Skip"
meta.version = "1.0"
meta.description =
"Skip the moon challenge"
meta.author = "Jools"

local WORLD_SUNKEN_CITY = 7

-- If sun challenge hasn't spawned yet, the game will force spawn in the last possible level, so start there. (7-2 in case of the Sun challenge)
local targetLevel = 2

set_callback(function()
    if not test_flag(state.presence_flags, PRESENCE_FLAG.MOON_CHALLENGE) then
        return
    end

    local player = get_player(1, false)

    local tunX, tunY = get_position(get_entities_by({ ENT_TYPE.TUN }, MASK.ANY, LAYER.FRONT)[1])
end, ON.LEVEL)
