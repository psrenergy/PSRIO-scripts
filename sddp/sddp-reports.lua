local function add_chart_line(dashboard, output, output_name)
	chart = Chart(output_name);		-- Create chart
	for i, out in pairs(output) do  
		chart:add_line(out);        -- Add output
	end                             
	dashboard:push(chart);          -- Add outputs to informed dashboard
end

local function add_chart_column(dashboard, output, output_name)
	chart = Chart(output_name);		-- Create chart
	for i, out in pairs(output) do  
		chart:add_column(out);      -- Add output
	end                             
	dashboard:push(chart);          -- Add outputs to informed dashboard
end

local function add_chart_pie(dashboard, output, output_name)
	chart = Chart(output_name);		-- Create chart
	for i, out in pairs(output) do  
		chart:add_pie(out);         -- Add output
	end                             
	dashboard:push(chart);          -- Add outputs to informed dashboard
end

local function add_chart_area_stacking(dashboard, output, output_name)
	chart = Chart(output_name); 	  -- Create chart
	for i, out in pairs(output) do
		chart:add_area_stacking(out); -- Add output
	end
	dashboard:push(chart);            -- Add outputs to informed dashboard
end

local function discount_rate()
    local study = Study(); -- Load study
	local dr = (1 + study.discount_rate) ^ ((study.stage - 1) / study:stages_per_year()); -- Discount rate	
    return dr -- Return discount rate for each stage
end

local function check_non_zero(output)
	x = output:aggregate_agents(BY_SUM(), "CheckZeros"):aggregate_stages(BY_SUM()):to_list()[1];
	if x > 0.0 then
		non_zero = true
	end
	return non_zero
end

local function get_conv_file_info(file_list,horizons)
    
    local gen = Generic();
    
    -- Loading file
    table = gen:load_table("sddppol.csv");

    local file_name = ""
    for i = 1, #table do
        file_name = table[i]["FileNames"]
        file_list[i] = string.sub(file_name,1,#file_name - 4)
        horizons[i] = table[i]["InitialHorizon"]..":"..  table[i]["FinalHorizon"];
    end 
end

-----------------------------------------------------------------------------------------------
-- SDDP OUTPUT GENERATION FUNCTIONS
-----------------------------------------------------------------------------------------------

local function make_inflow_energy(dashboard)
    local gen = Generic();

    local inferg = gen:load("sddp_dashboard_input_enaflu");
    local chart = Chart("Total inflow energy");
    chart:add_area_range(inferg:select_agents({1}),inferg:select_agents({3})); -- Confidence interval
    chart:add_line(inferg:select_agents({2})); -- average
    dashboard:push(chart);
end

local function make_sddp_total_gen(dashboard,chart_title)
	-- Loading collections
	thermal = Thermal();
	hydro   = Hydro();
	rwn     = Renewable();
	batt    = Battery();
	pinj    = PowerInjection();
	sys     = System();
	
	-- Loading generations files
	gerter = thermal:load("gerter");
	gerhid = hydro:load("gerhid");
	gergnd = rwn:load("gergnd");
	gerbat = rwn:load("gerbat");
	potinj = pinj:load("powinj");
	def    = sys:load("defcit")
	
	-- Data processing
	total_thermal_gen = gerter:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Thermal");
	total_hydro_gen   = gerhid:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Hydro");
	total_rnw_gen     = gergnd:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Renewable");
	total_batt_gen    = gerbat:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Battery");
	total_pot_inj     = potinj:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total P. Inj.");
	total_deficit     = def:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(),"Total Deficit");
	
	add_chart_area_stacking(dashboard,{total_thermal_gen,total_hydro_gen,total_rnw_gen,total_batt_gen,total_pot_inj,total_deficit},chart_title);
end

local function make_costs_and_revs(dashboard)

	local objcop = require("sddp/costs");
	
	local costs = ifelse(objcop():ge(0), objcop(), 0);
	
	costs = costs/discount_rate();
	
	-- sddp_dashboard_cost_tot
	costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):save("sddp_dashboard_cost_tot", {remove_zeros = true, csv=true});
	
	-- sddp_dashboard_cost_avg
	costs_avg = costs:aggregate_scenarios(BY_AVERAGE()):select_agent(1);
	
	-- sddp_dashboard_cost_disp
	disp = concatenate(
		costs:aggregate_agents(BY_SUM(), "P10"):aggregate_scenarios(BY_PERCENTILE(10)),
		costs:aggregate_agents(BY_SUM(), "Average"):aggregate_scenarios(BY_AVERAGE()),
		costs:aggregate_agents(BY_SUM(), "P90"):aggregate_scenarios(BY_PERCENTILE(90))
	);
	
	aux = check_non_zero(costs_avg)
	if aux then
		add_chart_column(dashboard,{costs_avg},"Average operating costs per stage");
	end
	
	aux = check_non_zero(disp)
	if aux then
		add_chart_line(dashboard,{disp},"Dispersion of operating costs per stage");
	end
	
end

local function make_marg_costs(dashboard)

	system = System();
	local cmg   = system:load("cmgdem")
	
	-- Marginal cost aggregated by average
	cmg_aggsum  = cmg:aggregate_blocks(BY_AVERAGE());
	cmg_aggyear = cmg:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR);

	-- Add marginal costs outputs
	add_chart_column(dashboard,{cmg_aggsum},"Average marginal costs per stage per subsystem"); -- Average Marg. cost
	add_chart_column(dashboard,{cmg_aggyear},"Annual marginal cost by sub-system"); -- Annual Marg. cost 
	
end

local function get_convergence_file_agents(file_list, conv_age, cuts_age)
    
    local gen = Generic();
    
    for i, file in ipairs(file_list) do
        local conv_file = gen:load(file)
        conv_age[i] = conv_file:select_agents({1,2,3,4}); -- Zinf        ,Zsup - Tol  ,Zsup        ,Zsup + Tol  
        cuts_age[i] = conv_file:select_agents({5,6});     -- Optimality  ,Feasibility 
    end 
    
end

local function make_convergence_graphs(dashboard,conv_age,horizon)
    for i, conv in ipairs(conv_age) do
        local chart = Chart("Convergence report | Horizon - " .. horizon[i]);
        chart:add_area_range(conv:select_agents({2}),conv:select_agents({4})); -- Confidence interval
        chart:add_line(conv:select_agents({1}), {xAllowDecimals = false}); -- Zinf
        chart:add_line(conv:select_agents({3}), {xAllowDecimals = false}); -- Zsup
        dashboard:push(chart);
    end 
end

local function make_added_cuts_graphs(dashboard,cuts_age,horizon)
    for i, cuts in ipairs(cuts_age) do
        local chart = Chart("Number of added cuts report | Horizon - " .. horizon[i]);
        chart:add_column(cuts:select_agents({1}), {xAllowDecimals = false}); -- Opt
        chart:add_column(cuts:select_agents({2}), {xAllowDecimals = false}); -- Feas
        dashboard:push(chart);
    end 
end

local function make_penalty_proportion_graph(dashboard)
    local gen = Generic();
    
    local penp = gen:load("sddppenp");
    local chart = Chart("Share of violation penalties and deficit in the cost of each stage/scenario");
    chart:add_heatmap_hourly(penp);
    dashboard:push(chart);
end

local function make_conv_map_graph(dashboard)

    local gen = Generic();
    
    local conv_map = gen:load("sddpconvmap");
    local chart = Chart("Convergence map");
    chart:add_heatmap_hourly(conv_map);
    dashboard:push(chart);
end

local function make_hourly_sol_status_graph(dashboard)
    local gen = Generic();

    local status = gen:load("sddpstatus");
    local chart = Chart("Execution status per stage and scenario");
    chart:add_heatmap_hourly(penp);
    dashboard:push(chart);
end
-----------------------------------------------------------------------------------------------
-- COSTS
-----------------------------------------------------------------------------------------------
local objcop = require("sddp/costs");
--
local costs = ifelse(objcop():ge(0), objcop(), 0);

---- sddp_dashboard_cost_tot
total_costs_agg = costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM());

-----------------------------------------------------------------------------------------------
-- DASHBOARD
-----------------------------------------------------------------------------------------------

-- The dashboard is separated into tabs. One tab contains the solution quality outputs and the other the outputs of the optimization model

-- Main tabs
sddp_input      = Tab("Input data");
sddp_solqual    = Tab("Solution quality");
results_tab     = Tab("Results");

-- Subtabs of "Input data"
sddp_inferg     = Tab("Inflow energy");

-- Subtabs of "Results"
sddp_costs_revs = Tab("Costs & Revenues");
sddp_marg_costs = Tab("Marginal Costs");
sddp_generation = Tab("Generation");

-----------------------------------------------------------------------------------------------
-- Input data
-----------------------------------------------------------------------------------------------

make_inflow_energy(sddp_inferg);
sddp_input:push(sddp_inferg);

-----------------------------------------------------------------------------------------------
-- Solution quality report
-----------------------------------------------------------------------------------------------
study = Study();

-- Convergence and bender cuts statistics
file_list = {};
horizon   = {};

conv_data = {};
cuts_data = {};

-- Convergence report
get_conv_file_info(file_list,horizon);
get_convergence_file_agents(file_list,conv_data,cuts_data);
make_convergence_graphs(sddp_solqual,conv_data,horizon);

-- Breakdown of ope. costs
aux = check_non_zero(total_costs_agg)
if aux then
	add_chart_pie(sddp_solqual,{total_costs_agg},"Breakdown of total operating costs");
end

-- SDDP status report(only for hourly cases)
is_hourly = Study():get_parameter("SIMH", -1) == 2; -- If SIMH is not present at sddp.dat, returns -1
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
-- Results report
-----------------------------------------------------------------------------------------------

-- Marginal costs, costs and renenues and total generation
make_marg_costs(sddp_marg_costs);                         -- Marginal costs
make_costs_and_revs(sddp_costs_revs); 					  -- Costs and revenues
make_sddp_total_gen(sddp_generation,"Total generation");  -- Total generation

results_tab:push(sddp_costs_revs);
results_tab:push(sddp_marg_costs);
results_tab:push(sddp_generation);

-----------------------------------------------------------------------------------------------
-- Saving dashboard
-----------------------------------------------------------------------------------------------
sddp_dashboard = Dashboard();
sddp_dashboard:push(sddp_input);
sddp_dashboard:push(sddp_solqual);
sddp_dashboard:push(results_tab);
sddp_dashboard:save("SDDPDashboard");