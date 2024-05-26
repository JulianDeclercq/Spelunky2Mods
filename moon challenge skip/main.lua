meta.name = "Moon Challenge Skip"
meta.version = "1.0"
meta.description =
"Skip the moon challenge"
meta.author = "Jools"

local bowMoved = false
set_callback(function()
    local moonChallenge = state.logic.tun_moon_challenge
    if moonChallenge == nil then
        print("moon challenge NOT defined")
        return
    else
        print("moon challenge DEFINED")
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

    -- when the player has picked up the bow and the challenge has started, kill the mattock to finish the challenge
    if bowMoved and moonChallenge.forcefield_countdown == 0 then
        if player.holding_uid then
            held_entity = get_entity(player.holding_uid)
            if held_entity and held_entity.type.id == ENT_TYPE.ITEM_HOUYIBOW then
                kill_entity(moonChallenge.mattock_uid)
                return
            end
        end
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

set_callback(function()
    print("reset called")
    bowMoved = false
end, ON.RESET)
