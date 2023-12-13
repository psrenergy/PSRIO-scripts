-----------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS
-----------------------------------------------------------------------------------------------

local function violation_aggregation(log_viol,viol_struct,aggregation,suffix,tol)
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
            viol_file_name = "sddp_dashboard_viol_" .. suffix .. "_" .. viol_struct.name
        	violation:remove_zeros():save(viol_file_name, {csv=true});
			info("Violation dashboard for " .. viol_struct.name .. " created successfully.")
            if log_viol.file:is_open() then
                log_viol.file:write(viol_file_name .. "\n");
                log_viol.nrec = log_viol.nrec + 1;
            else
                info("Error writing violation log file");
            end
		else
			info("Violation values for " .. viol_struct.name .. " aren't significatives. Skipping save... ")
		end
    end
end

local function violation_output(log_viol, out_list, viol_structs, tol)
    local file_exists;

    for i, viol_struct in ipairs(viol_structs) do
        file_exists = false;
        for j, out_file in ipairs(out_list) do
            if out_file == viol_struct.name then
                file_exists = true;
            end
        end

        if file_exists then
            has_at_least_one_out = true;

--          Aggregation by Max
            violation_aggregation(log_viol,viol_struct,BY_MAX(),"max",tol)
--          Aggregation by Average
            violation_aggregation(log_viol,viol_struct,BY_AVERAGE(),"avg",tol)
        end
    end

    if log_viol.nrec == 0 then
        info("Entrou aqui");
        if log_viol.file:is_open() then
            log_viol.file:write("empty");
        end
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
    (costs/discount_rate()):aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):remove_zeros():save("sddp_dashboard_cost_tot", {csv=true});

    -- sddp_dashboard_cost_avg
    costs:aggregate_scenarios(BY_AVERAGE()):remove_zeros():save("sddp_dashboard_cost_avg", {csv=true});

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
    (revenues/discount_rate()):aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):remove_zeros():save("sddp_dashboard_rev_tot", {csv=true});

    -- sddp_dashboard_rev_avg
    revenues:aggregate_scenarios(BY_AVERAGE()):remove_zeros():save("sddp_dashboard_rev_avg", {csv=true});

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
-- DEFICIT RISK
-----------------------------------------------------------------------------------------------
local defrisk = require("sddp-reports/sddprisk")();
defrisk:save("sddprisk",{csv=true});

-----------------------------------------------------------------------------------------------
-- VIOLATIONS
-----------------------------------------------------------------------------------------------

-- IMPORTANT: the name of the violation must be the same as the dependency
viol_structs = {
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
	{name = "tuvio", aggregation = BY_SUM()}
}

viol_structs_debug = {
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
        file = sddp_outputs[lin][1];
        table.insert(out_list,file);
    end
end

-- Log file with violation files used execution
log_viol = {file = Generic():create_writer("sddp_viol.out"), nrec = 0};
violation_output(log_viol, out_list, viol_structs, 0.01)
log_viol.file:close();
-----------------------------------------------------------------------------------------------
-- RENEWABLES
-----------------------------------------------------------------------------------------------
local rnw = Renewable();

-- Get renewable generation spillage
rnw_spill = rnw:load("vergnd");

rnw_spill:aggregate_agents(BY_SUM(), Collection.SYSTEM):aggregate_scenarios(BY_AVERAGE()):remove_zeros():save("sddp_dashboard_result_avg_vergnd",{csv=true});

-----------------------------------------------------------------------------------------------
-- LGC
-----------------------------------------------------------------------------------------------
local lgcgen = Hydro():load("lgcgen");
local lgcrev = Hydro():load("lgcrev");

-- sddp_dashboard_lgc_gen
lgcgen:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM(), Profile.PER_YEAR):remove_zeros():save("sddp_dashboard_lgc_gen", {csv=true});

-- sddp_dashboard_lgc_rev
lgcrev:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM(), Profile.PER_YEAR):remove_zeros():save("sddp_dashboard_lgc_rev", {csv=true});

-----------------------------------------------------------------------------------------------
-- CIRCUIT LOSSES ERROR
-----------------------------------------------------------------------------------------------
-- sddp_dashboard_AC_circuit_linear_losses
local lsserac = Circuit():load("lsserac");
if lsserac:loaded() then
    lsserac:save("sddp_dashboard_AC_losses_error", {csv=true});
end

-- sddp_dashboard_DC_circuit_linear_losses
local lsserdc = Circuit():load("lsserdc");
if lsserdc:loaded() then
    lsserdc:save("sddp_dashboard_DC_losses_error", {csv=true});
end