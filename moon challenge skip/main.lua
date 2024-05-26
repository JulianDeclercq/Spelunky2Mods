meta.name = "Moon Challenge Skip"
meta.version = "1.0"
meta.description =
"Skip the moon challenge"
meta.author = "Jools"

local bowMoved = false
set_callback(function()
    local moonChallenge = state.logic.tun_moon_challenge
    if moonChallenge == nil then
        return
    end

    local player = get_player(1, false)
    
    -- if moonChallenge object is defined it means the player has paid for the moon challenge
    if moonChallenge and player.layer == LAYER.BACK and not bowMoved then
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
        bowMoved = true
    end

    -- kill the mattock to finish the challenge after the bow has moved
    if bowMoved and moonChallenge.forcefield_countdown == 0 then
        kill_entity(moonChallenge.mattock_uid)
    end 
end, ON.PRE_UPDATE)

set_callback(function()
    bowMoved = false
end, ON.RESET)
