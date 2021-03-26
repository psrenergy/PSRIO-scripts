if generic == nil then generic = Generic(); end
if study == nil then study = Study(); end

interest = (1 + study.discount_rate) ^ ((study.stage - 1) / study.stages_per_year);

objcop = generic:load("objcop");
if study:is_hourly() then
    costs = objcop:remove_agents({1}):aggregate_blocks(BY_SUM()); -- remove future cost
else
    costs = objcop:remove_agents({1}):aggregate_blocks(BY_SUM()); -- remove total cost
    costs = costs:remove_agents({-1}); -- remove future cost
end

-- SDDPD_SCECOS
concatenate(
    costs:aggregate_agents(BY_SUM(), "P10"):aggregate_scenarios(BY_PERCENTILE(10)),
    costs:aggregate_agents(BY_SUM(), "P50"):aggregate_scenarios(BY_PERCENTILE(50)),
    costs:aggregate_agents(BY_SUM(), "P90"):aggregate_scenarios(BY_PERCENTILE(90))
):save("sddpd_scecos");

-- SDDPD_PERCCOSTS - average costs per stage
costs = costs:aggregate_scenarios(BY_AVERAGE());
(costs / costs:aggregate_agents(BY_SUM(), "total cost")):convert("%"):save("sddpd_perccosts", {remove_zeros = true});