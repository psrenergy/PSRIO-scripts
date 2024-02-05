-----------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS
-----------------------------------------------------------------------------------------------
local function violation_aggregation(log_viol, data, data_name, aggregation, suffix, maximum)
    local n_agents = 5;

	local violation_agg = data:aggregate_scenarios(aggregation);
	local n = violation_agg:agents_size();
	if n > n_agents then
		local largest_agents = maximum:select_largest_agents(n_agents)
									  :agents();

		violation_agg = concatenate(
			violation_agg:select_agents(largest_agents),
			violation_agg:remove_agents(largest_agents):aggregate_agents(BY_SUM(), "Others")
		);
	end
	local violation_file_name = "sddp_dashboard_viol_" .. suffix .. "_" .. data_name
	violation_agg:save(violation_file_name, { csv = true });

	if log_viol.file:is_open() then
		log_viol.file:write(violation_file_name .. "\n");
		log_viol.nrec = log_viol.nrec + 1;
	else
		info("Error writing violation log file");
	end
end

local function violation_output(log_viol, out_list, viol_structs, tol)
	local generic = Generic();

    for _, viol_struct in ipairs(viol_structs) do
		if out_list[viol_struct.name] then
			local file_name = viol_struct.name;
			local violation = generic:load(file_name);
			if violation:loaded() then
				violation = violation:remove_zeros();
				if violation:loaded() then

					if viol_struct.signal then
						if viol_struct.signal == "positive" then
							violation = max(violation,0);
						elseif viol_struct.signal == "negative" then
							violation = min(violation,0) * (-1);
						end
						file_name = file_name .. "_" .. viol_struct.signal;
					end

					local violation_agg = violation:aggregate_blocks(viol_struct.aggregation):save_cache();
					local maximum = violation:abs()
									:aggregate_blocks(viol_struct.aggregation)
									:aggregate_stages(BY_SUM())
									:aggregate_scenarios(BY_SUM())
									:save_cache();

					local x = maximum:aggregate_agents(BY_SUM(),"Total"):to_list()[1];

					if x > tol then
				--      Aggregation by Max
						violation_aggregation(log_viol,violation_agg,file_name,BY_MAX(),"max",maximum)
				--      Aggregation by Average
						violation_aggregation(log_viol,violation_agg,file_name,BY_AVERAGE(),"avg",maximum)

						info("Violation dashboard for " .. file_name .. " created successfully.")
					else
						info("Violation values for " .. file_name .. " aren't significatives. Skipping save... ")
					end
				end
			end
		end
    end

	if log_viol.nrec == 0 then
        if log_viol.file:is_open() then
            log_viol.file:write("empty");
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
        local x = agg_output:abs():aggregate_stages(BY_SUM()):aggregate_scenarios(BY_SUM()):to_list()[1];
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
local discount_rate = discount_rate():save_cache();
local objcop_function = require("sddp/costs");
local objcop = objcop_function();

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
    local x = disp_agg:aggregate_stages(BY_SUM()):aggregate_scenarios(BY_SUM()):aggregate_blocks(BY_SUM()):to_list()[1];
    if x > 0.0 then
		local disp = concatenate(
			disp_agg:aggregate_scenarios(BY_PERCENTILE(10)),
			disp_agg:rename_agents({"Average"}):aggregate_scenarios(BY_AVERAGE()),
			disp_agg:rename_agents({"P90"}):aggregate_scenarios(BY_PERCENTILE(90))
		);
        disp:save("sddp_dashboard_rev_disp", {csv=true});
    end
end

-----------------------------------------------------------------------------------------------
-- DEFICIT RISK
-----------------------------------------------------------------------------------------------
local defrisk = require("sddp-reports/sddprisk")();
defrisk:save("sddprisk",{csv=true});

-----------------------------------------------------------------------------------------------
-- VIOLATIONS
-----------------------------------------------------------------------------------------------
local viol_structs = {
	{name = "defcit", aggregation = BY_SUM()},
	{name = "nedefc", aggregation = BY_AVERAGE()},
	{name = "defbus", aggregation = BY_SUM()},
	{name = "defbusp", aggregation = BY_AVERAGE()},
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
	{name = "tuvio", aggregation = BY_SUM()},
	{name = "lsserac", aggregation = BY_AVERAGE(), signal = "positive"},
	{name = "lsserac", aggregation = BY_AVERAGE(), signal = "negative"},
	{name = "lsserdc", aggregation = BY_AVERAGE(), signal = "positive"},
	{name = "lsserdc", aggregation = BY_AVERAGE(), signal = "negative"},
    {name = "lsserdcl", aggregation = BY_AVERAGE(), signal = "positive"},
	{name = "lsserdcl", aggregation = BY_AVERAGE(), signal = "negative"}
}

local viol_structs_debug = {
	{name = "defcitp", aggregation = BY_AVERAGE()},
	{name = "vfeact", aggregation = BY_AVERAGE()}
}

-- Load output files from SDDP model
local output_list_name = "outfiles.out";
local out_list = {};

local sddp_outputs = Generic():load_table_without_header(output_list_name);
if #sddp_outputs > 0 then
    -- Create list of violation outputs to be considered
    for lin = 1, #sddp_outputs do
        local file = sddp_outputs[lin][1];
		out_list[file] = true;
    end
end

-- Log file with violation files used execution
local log_viol = {file = Generic():create_writer("sddp_viol.out"), nrec = 0};
violation_output(log_viol, out_list, viol_structs, 0.01)
log_viol.file:close();

-- -----------------------------------------------------------------------------------------------
-- -- RENEWABLES
-- -----------------------------------------------------------------------------------------------
-- local rnw = Renewable();

-- -- Get renewable generation spillage
-- local rnw_spill = rnw:load("vergnd");

-- rnw_spill:aggregate_agents(BY_SUM(), Collection.SYSTEM):aggregate_scenarios(BY_AVERAGE()):remove_zeros():save("sddp_dashboard_result_avg_vergnd",{ csv = true });

-----------------------------------------------------------------------------------------------
-- LGC
-----------------------------------------------------------------------------------------------
local lgcgen = Hydro():load("lgcgen");
local lgcrev = Hydro():load("lgcrev");

-- sddp_dashboard_lgc_gen
lgcgen:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM(), Profile.PER_YEAR):remove_zeros():save("sddp_dashboard_lgc_gen", { csv = true });

-- sddp_dashboard_lgc_rev
lgcrev:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM(), Profile.PER_YEAR):remove_zeros():save("sddp_dashboard_lgc_rev", { csv = true });
