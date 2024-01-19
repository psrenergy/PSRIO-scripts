-----------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS
-----------------------------------------------------------------------------------------------
local function violation_aggregation(data,data_name,aggregation,suffix,tol)
    local n_agents = 5;

	local violation_agg = data:aggregate_scenarios(aggregation);
	local violation_agg_stg = violation_agg:aggregate_stages(BY_SUM());
	local x = violation_agg_stg:aggregate_agents(BY_SUM(),"Total"):to_list()[1];
	if x > tol then

		local n = violation_agg:agents_size();
		if n > n_agents then
			local largest_agents = violation_agg_stg:select_largest_agents(n_agents):agents();

			violation_agg = concatenate(
				violation_agg:select_agents(largest_agents),
				violation_agg:remove_agents(largest_agents):aggregate_agents(BY_SUM(), "Others")
			);
		end
		violation_agg:remove_zeros():save("sddp_dashboard_viol_" .. suffix .. "_" .. data_name, { csv = true });
		info("Violation dashboard for " .. data_name .. " created successfully.")
	else
		info("Violation values for " .. data_name .. " aren't significatives. Skipping save... ")
	end

end

local function violation_output(viol_structs,tol)
    for i, viol_struct in ipairs(viol_structs) do
		local generic = Generic();
		local violation = generic:load(viol_struct.name);
		
		if violation:loaded() then
			local violation_agg = violation:aggregate_blocks(viol_struct.aggregation):save_cache();

	--      Aggregation by Max
			violation_aggregation(violation_agg,viol_struct.name,BY_MAX(),"max",tol)
	--      Aggregation by Average
			violation_aggregation(violation_agg,viol_struct.name,BY_AVERAGE(),"avg",tol)
		end
    end
end

local function dispersion(output,file_name)
	local agg_output = output:aggregate_agents(BY_SUM(), "P10"):save_cache();
    if output:loaded() then
        local disp = concatenate(
            agg_output:aggregate_scenarios(BY_PERCENTILE(10)),
            agg_output:rename_agents({"Average"}):aggregate_scenarios(BY_AVERAGE()),
            agg_output:rename_agents({"P90"}):aggregate_scenarios(BY_PERCENTILE(90))
        );
        local x = agg_output:aggregate_stages(BY_SUM()):aggregate_scenarios(BY_SUM()):to_list()[1];
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

local discount_rate = discount_rate():save_cache();
local objcop_function = require("sddp/costs");
local objcop = objcop_function();
-----------------------------------------------------------------------------------------------
-- COSTS
-----------------------------------------------------------------------------------------------
local costs = max(objcop,0):save_cache();

if( costs:loaded() ) then
    -- sddp_dashboard_cost_tot. Considering discount rate in the cost aggregation
    (costs/discount_rate):aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):remove_zeros():save("sddp_dashboard_cost_tot", { csv = true });
    
    -- sddp_dashboard_cost_avg
    costs:aggregate_scenarios(BY_AVERAGE()):remove_zeros():save("sddp_dashboard_cost_avg", { csv = true });
    
    -- sddp_dashboard_cost_disp
	local cost_agg = costs:aggregate_agents(BY_SUM(), "P10"):save_cache();
    local costs = concatenate(
        cost_agg:aggregate_scenarios(BY_PERCENTILE(10)),
        cost_agg:rename_agents({"Average"}):aggregate_scenarios(BY_AVERAGE()),
        cost_agg:rename_agents({"P90"}):aggregate_scenarios(BY_PERCENTILE(90))
    );
    local x = costs:aggregate_stages(BY_SUM()):aggregate_scenarios(BY_SUM()):to_list()[1];
    if x > 0.0 then
        costs:save("sddp_dashboard_cost_disp", {csv=true});
    end
end

-----------------------------------------------------------------------------------------------
-- REVENUES
-----------------------------------------------------------------------------------------------
local revenues = (-min(objcop,0)):save_cache();

if( revenues:loaded() ) then
    -- sddp_dashboard_rev_tot. Considering discount rate in the revenue aggregation
    (revenues/discount_rate):aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):remove_zeros():save("sddp_dashboard_rev_tot", { csv = true });
    
    -- sddp_dashboard_rev_avg
    revenues:aggregate_scenarios(BY_AVERAGE()):remove_zeros():save("sddp_dashboard_rev_avg", { csv = true });
    
    -- sddp_dashboard_rev_disp
	local disp_agg = costs:aggregate_agents(BY_SUM(), "P10"):save_cache();
    local disp = concatenate(
        disp_agg:aggregate_scenarios(BY_PERCENTILE(10)),
        disp_agg:rename_agents({"Average"}):aggregate_scenarios(BY_AVERAGE()),
        disp_agg:rename_agents({"P90"}):aggregate_scenarios(BY_PERCENTILE(90))
    );
    local x = disp:aggregate_stages(BY_SUM()):aggregate_scenarios(BY_SUM()):to_list()[1];
    if x > 0.0 then
        disp:save("sddp_dashboard_rev_disp", {csv=true});
    end
end

-----------------------------------------------------------------------------------------------
-- VIOLATIONS
-----------------------------------------------------------------------------------------------
local viol_structs = {
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
	{name = "cflwvio", aggregation = BY_AVERAGE()},
	{name = "fcofdvio", aggregation = BY_SUM()},
	{name = "edemdef", aggregation = BY_SUM()},
	{name = "tuvio", aggregation = BY_SUM()}
}

local viol_structs_debug = {
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
local rnw_spill = rnw:load("vergnd");

rnw_spill:aggregate_agents(BY_SUM(), Collection.SYSTEM):aggregate_scenarios(BY_AVERAGE()):remove_zeros():save("sddp_dashboard_result_avg_vergnd",{ csv = true });

-----------------------------------------------------------------------------------------------
-- LGC
-----------------------------------------------------------------------------------------------
local lgcgen = Hydro():load("lgcgen");
local lgcrev = Hydro():load("lgcrev");

-- sddp_dashboard_lgc_gen
lgcgen:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM(), Profile.PER_YEAR):remove_zeros():save("sddp_dashboard_lgc_gen", { csv = true });

-- sddp_dashboard_lgc_rev
lgcrev:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM(), Profile.PER_YEAR):remove_zeros():save("sddp_dashboard_lgc_rev", { csv = true });
