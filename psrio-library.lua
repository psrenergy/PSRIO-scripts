local PSR = {}

function PSR.get_costs()
    if generic == nil then generic = Generic(); end
    if study == nil then study = Study(); end

    objcop = generic:load("objcop");
    if study:is_hourly() then
        return objcop:remove_agents({1}):aggregate_blocks(BY_SUM()); -- remove future cost
    else
        costs = objcop:remove_agents({1}):aggregate_blocks(BY_SUM()); -- remove total cost
        return costs:remove_agents({-1}); -- remove future cost
    end
end

function PSR.get_interest()
    if study == nil then study = Study(); end
    return (1 + study.discount_rate) ^ ((study.stage - 1) / study.stages_per_year);
end