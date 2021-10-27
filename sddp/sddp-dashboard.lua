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
disp = concatenate(
    costs:aggregate_agents(BY_SUM(), "P10"):aggregate_scenarios(BY_PERCENTILE(10)),
    costs:aggregate_agents(BY_SUM(), "Average"):aggregate_scenarios(BY_AVERAGE()),
    costs:aggregate_agents(BY_SUM(), "P90"):aggregate_scenarios(BY_PERCENTILE(90))
);
x = disp:aggregate_agents(BY_SUM(), "CheckZeros"):aggregate_stages(BY_SUM()):to_list()[1];
if x > 0.0 then
    disp:save("sddp_dashboard_cost_disp");
end

-----------------------------------------------------------------------------------------------
-- REVENUES
-----------------------------------------------------------------------------------------------
local revenues = ifelse(objcop():le(0), -objcop(), 0);

-- sddp_dashboard_rev_tot
revenues:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):save("sddp_dashboard_rev_tot", {remove_zeros = true});

-- sddp_dashboard_rev_avg
revenues:aggregate_scenarios(BY_AVERAGE()):save("sddp_dashboard_rev_avg", {remove_zeros = true});

-- sddp_dashboard_rev_disp
disp = concatenate(
    revenues:aggregate_agents(BY_SUM(), "P10"):aggregate_scenarios(BY_PERCENTILE(10)),
    revenues:aggregate_agents(BY_SUM(), "Average"):aggregate_scenarios(BY_AVERAGE()),
    revenues:aggregate_agents(BY_SUM(), "P90"):aggregate_scenarios(BY_PERCENTILE(90))
);
x = disp:aggregate_agents(BY_SUM(), "CheckZeros"):aggregate_stages(BY_SUM()):to_list()[1];
if x > 0.0 then
    disp:save("sddp_dashboard_rev_disp");
end

-----------------------------------------------------------------------------------------------
-- VIOLATIONS
-----------------------------------------------------------------------------------------------
local function violation_max(name)
    n_agents = 5;

    generic = Generic();
    violation = generic:load(name);
    if violation:loaded() then
        violation = violation:aggregate_scenarios(BY_MAX()):aggregate_blocks(BY_MAX());

        n = violation:agents_size();
        if n > n_agents then
            aux = violation:aggregate_stages(BY_MAX());
            largest_agents = aux:select_largest_agents(n_agents):agents();

            violation = concatenate(
                violation:select_agents(largest_agents),
                violation:remove_agents(largest_agents):aggregate_agents(BY_SUM(), "Others")
            );
        end
        violation:save("sddp_dashboard_viol_" .. name, {remove_zeros = true});
    end
end

violation_max("defcit");
violation_max("defcitp");
violation_max("nedefc");
violation_max("defbus");
violation_max("defbusp");
violation_max("gncivio");
violation_max("gncvio");
violation_max("vrestg");
violation_max("excbus");
violation_max("excsis");
violation_max("vvaler");
violation_max("vioguide");
violation_max("vriego");
violation_max("vmxost");
violation_max("vimxsp");
violation_max("vdefmx");
violation_max("vvolmn");
violation_max("vdefmn");
violation_max("vturmn");
violation_max("vimnsp");
violation_max("rampvio");
violation_max("vreseg");
violation_max("vfeact");
violation_max("vsarhd");
violation_max("vsarhden");
violation_max("viocar");
violation_max("vgmint");
violation_max("vioemiq");
violation_max("vsecset");
violation_max("valeset");
violation_max("vespset");