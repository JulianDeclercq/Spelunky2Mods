meta.name = "Moon Challenge Skip"
meta.version = "1.0"
meta.description =
"Skip the moon challenge"
meta.author = "Jools"

local finished = false
set_callback(function()
    if not test_flag(state.presence_flags, PRESENCE_FLAG.MOON_CHALLENGE) then
        return
    end

    -- locate the clover
    local clovers = get_entities_by({ ENT_TYPE.ITEM_PICKUP_CLOVER }, MASK.ANY, LAYER.BACK)
    if #clovers > 1 then
        print("Unexpected amount of clovers: " .. #clovers)
        return
    end

    -- move the bow to the clover 
    local bows = get_entities_by({ ENT_TYPE.ITEM_HOUYIBOW }, MASK.ANY, LAYER.BACK)
    if #bows ~= 1 then
        print("Unexpected amount of bows: " .. #bows)
        return
    end

    local bow = get_entity(bows[1])
    local cloverX, cloverY = get_position(clovers[1])
    bow:set_position(cloverX, cloverY)
end, ON.LEVEL)

set_callback(function()
    if finished or not test_flag(state.presence_flags, PRESENCE_FLAG.MOON_CHALLENGE) then
        return
    end

    -- delete the mattock when the player picks up the bow to immediately end the challenge
    local player = get_player(1, false)
    if player.holding_uid then
        held_entity = get_entity(player.holding_uid)
        if held_entity and held_entity.type.id == ENT_TYPE.ITEM_HOUYIBOW then
            kill_entity(state.logic.tun_moon_challenge.mattock_uid)
            finished = true
        end
    end
end, ON.PRE_UPDATE)

set_callback(function()
    finished = false
end, ON.RESET)