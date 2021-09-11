local objcop = require("sddp/costs");

-----------------------------------------------------------------------------------------------
-- COSTS
-----------------------------------------------------------------------------------------------
local costs = ifelse(objcop():ge(0), objcop(), 0);

-- sddp_dashboard_cost_tot
costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):save("sddp_dashboard_cost_tot", {remove_zeros = true});

-- sddp_dashboard_cost_avg
costs:aggregate_scenarios(BY_AVERAGE()):save("sddp_dashboard_cost_avg", {remove_zeros = true});

-- sddp_dashboard_cost_disp
concatenate(
    costs:aggregate_agents(BY_SUM(), "P10"):aggregate_scenarios(BY_PERCENTILE(10)),
    costs:aggregate_agents(BY_SUM(), "Average"):aggregate_scenarios(BY_AVERAGE()),
    costs:aggregate_agents(BY_SUM(), "P90"):aggregate_scenarios(BY_PERCENTILE(90))
):save("sddp_dashboard_cost_disp");

-----------------------------------------------------------------------------------------------
-- REVENUES
-----------------------------------------------------------------------------------------------
local revenues = ifelse(objcop():le(0), -objcop(), 0);

-- sddp_dashboard_rev_tot
revenues:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):save("sddp_dashboard_rev_tot", {remove_zeros = true});

-- sddp_dashboard_rev_avg
revenues:aggregate_scenarios(BY_AVERAGE()):save("sddp_dashboard_rev_avg", {remove_zeros = true});

-- sddp_dashboard_rev_disp
concatenate(
    revenues:aggregate_agents(BY_SUM(), "P10"):aggregate_scenarios(BY_PERCENTILE(10)),
    revenues:aggregate_agents(BY_SUM(), "Average"):aggregate_scenarios(BY_AVERAGE()),
    revenues:aggregate_agents(BY_SUM(), "P90"):aggregate_scenarios(BY_PERCENTILE(90))
):save("sddp_dashboard_rev_disp");
