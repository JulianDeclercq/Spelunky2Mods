meta.name = "Moon Challenge Skip"
meta.version = "1.0"
meta.description =
"Skip the moon challenge"
meta.author = "Jools"

set_callback(function()
    local moonChallenge = state.logic.tun_moon_challenge
    if moonChallenge == nil then
        return
    end

    local player = get_player(1, false)
    
    -- if moonChallenge object exists it means the player has paid for the moon challenge
    if moonChallenge and player.layer == LAYER.BACK then
       -- replace the clover with the bow 
        print("Player has entered the moonchallenge itself after having paid")
        print("forcefield countdown is " .. moonChallenge.forcefield_countdown)
        
        -- item_pickup_clover
        local clovers = get_entities_by({ ENT_TYPE.ITEM_PICKUP_CLOVER }, MASK.ANY, LAYER.BACK)
        if #clovers ~= 1 then
            print("more than 1 clover found, exiting")
            return
        end

        for i, clover in ipairs(clovers) do
            print("clover id from loop " .. clover)
            print("clover id from type " .. type(clover))
        end

        local clover = clovers[1] 
        local cloverX, cloverY = get_position(clovers[1])
        
        -- get the bow
        local bows = get_entities_by({ ENT_TYPE.ITEM_HOUYIBOW }, MASK.ANY, LAYER.BACK)
        if #bows ~= 1 then
            print("more than 1 bow found, exiting")
            return
        end

        local bowEnt = get_entity(bows[1])
        bowEnt:set_position(cloverX, cloverY)
    end
    
    if moonChallenge.challenge_active then
        print("moon challenge is ACTIVE!")
        print("mattock uuid " .. moonChallenge.mattock_uid)
        --kill_entity(moonChallenge.mattock_uid)
    else
        --print("moon challenge is NOT active!")
    end
end, ON.PRE_UPDATE)


set_callback(function()
    local player = get_player(1, false)
    player.inventory.money = 100000
    -- on going through the main door in camp
    if state.loading == 1 and state.screen_next == ON.LEVEL
            and state.world_next == 1 and state.level_next == 1 and state.theme_next == THEME.DWELLING then
        state.world_next = 2
        state.level_next = 2
        state.theme_next = THEME.JUNGLE

        -- for instant restart
        state.world_start = 2
        state.level_start = 2
        state.theme_start = THEME.JUNGLE
    end
end, ON.LOADING)
