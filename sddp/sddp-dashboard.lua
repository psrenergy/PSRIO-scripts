-----------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS
-----------------------------------------------------------------------------------------------

local function violation_aggregation(name,aggregation,suffix)
    n_agents = 5;

    generic = Generic();
    violation = generic:load(name);
    if violation:loaded() then
        violation = violation:aggregate_scenarios(aggregation):aggregate_blocks(aggregation);

        n = violation:agents_size();
        if n > n_agents then
            aux = violation:aggregate_stages(aggregation);
            largest_agents = aux:select_largest_agents(n_agents):agents();

            violation = concatenate(
                violation:select_agents(largest_agents),
                violation:remove_agents(largest_agents):aggregate_agents(BY_SUM(), "Others")
            );
        end
        violation:save("sddp_dashboard_viol_" .. suffix .. "_" .. name, {remove_zeros = true, csv=true});
    end
end

local function violation_output(names)
    for i, name in ipairs(names) do
--      Aggregation by Max
        violation_aggregation(name,BY_MAX(),"max")
--      Aggregation by Average
        violation_aggregation(name,BY_AVERAGE(),"avg")
    end
end

local function dispersion(output,file_name)
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

-- sddp_dashboard_cost_tot
costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):save("sddp_dashboard_cost_tot", {remove_zeros = true, csv=true});

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

-----------------------------------------------------------------------------------------------
-- REVENUES
-----------------------------------------------------------------------------------------------
local revenues = ifelse(objcop():le(0), -objcop(), 0);

-- sddp_dashboard_rev_tot
revenues:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):save("sddp_dashboard_rev_tot", {remove_zeros = true, csv=true});

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

-----------------------------------------------------------------------------------------------
-- VIOLATIONS
-----------------------------------------------------------------------------------------------
names_viol = {
	"defcit",
	"defcitp",
	"nedefc",
	"defbus",
	"defbusp",
	"gncivio",
	"gncvio",
	"vrestg",
	"excbus",
	"excsis",
	"vvaler",
	"vioguide",
	"vriego",
	"vmxost",
	"vimxsp",
	"vdefmx",
	"vvolmn",
	"vdefmn",
	"vturmn",
	"vimnsp",
	"rampvio",
	"vreseg",
	"vfeact",
	"vsarhd",
	"vsarhden",
	"viocar",
	"vgmint",
	"vioemiq",
	"vsecset",
	"valeset",
	"vespset"
}

violation_output(names_viol)

-----------------------------------------------------------------------------------------------
-- RENEWABLES
-----------------------------------------------------------------------------------------------
local rnw = Renewable();

-- Get renewable generation spillage
rnw_spill = rnw:load("vergnd");

rnw_spill:aggregate_scenarios(BY_AVERAGE()):save("sddp_dashboard_result_avg_vergnd",{remove_zeros=true, csv=true});
