local costs = require("sddp/costs");
local costs_aggregated = costs():aggregate_blocks(BY_SUM());

-- SDDPD_SCECOS
concatenate(
    costs_aggregated:aggregate_agents(BY_SUM(), "P10"):aggregate_scenarios(BY_PERCENTILE(10)),
    costs_aggregated:aggregate_agents(BY_SUM(), "P50"):aggregate_scenarios(BY_PERCENTILE(50)),
    costs_aggregated:aggregate_agents(BY_SUM(), "P90"):aggregate_scenarios(BY_PERCENTILE(90))
):save("sddpd_scecos");

-- SDDPD_PERCCOSTS
local costs_per_agent = costs_aggregated:aggregate_scenarios(BY_AVERAGE());
local costs_agents_aggregated = costs_per_agent:aggregate_agents(BY_SUM(), "total cost");
(costs_per_agent / costs_agents_aggregated):convert("%"):save("sddpd_perccosts", {remove_zeros = true});