local set_requests = defines.control_behavior.logistic_container.circuit_mode_of_operation.set_requests

local function circuit_sets_requests(logistic_chest)
  return logistic_chest.owner.get_control_behavior() and logistic_chest.owner.get_control_behavior().circuit_mode_of_operation == set_requests
end

local function has_visible_circuit_wire(logistic_chest)
    return table_size(logistic_chest.owner.circuit_connected_entities.red) + table_size(logistic_chest.owner.circuit_connected_entities.green) > 0
end

function trigger()
    for _, force in pairs(game.forces) do
        for _, logistic_networks in pairs(force.logistic_networks) do
            for _, logistic_network in pairs(logistic_networks) do
                for _, logistic_chest in pairs(logistic_network.requester_points) do
                    if(logistic_chest.mode == defines.logistic_mode.requester) then
                        if(logistic_chest.owner.request_from_buffers == true) then
                        -- only blue ones which request from buffers

                            if(logistic_chest.filters) then
                            -- its filter slots arent empty

                                if(circuit_sets_requests(logistic_chest) and has_visible_circuit_wire(logistic_chest)) then
                                -- assume chests controlled by circuits are allowed, these will not trigger an alert
                                else
                                    for k, player in pairs (game.connected_players) do
                                        if(player.force == force) then -- is this needed, or does the force on the 1st argument of the alert filter it out?
                                            player.add_custom_alert(logistic_chest.owner, {type = "item", name = "logistic-chest-requester"}, "[item=logistic-chest-requester] requesting from buffer chests", true)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

script.on_nth_tick(60 * 1, trigger)