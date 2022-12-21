local battery         = Battery();
local bus             = Bus();
local circuit         = Circuit();
local generic         = Generic();
local hydro           = Hydro();
local interconn       = Interconnection();
local power_injection = PowerInjection();
local renewable       = Renewable();
local study           = Study();
local system          = System();
local thermal         = Thermal();

-- Setting global colors
PSR.set_global_colors({"#4E79A7","#F28E2B","#8CD17D","#B6992D","#E15759","#76B7B2","#FF9DA7","#D7B5A6","#B07AA1","#59A14F","#F1CE63","#A0CBE8","#E15759"});

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

local function get_conv_file_info(file_list, systems, horizons)
    -- Loading file
    local sddppol = generic:load_table("sddppol.csv");

    local file_name = "";
    for i = 1, #sddppol do
        file_name = sddppol[i]["FileNames"]
        file_list[i] = string.sub(file_name, 1, #file_name - 4)
        systems[i]   = sddppol[i]["System"]
        horizons[i]  = sddppol[i]["InitialHorizon"] .. "-" .. sddppol[i]["FinalHorizon"];
    end
end

-----------------------------------------------------------------------------------------------
-- SDDP OUTPUT GENERATION FUNCTIONS
-----------------------------------------------------------------------------------------------

local function make_case_summary(dashboad)

    -- Horizon
    local initial_year = study:initial_year();
    local nstage = study:stages();
    local nforwd = study:scenarios();
    local nback  = study:openings();
    
    -- Resolution
    local blocks_size = hydro:load("gerhid"):blocks(1);
    local is_hourly = hydro:load("gerhid"):is_hourly();
    local has_hourly_data = ""
    if is_hourly then
        has_hourly_data = "yes"
    else
        has_hourly_data = "no"
    end
    
    -- Generators
    local bat_size     = #battery:labels();
    local bus_size     = #bus:labels();
    local circ_size    = #circuit:labels();
    local hydro_size   = #hydro:labels();
    local inter_size   = #interconn:labels();
    local pinj_size    = #power_injection:labels();
    local thermal_size = #thermal:labels();
    local renew_size   = #renewable:labels();
    local sys_size     = #system:labels();
    
    local has_net = ""
    if( bus_size > 0 ) then
        has_net = "yes"
    else
        has_net = "no"
    end
    
    -- Inserting info
    dashboad:push("# Case summary");
    dashboad:push("");
    dashboad:push("## Horizon, resolution and execution options");
    dashboad:push("| Case parameter | Value |");
    dashboad:push("|----------------|-------|");
    dashboad:push("| Number of stages | "          .. tostring(nstage)       .. "|");
    dashboad:push("| Initial year of study | "     .. tostring(initial_year) .. "|");
    dashboad:push("| Number of blocks | "          .. tostring(blocks_size)  .. "|");
    dashboad:push("| Number of forward series | "  .. tostring(nforwd)       .. "|");
    dashboad:push("| Number of backward series | " .. tostring(nback)        .. "|");
    dashboad:push("| Hourly representation | "     .. has_hourly_data        .. "|");
    dashboad:push("| Network representation | "    .. has_net                .. "|");
    dashboad:push("");
    dashboad:push("## Dimensions");
    dashboad:push("| Case parameter | Value |");
    dashboad:push("|----------------|-------|");
    dashboad:push("| Number of systems |"           .. tostring(sys_size)     .. "|");
    dashboad:push("| Number of batteries |"         .. tostring(bat_size)     .. "|");
    if has_net == "yes" then
        dashboad:push("| Number of buses | "            .. tostring(bus_size)     .. "|");
        dashboad:push("| Number of circuits | "         .. tostring(circ_size)    .. "|");
    end
    dashboad:push("| Number of hydro plants | "     .. tostring(hydro_size)   .. "|");
    dashboad:push("| Number of interconnections | " .. tostring(inter_size)    .. "|");
    dashboad:push("| Number of power injections | " .. tostring(pinj_size)    .. "|");
    dashboad:push("| Number of renewable plants | " .. tostring(renew_size)   .. "|");
    dashboad:push("| Number of thermal plants | "   .. tostring(thermal_size) .. "|");
end

local function make_inflow_energy(dashboard)
    local inferg = generic:load("sddp_dashboard_input_enaflu");
    local chart = Chart("Total inflow energy");
    chart:add_area_range(inferg:select_agent(1), inferg:select_agent(3),{color={"#A0CBE8","#A0CBE8"}}); -- Confidence interval
    chart:add_line(inferg:select_agent(2),{color={"#4E79A7"}}); -- average
    dashboard:push(chart);
end

local function make_sddp_total_gen(dashboard,chart_title)
	
    -- Color preferences
    local color_hydro       = '#4E79A7';
    local color_thermal     = '#F28E2B';
    local color_wind        = '#8CD17D';
    local color_solar       = '#F1CE63';
    local color_small_hydro = '#A0CBE8';
    local color_battery     = '#B07AA1';
    local color_deficit     = '#000000';
    local color_pinj        = '#BAB0AC';

    -- Loading generations files
	local gerter = thermal:load("gerter");
	local gerhid = hydro:load("gerhid");
	local gergnd = renewable:load("gergnd");
	local gerbat = renewable:load("gerbat");
	local potinj = power_injection:load("powinj");
	local def    = system:load("defcit");
    
    -- Renewable technologies
    wind = renewable.tech_type:eq(1);
    solar = renewable.tech_type:eq(2);
    small_hydro = renewable.tech_type:eq(4);

	-- Data processing
	local total_batt_gen        = gerbat:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Battery");
    local total_deficit         = def:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Deficit");
    local total_hydro_gen       = gerhid:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Hydro");
    local total_pot_inj         = potinj:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total P. Inj.");
    local total_wind_gen        = gergnd:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Wind");
    local total_solar_gen       = gergnd:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Solar");
    local total_thermal_gen     = gerter:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Thermal");

    chart = Chart(chart_title);
    chart:add_area_stacking(total_thermal_gen,{color={color_thermal}});
    chart:add_area_stacking(total_hydro_gen,{color={color_hydro}});
    chart:add_area_stacking(total_batt_gen,{color={color_battery}});
    chart:add_area_stacking(total_pot_inj,{color={color_pinj}});
    chart:add_area_stacking(total_wind_gen,{color={color_wind}});
    chart:add_area_stacking(total_solar_gen,{color={color_solar}});
    chart:add_area_stacking(total_deficit,{color={color_deficit}});
    
    dashboard:push(chart);
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
	    local chart = Chart("Dispersion of operating costs per stage");	
		chart:add_area_range(disp:select_agent(1), disp:select_agent(3),{color={"#EA6B73","#EA6B73"}}); -- Confidence interval
        chart:add_line(disp:select_agent(2),{color={"#F02720"}}); -- Average
        dashboard:push(chart);
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

local function get_convergence_file_agents(file_list, conv_age, cuts_age, time_age)
    for i, file in ipairs(file_list) do
        local conv_file = generic:load(file);
        conv_age[i] = conv_file:select_agents({1, 2, 3, 4}); -- Zinf        ,Zsup - Tol  ,Zsup        ,Zsup + Tol  
        cuts_age[i] = conv_file:select_agents({5, 6});     -- Optimality  ,Feasibility 
        time_age[i] = conv_file:select_agents({7, 8});     -- Forw. time, Back. time
    end
end

local function make_convergence_graphs(dashboard, conv_age, systems, horizon)
    for i, conv in ipairs(conv_age) do
        local chart = Chart("Convergence report | System: " .. systems[i] .. " | Horizon: " .. horizon[i]);
        chart:add_area_range(conv:select_agents({2}), conv:select_agents({4}), {color={"#ACD98D","#ACD98D"}, xAllowDecimals = false }); -- Confidence interval
        chart:add_line(conv:select_agents({1}), {color={"#3CB7CC"}, xAllowDecimals = false }); -- Zinf
        chart:add_line(conv:select_agents({3}), {color={"#32A251"}, xAllowDecimals = false }); -- Zsup
        dashboard:push(chart);
    end
end

local function make_added_cuts_graphs(dashboard, cuts_age, systems, horizon)
    for i, cuts in ipairs(cuts_age) do
        local chart = Chart("Number of added cuts report | System: " .. systems[i] .. " Horizon: " .. horizon[i]);
        chart:add_column(cuts:select_agents({1}), { xAllowDecimals = false }); -- Opt
        chart:add_column(cuts:select_agents({2}), { xAllowDecimals = false }); -- Feas
        dashboard:push(chart);
    end 
end

local function calculate_number_of_systems(sys_vec)
    
    local sys_name = sys_vec[1];
    local counter = 1;
    for i, name in ipairs(sys_vec) do
        if(sys_name ~= name) then
            counter = counter + 1;
            sys_name = name
        end
    end
    
    return counter;
end
local function make_policy_report(dashboard, conv_age, cuts_age, time_age, systems, horizon)

    -- If there is only one FCF file in the case, print final simulation cost as columns
    oper_mode = study:get_parameter("Opcion", -1); -- 1=AIS; 2=COO; 3=INT;    
    
    nsys = calculate_number_of_systems(systems);
    graph_sim_cost = false;
    
    if( (oper_mode < 3 and nsys == 1) or  oper_mode == 3) then
        info("Entrou aqui");    
        graph_sim_cost = true;
        local objcop = Generic():load("objcop");
        total_costs = objcop:select_agent(1):aggregate_scenarios(BY_AVERAGE()):to_list()[1]; -- Select total cost agent
        conv_age_aux = conv_age[1]:select_agent(1):rename_agent("Final simulation");         -- Take expression and use it as mask for "final_sim_cost"
        final_sim_cost = conv_age_aux:fill(total_costs);
    end
       
    for i, conv in ipairs(conv_age) do -- Each position of conv_age and cuts_age refers to the same file
        dashboard:push("## System: " .. systems[i] .. " | Horizon: " .. horizon[i]);
        local chart = Chart("Convergence report");
        if( graph_sim_cost ) then
            chart:add_column(final_sim_cost, {color={"#D37295"},  xAllowDecimals = false }); -- Final simulation cost
        end 
        chart:add_area_range(conv:select_agents({2}), conv:select_agents({4}), {color={"#ACD98D","#ACD98D"},  xAllowDecimals = false }); -- Confidence interval
        chart:add_line(conv:select_agents({1}), {color={"#3CB7CC"},  xAllowDecimals = false }); -- Zinf
        chart:add_line(conv:select_agents({3}), {color={"#32A251"},  xAllowDecimals = false }); -- Zsup
        dashboard:push(chart);
        
        chart = Chart("Number of added cuts report");
        chart:add_column(cuts_age[i], { xAllowDecimals = false }); -- Opt and Feas
        dashboard:push(chart);
        
        chart = Chart("Forward and backward execution times");
        chart:add_line(time_age[i], { xAllowDecimals = false }); -- Forw. and Back. times
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
local total_costs_agg = costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):remove_zeros();

-----------------------------------------------------------------------------------------------
-- DASHBOARD
-----------------------------------------------------------------------------------------------

-- The dashboard is separated into tabs. One tab contains the solution quality outputs and the other the outputs of the optimization model

-- Main tabs
local sddp_input   = Tab("Input data");
local sddp_solqual = Tab("Solution quality");
local sddp_viol    = Tab("Violations");
local sddp_results = Tab("Results");

-- Tabs are initially colapsed when first opening the dash
sddp_input:set_collapsed(false);
sddp_solqual:set_collapsed(true);
sddp_viol:set_collapsed(true);
sddp_results:set_collapsed(true);

-- Main tabs have no content to show, hence they are disabled
sddp_input:set_disabled();
sddp_solqual:set_disabled();
sddp_viol:set_disabled();
sddp_results:set_disabled();

-- Subtabs of "Input data"
local sddp_summ       = Tab("Case summary");
local sddp_inferg     = Tab("Inflow energy");

-- Subtabs of "Solution quality"
local sddp_pol     = Tab("Policy");
local sddp_sim     = Tab("Simulation");

-- Subtabs of violations
local sddp_viol_avg   = Tab("Average");
local sddp_viol_max   = Tab("Maximum");

-- Subtabs of "Results"
local sddp_costs_revs = Tab("Costs & Revenues");
local sddp_marg_costs = Tab("Marginal Costs");
local sddp_generation = Tab("Generation");
local sddp_risk       = Tab("Risk");

-- Set icons of the main tabs
sddp_input:set_icon("file-input"); -- Alternative: arrow-big-right
sddp_solqual:set_icon("alert-triangle");
sddp_viol:set_icon("siren");
sddp_results:set_icon("line-chart");

-----------------------------------------------------------------------------------------------
-- Input data
-----------------------------------------------------------------------------------------------

-- Case summary
make_case_summary(sddp_summ);
make_inflow_energy(sddp_inferg);

sddp_input:push(sddp_summ);
sddp_input:push(sddp_inferg);

-----------------------------------------------------------------------------------------------
-- Solution quality report
-----------------------------------------------------------------------------------------------

-- *** Policy report ***

-- Convergence and bender cuts statistics
local file_list = {};
local systems   = {};
local horizon   = {};

local conv_data = {};
local cuts_data = {};
local time_data = {};

-- Convergence report
get_conv_file_info(file_list, systems, horizon);
get_convergence_file_agents(file_list, conv_data, cuts_data, time_data);

-- Creating policy report
make_policy_report(sddp_pol, conv_data, cuts_data, time_data, systems, horizon);

-- *** Simulation report ***

-- Breakdown of ope. costs
if is_greater_than_zero(total_costs_agg) then
	add_chart_pie(sddp_sim, { total_costs_agg }, "Breakdown of total operating costs");
end

-- SDDP status report(only for hourly cases)
local is_hourly = study:get_parameter("SIMH", -1) == 2; -- If SIMH is not present at sddp.dat, returns -1
if is_hourly then
    make_hourly_sol_status_graph(sddp_sim);
end

-- Penalty proportion report
make_penalty_proportion_graph(sddp_sim);

-- Convergence map report
make_conv_map_graph(sddp_sim);

-- Adding tabs to solution quality
sddp_solqual:push(sddp_pol);
sddp_solqual:push(sddp_sim);

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

sddp_results:push(sddp_costs_revs);
sddp_results:push(sddp_marg_costs);
sddp_results:push(sddp_generation);
sddp_results:push(sddp_risk);

-----------------------------------------------------------------------------------------------
-- Saving dashboard
-----------------------------------------------------------------------------------------------
local sddp_dashboard = Dashboard();
sddp_dashboard:push(sddp_input);
sddp_dashboard:push(sddp_solqual);
sddp_dashboard:push(sddp_viol);
sddp_dashboard:push(sddp_results);
sddp_dashboard:save("SDDPDashboard");