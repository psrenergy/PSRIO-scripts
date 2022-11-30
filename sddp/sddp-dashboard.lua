local generic = Generic();
local study = Study();
local thermal = Thermal();
local hydro = Hydro();
local renewable = Renewable();
local battery = Battery();
local power_injection = PowerInjection();
local system = System();

local function add_chart_line(dashboard, output, output_name)
	local chart = Chart(output_name);-- Create chart
	for i, out in pairs(output) do
		chart:add_line(out);         -- Add output
	end
	dashboard:push(chart);           -- Add outputs to informed dashboard
end

local function add_chart_column(dashboard, output, output_name)
	local chart = Chart(output_name); -- Create chart
	for _, out in pairs(output) do
		chart:add_column(out);        -- Add output
	end
	dashboard:push(chart);            -- Add outputs to informed dashboard
end

local function add_chart_pie(dashboard, output, output_name)
	local chart = Chart(output_name); -- Create chart
	for _, out in pairs(output) do
		chart:add_pie(out);           -- Add output
	end
	dashboard:push(chart);            -- Add outputs to informed dashboard
end

local function add_chart_area_stacking(dashboard, output, output_name)
	local chart = Chart(output_name); -- Create chart
	for _, out in pairs(output) do
		chart:add_area_stacking(out); -- Add output
	end
	dashboard:push(chart);            -- Add outputs to informed dashboard
end

local function discount_rate()
	return (1 + study.discount_rate) ^ ((study.stage - 1) / study:stages_per_year()); -- Discount rate	
end

local function is_greater_than_zero(output)
	local x = output:aggregate_agents(BY_SUM(), "CheckZeros"):aggregate_stages(BY_SUM()):to_list();
	if x[1] > 0.0 then
		return true;
	else
		return false;
	end
end

local function get_conv_file_info(file_list, horizons)
    -- Loading file
    local sddppol = generic:load_table("sddppol.csv");

    local file_name = "";
    for i = 1, #sddppol do
        file_name = sddppol[i]["FileNames"]
        file_list[i] = string.sub(file_name, 1, #file_name - 4)
        horizons[i] = sddppol[i]["InitialHorizon"] .. ":" .. sddppol[i]["FinalHorizon"];
    end
end

-----------------------------------------------------------------------------------------------
-- SDDP OUTPUT GENERATION FUNCTIONS
-----------------------------------------------------------------------------------------------

local function make_inflow_energy(dashboard)
    local inferg = generic:load("sddp_dashboard_input_enaflu");
    local chart = Chart("Total inflow energy");
    chart:add_area_range(inferg:select_agent(1), inferg:select_agent(3)); -- Confidence interval
    chart:add_line(inferg:select_agent(2)); -- average
    dashboard:push(chart);
end

local function make_sddp_total_gen(dashboard,chart_title)
	-- Loading generations files
	local gerter = thermal:load("gerter");
	local gerhid = hydro:load("gerhid");
	local gergnd = renewable:load("gergnd");
	local gerbat = renewable:load("gerbat");
	local potinj = power_injection:load("powinj");
	local def    = system:load("defcit")

	-- Data processing
	local total_thermal_gen = gerter:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Thermal");
	local total_hydro_gen   = gerhid:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Hydro");
	local total_rnw_gen     = gergnd:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Renewable");
	local total_batt_gen    = gerbat:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Battery");
	local total_pot_inj     = potinj:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total P. Inj.");
	local total_deficit     = def:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Deficit");

	add_chart_area_stacking(dashboard, { total_thermal_gen, total_hydro_gen, total_rnw_gen, total_batt_gen, total_pot_inj, total_deficit }, chart_title);
end

local function make_costs_and_revs(dashboard)
	local objcop = require("sddp/costs");
	local costs = ifelse(objcop():ge(0), objcop(), 0) / discount_rate();

	-- sddp_dashboard_cost_tot
	costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):save("sddp_dashboard_cost_tot", {remove_zeros = true, csv=true});

	-- sddp_dashboard_cost_avg
	local costs_avg = costs:aggregate_scenarios(BY_AVERAGE()):select_agent(1);

	-- sddp_dashboard_cost_disp
	local disp = concatenate(
		costs:aggregate_agents(BY_SUM(), "P10"):aggregate_scenarios(BY_PERCENTILE(10)),
		costs:aggregate_agents(BY_SUM(), "Average"):aggregate_scenarios(BY_AVERAGE()),
		costs:aggregate_agents(BY_SUM(), "P90"):aggregate_scenarios(BY_PERCENTILE(90))
	);

	if is_greater_than_zero(costs_avg) then
		add_chart_column(dashboard, { costs_avg }, "Average operating costs per stage");
	end

	if is_greater_than_zero(disp) then
		add_chart_line(dashboard, { disp }, "Dispersion of operating costs per stage");
	end
end

local function make_marg_costs(dashboard)
	local cmg = system:load("cmgdem")

	-- Marginal cost aggregated by average
	local cmg_aggsum  = cmg:aggregate_blocks(BY_AVERAGE());
	local cmg_aggyear = cmg:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR);

	-- Add marginal costs outputs
	add_chart_column(dashboard,{cmg_aggsum},"Average marginal costs per stage per subsystem"); -- Average Marg. cost
	add_chart_column(dashboard,{cmg_aggyear},"Annual marginal cost by sub-system"); -- Annual Marg. cost 
end

local function make_risk_report(dashboard)
    local risk_file = generic:load("sddprisk");
    local chart = Chart("Deficit risk by sub-system");
    chart:add_column(risk_file);
    dashboard:push(chart);
end

local function get_convergence_file_agents(file_list, conv_age, cuts_age)
    for i, file in ipairs(file_list) do
        local conv_file = generic:load(file);
        conv_age[i] = conv_file:select_agents({1, 2, 3, 4}); -- Zinf        ,Zsup - Tol  ,Zsup        ,Zsup + Tol  
        cuts_age[i] = conv_file:select_agents({5, 6});     -- Optimality  ,Feasibility 
    end
end

local function make_convergence_graphs(dashboard, conv_age, horizon)
    for i, conv in ipairs(conv_age) do
        local chart = Chart("Convergence report | Horizon: " .. horizon[i]);
        chart:add_area_range(conv:select_agents({2}), conv:select_agents({4}), { xAllowDecimals = false }); -- Confidence interval
        chart:add_line(conv:select_agents({1}), { xAllowDecimals = false }); -- Zinf
        chart:add_line(conv:select_agents({3}), { xAllowDecimals = false }); -- Zsup
        dashboard:push(chart);
    end
end

local function make_added_cuts_graphs(dashboard, cuts_age, horizon)
    for i, cuts in ipairs(cuts_age) do
        local chart = Chart("Number of added cuts report | Horizon: " .. horizon[i]);
        chart:add_column(cuts:select_agents({1}), { xAllowDecimals = false }); -- Opt
        chart:add_column(cuts:select_agents({2}), { xAllowDecimals = false }); -- Feas
        dashboard:push(chart);
    end 
end

local function make_penalty_proportion_graph(dashboard)
    local penp = generic:load("sddppenp");
    local chart = Chart("Share of violation penalties and deficit in the cost of each stage/scenario");
    chart:add_heatmap_hourly(penp);
    dashboard:push(chart);
end

local function make_conv_map_graph(dashboard)
    local conv_map = generic:load("sddpconvmap");
    local chart = Chart("Convergence map");
    chart:add_heatmap_hourly(conv_map);
    dashboard:push(chart);
end

local function make_hourly_sol_status_graph(dashboard)
    local status = generic:load("sddpstatus");
    local chart = Chart("Execution status per stage and scenario");
    chart:add_heatmap_hourly(penp);
    dashboard:push(chart);
end

-----------------------------------------------------------------------------------------------
-- Violation reports methods
-----------------------------------------------------------------------------------------------

local viol_report_structs = {
	{name = "defcit",   title = "Deficit"},
	{name = "nedefc",   title = "Deficit associated to non-electrical gas demand"},
	{name = "defbus",   title = "Deficit per bus (% of load)"},
	{name = "gncivio",  title = "General interpolation constraint violation"},
	{name = "gncvio",   title = "General constraint: linear"},
	{name = "vrestg",   title = "Generation constraint violation"},
	{name = "excbus",   title = "Generation excess per AC bus"},
	{name = "excsis",   title = "Generation excess per system"},
	{name = "vvaler",   title = "Alert storage violation"},
	{name = "vioguide", title = "Guide curve violation per hydro reservoir"},
	{name = "vriego",   title = "Hydro: irrigation"},
	{name = "vmxost",   title = "Hydro: maximum operative storage"},
	{name = "vimxsp",   title = "Hydro: maximum spillage"},
	{name = "vdefmx",   title = "Hydro: maximum total outflow"},
	{name = "vvolmn",   title = "Hydro: minimum storage"},
	{name = "vdefmn",   title = "Hydro: minimum total outflow"},
	{name = "vturmn",   title = "Hydro: minimum turbining outflow"},
	{name = "vimnsp",   title = "Hydro: mininum spillage"},
	{name = "rampvio",  title = "Hydro: outflow ramp"},
	{name = "vreseg",   title = "Reserve: joint requirement"},
	{name = "vsarhd",   title = "RAS target storage violation %"},
	{name = "vsarhden", title = "RAS target storage violation GWh"},
	{name = "viocar",   title = "Risk Aversion Curve"},
	{name = "vgmint",   title = "Thermal: minimum generation"},
	{name = "vgmntt",   title = "NE"},
	{name = "vioemiq",  title = "Emission budget violation"},
	{name = "vsecset",  title = "Reservoir set: security energy constraint"},
	{name = "valeset",  title = "Reservoir set: alert energy constraint"},
	{name = "vespset",  title = "Reservoir set: flood control energy constraint"},
    {name = "fcoffvio", title = "Fuel contract minimum offtake rate violation"},
	{name = "vflmnww",  title = "Minimum hydro bypass flow violation"},
	{name = "vflmxww",  title = "Maximum hydro bypass flow violation"},
	{name = "finjvio",  title = "NE"}
}

local function make_viol_report(dashboard, viol_struct, suffix)
    for i, struct in ipairs(viol_struct) do
        local file_name = "sddp_dashboard_viol_" .. suffix .. "_" .. struct.name;
        local viol_file = generic:load(file_name);
        if viol_file:loaded() then
            local chart = Chart(struct.title);
            chart:add_column_stacking(viol_file);
            dashboard:push(chart);
        end
    end
end

-----------------------------------------------------------------------------------------------
-- COSTS
-----------------------------------------------------------------------------------------------
local objcop = require("sddp/costs");
--
local costs = ifelse(objcop():ge(0), objcop(), 0);

---- sddp_dashboard_cost_tot
local total_costs_agg = costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM());

-----------------------------------------------------------------------------------------------
-- DASHBOARD
-----------------------------------------------------------------------------------------------

-- The dashboard is separated into tabs. One tab contains the solution quality outputs and the other the outputs of the optimization model

-- Main tabs
local sddp_input      = Tab("Input data");
local sddp_solqual    = Tab("Solution quality");
local sddp_viol       = Tab("Violations");
local results_tab     = Tab("Results");

-- Subtabs of "Input data"
local sddp_inferg     = Tab("Inflow energy");

-- Subtabs of violations
local sddp_viol_avg   = Tab("Average");
local sddp_viol_max   = Tab("Maximum");

-- Subtabs of "Results"
local sddp_costs_revs = Tab("Costs & Revenues");
local sddp_marg_costs = Tab("Marginal Costs");
local sddp_generation = Tab("Generation");
local sddp_risk       = Tab("Risk");

-----------------------------------------------------------------------------------------------
-- Input data
-----------------------------------------------------------------------------------------------

make_inflow_energy(sddp_inferg);
sddp_input:push(sddp_inferg);

-----------------------------------------------------------------------------------------------
-- Solution quality report
-----------------------------------------------------------------------------------------------

-- Convergence and bender cuts statistics
local file_list = {};
local horizon   = {};

local conv_data = {};
local cuts_data = {};

-- Convergence report
get_conv_file_info(file_list, horizon);
get_convergence_file_agents(file_list, conv_data, cuts_data);
make_convergence_graphs(sddp_solqual, conv_data, horizon);

-- Breakdown of ope. costs
if is_greater_than_zero(total_costs_agg) then
	add_chart_pie(sddp_solqual, { total_costs_agg }, "Breakdown of total operating costs");
end

-- SDDP status report(only for hourly cases)
local is_hourly = study:get_parameter("SIMH", -1) == 2; -- If SIMH is not present at sddp.dat, returns -1
if is_hourly then
    make_hourly_sol_status_graph(sddp_solqual);
end

-- Penalty proportion report
make_penalty_proportion_graph(sddp_solqual);

-- Convergence map report
make_conv_map_graph(sddp_solqual);

-- Added cuts report
make_added_cuts_graphs(sddp_solqual,cuts_data,horizon);

-----------------------------------------------------------------------------------------------
-- Violation report
-----------------------------------------------------------------------------------------------

make_viol_report(sddp_viol_avg, viol_report_structs, "avg");
make_viol_report(sddp_viol_max, viol_report_structs, "max");

sddp_viol:push(sddp_viol_avg);
sddp_viol:push(sddp_viol_max);

-----------------------------------------------------------------------------------------------
-- Results report
-----------------------------------------------------------------------------------------------

-- Marginal costs, costs and renenues and total generation
make_marg_costs(sddp_marg_costs);                         -- Marginal costs
make_costs_and_revs(sddp_costs_revs); 					  -- Costs and revenues
make_sddp_total_gen(sddp_generation, "Total generation"); -- Total generation
make_risk_report(sddp_risk);                              -- Deficit risk

results_tab:push(sddp_costs_revs);
results_tab:push(sddp_marg_costs);
results_tab:push(sddp_generation);
results_tab:push(sddp_risk);

-----------------------------------------------------------------------------------------------
-- Saving dashboard
-----------------------------------------------------------------------------------------------
local sddp_dashboard = Dashboard();
sddp_dashboard:push(sddp_input);
sddp_dashboard:push(sddp_solqual);
sddp_dashboard:push(sddp_viol);
sddp_dashboard:push(results_tab);
sddp_dashboard:save("SDDPDashboard");