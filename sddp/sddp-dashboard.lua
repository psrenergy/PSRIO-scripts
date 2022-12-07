-----------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS
-----------------------------------------------------------------------------------------------

local function violation_aggregation(viol_struct,aggregation,suffix,tol)
    n_agents = 5;

    generic = Generic();
    violation = generic:load(viol_struct.name);
    
    if violation:loaded() then
    	x = violation:aggregate_scenarios(aggregation):aggregate_blocks(viol_struct.aggregation):aggregate_agents(BY_SUM(),"Total"):aggregate_stages(BY_SUM()):to_list()[1];
    	if x > tol then
        	violation = violation:aggregate_scenarios(aggregation):aggregate_blocks(viol_struct.aggregation);

        	n = violation:agents_size();
        	if n > n_agents then
            	aux = violation:aggregate_stages(BY_SUM());
            	largest_agents = aux:select_largest_agents(n_agents):agents();

            	violation = concatenate(
                	violation:select_agents(largest_agents),
                	violation:remove_agents(largest_agents):aggregate_agents(BY_SUM(), "Others")
            	);
        	end
        	violation:save("sddp_dashboard_viol_" .. suffix .. "_" .. viol_struct.name, {remove_zeros = true, csv=true});
			info("Violation dashboard for " .. viol_struct.name .. " created successfully.")
		else
			info("Violation values for " .. viol_struct.name .. " aren't significatives. Skipping save... ")
		end
    end
end

local function violation_output(viol_structs,tol)
    for i, viol_struct in ipairs(viol_structs) do
--      Aggregation by Max
        violation_aggregation(viol_struct,BY_MAX(),"max",tol)
--      Aggregation by Average
        violation_aggregation(viol_struct,BY_AVERAGE(),"avg",tol)
    end
end

local function dispersion(output,file_name)
    if output:loaded() then
        disp = concatenate(
            output:aggregate_agents(BY_SUM(), "P10"):aggregate_scenarios(BY_PERCENTILE(10)),
            output:aggregate_agents(BY_SUM(), "Average"):aggregate_scenarios(BY_AVERAGE()),
            output:aggregate_agents(BY_SUM(), "P90"):aggregate_scenarios(BY_PERCENTILE(90))
        );
        x = disp:aggregate_agents(BY_SUM(), "CheckZeros"):aggregate_stages(BY_SUM()):to_list()[1];
        if x > 0.0 then
            disp:save(file_name, {csv=true});
        end
    end
end

-- Local function for discount rate calculation
local function discount_rate()
    local study = Study();
    return (1 + study.discount_rate) ^ ((study.stage - 1) / study:stages_per_year());
end

-----------------------------------------------------------------------------------------------
-- INPUT DATA
-----------------------------------------------------------------------------------------------
-- Inflow energy
local enaflu = Generic():load("enaflu");

dispersion(enaflu,"sddp_dashboard_input_enaflu")

-----------------------------------------------------------------------------------------------
-- COSTS
-----------------------------------------------------------------------------------------------
local objcop = require("sddp/costs");
local costs = ifelse(objcop():ge(0), objcop(), 0);

if( costs:loaded() ) then
    -- sddp_dashboard_cost_tot. Considering discount rate in the cost aggregation
    (costs/discount_rate()):aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):save("sddp_dashboard_cost_tot", {remove_zeros = true, csv=true});
    
    -- sddp_dashboard_cost_avg
    costs:aggregate_scenarios(BY_AVERAGE()):save("sddp_dashboard_cost_avg", {remove_zeros = true, csv=true});
    
    -- sddp_dashboard_cost_disp
    disp = concatenate(
        costs:aggregate_agents(BY_SUM(), "P10"):aggregate_scenarios(BY_PERCENTILE(10)),
        costs:aggregate_agents(BY_SUM(), "Average"):aggregate_scenarios(BY_AVERAGE()),
        costs:aggregate_agents(BY_SUM(), "P90"):aggregate_scenarios(BY_PERCENTILE(90))
    );
    x = disp:aggregate_agents(BY_SUM(), "CheckZeros"):aggregate_stages(BY_SUM()):to_list()[1];
    if x > 0.0 then
        disp:save("sddp_dashboard_cost_disp", {csv=true});
    end
end

-----------------------------------------------------------------------------------------------
-- REVENUES
-----------------------------------------------------------------------------------------------
local revenues = ifelse(objcop():le(0), -objcop(), 0);

if( revenues:loaded() ) then
    -- sddp_dashboard_rev_tot. Considering discount rate in the revenue aggregation
    (revenues/discount_rate()):aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):save("sddp_dashboard_rev_tot", {remove_zeros = true, csv=true});
    
    -- sddp_dashboard_rev_avg
    revenues:aggregate_scenarios(BY_AVERAGE()):save("sddp_dashboard_rev_avg", {remove_zeros = true, csv=true});
    
    -- sddp_dashboard_rev_disp
    disp = concatenate(
        revenues:aggregate_agents(BY_SUM(), "P10"):aggregate_scenarios(BY_PERCENTILE(10)),
        revenues:aggregate_agents(BY_SUM(), "Average"):aggregate_scenarios(BY_AVERAGE()),
        revenues:aggregate_agents(BY_SUM(), "P90"):aggregate_scenarios(BY_PERCENTILE(90))
    );
    x = disp:aggregate_agents(BY_SUM(), "CheckZeros"):aggregate_stages(BY_SUM()):to_list()[1];
    if x > 0.0 then
        disp:save("sddp_dashboard_rev_disp", {csv=true});
    end
end

-----------------------------------------------------------------------------------------------
-- VIOLATIONS
-----------------------------------------------------------------------------------------------
viol_structs = {
	{name = "defcit", aggregation = BY_SUM()},
	{name = "nedefc", aggregation = BY_AVERAGE()},
	{name = "defbus", aggregation = BY_SUM()},
	{name = "gncivio", aggregation = BY_SUM()},
	{name = "gncvio", aggregation = BY_SUM()},
	{name = "vrestg", aggregation = BY_AVERAGE()},
	{name = "excbus", aggregation = BY_SUM()},
	{name = "excsis", aggregation = BY_SUM()},
	{name = "vvaler", aggregation = BY_AVERAGE()},
	{name = "vioguide", aggregation = BY_SUM()},
	{name = "vriego", aggregation = BY_AVERAGE()},
	{name = "vmxost", aggregation = BY_AVERAGE()},
	{name = "vimxsp", aggregation = BY_AVERAGE()},
	{name = "vdefmx", aggregation = BY_AVERAGE()},
	{name = "vvolmn", aggregation = BY_AVERAGE()},
	{name = "vdefmn", aggregation = BY_AVERAGE()},
	{name = "vturmn", aggregation = BY_AVERAGE()},
	{name = "vimnsp", aggregation = BY_AVERAGE()},
	{name = "rampvio", aggregation = BY_SUM()},
	{name = "vreseg", aggregation = BY_AVERAGE()},
	{name = "vsarhd", aggregation = BY_AVERAGE()},
	{name = "vsarhden", aggregation = BY_AVERAGE()},
	{name = "viocar", aggregation = BY_AVERAGE()},
	{name = "vgmint", aggregation = BY_AVERAGE()},
	{name = "vgmntt", aggregation = BY_AVERAGE()},
	{name = "vioemiq", aggregation = BY_AVERAGE()},
	{name = "vsecset", aggregation = BY_SUM()},
	{name = "valeset", aggregation = BY_SUM()},
	{name = "vespset", aggregation = BY_SUM()},
    {name = "fcoffvio", aggregation = BY_SUM()},
	{name = "vflmnww", aggregation = BY_AVERAGE()},
	{name = "vflmxww", aggregation = BY_AVERAGE()},
	{name = "finjvio", aggregation = BY_SUM()},
	{name = "cflwvio", aggregation = BY_AVERAGE()}
}

viol_structs_debug = {
	{name = "defcitp", aggregation = BY_AVERAGE()},
	{name = "defbusp", aggregation = BY_AVERAGE()},
	{name = "vfeact", aggregation = BY_AVERAGE()}
}

violation_output(viol_structs, 0.01)

-----------------------------------------------------------------------------------------------
-- RENEWABLES
-----------------------------------------------------------------------------------------------
local rnw = Renewable();

-- Get renewable generation spillage
rnw_spill = rnw:load("vergnd");

rnw_spill:aggregate_agents(BY_SUM(), Collection.SYSTEM):aggregate_scenarios(BY_AVERAGE()):save("sddp_dashboard_result_avg_vergnd",{remove_zeros=true, csv=true});

-----------------------------------------------------------------------------------------------
-- LGC
-----------------------------------------------------------------------------------------------
local lgcgen = Hydro():load("lgcgen");
local lgcrev = Hydro():load("lgcrev");

-- sddp_dashboard_lgc_gen
lgcgen:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM(), Profile.PER_YEAR):save("sddp_dashboard_lgc_gen", {remove_zeros = true, csv=true});

-- sddp_dashboard_lgc_rev
lgcrev:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM(), Profile.PER_YEAR):save("sddp_dashboard_lgc_rev", {remove_zeros = true, csv=true});
