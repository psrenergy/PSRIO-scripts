local discount_rate = require("sddp/discount_rate")();

-- Setting global colors
PSR.set_global_colors({"#4E79A7","#F28E2B","#8CD17D","#B6992D","#E15759","#76B7B2","#FF9DA7","#D7B5A6","#B07AA1","#59A14F","#F1CE63","#A0CBE8","#E15759"});

local case_dir_list = {};
local labels = {"Base case", "Test case"};
N = PSR.studies();

-- Loading cases
local cases = {};
for i=1,N do
    cases[i] = Generic(i);
    case_dir_list[i] = cases[i]:dirname();
    info(case_dir_list[i])
end

local function get_conv_file_info(case_ref, file_list, systems, horizons)
    -- Loading file
    local sddppol = case_ref:load_table("sddppol.csv");

    local file_name = "";
    for i = 1, #sddppol do
        file_name = sddppol[i]["FileNames"]
        file_list[i] = string.sub(file_name, 1, #file_name - 4)
        systems[i]   = sddppol[i]["System"]
        horizons[i]  = sddppol[i]["InitialHorizon"] .. "-" .. sddppol[i]["FinalHorizon"];
    end
end

local function make_inflow_energy(dashboard)
    
    local inferg = {};
    for i=1,N do
        inferg[i] = cases[i]:load("sddp_dashboard_input_enaflu");
        if(not inferg[i]:loaded()) then -- If any output couldn't be loaded, do not create de graphic
            error("Could not load output");
            return
        end 
    end     
    
    -- Color vectors
    inf_inter = {"#A0CBE8","#EA6B73"};
    sup_inter = {"#A0CBE8","#EA6B73"};
    avg_line  = {"#4E79A7","#F02720"};
    local chart = Chart("Total inflow energy");
    
    for i=1,N do
        -- Confidence interval
        chart:add_area_range(inferg[i]:select_agent(1), inferg[i]:select_agent(3),{color={inf_inter[i],sup_inter[i]},showInLegend = false});
        if i > 1 then
           chart:add_line(inferg[i]:select_agent(2):rename_agent(case_dir_list[i].." - Average"),{color={avg_line[i]},dashStyle = "dash"}); -- average
        else
           chart:add_line(inferg[i]:select_agent(2):rename_agent(case_dir_list[i].." - Average"),{color={avg_line[i]}}); -- average
        end
    end 
    
    dashboard:push(chart);
end

local function make_policy(dashboard)

    local conv_file;
    local conv_age;
    local cuts_age;
    local time_age;
    local file_list = {};
    local systems   = {};
    local horizons  = {};
    
    -- Color vectors
    zsup_inter_sup = {"#A0CBE8","#EA6B73"};
    zsup_inter_inf = {"#A0CBE8","#EA6B73"};
    zsup_avg_line  = {"#4E79A7","#F02720"};
    zinf_avg_line = {"#35CC8B","#3CB7CD"};
    
    -- Get list of file for reference case(1st case in psrio argument)
    get_conv_file_info(cases[1], file_list, systems, horizons)
    
    -- Assuming cases have the same list of files
    for i, file in ipairs(file_list) do
        local chart = Chart("Convergence report");
        dashboard:push("## System: " .. systems[i] .. " | Horizon: " .. horizons[i]);
        
        for j=1,N do
            conv_file = cases[j]:load(file);
            
            -- Selecting agents
            conv_age = conv_file:select_agents({1, 2, 3, 4}); -- Zinf        ,Zsup - Tol  ,Zsup        ,Zsup + Tol  
            cuts_age = conv_file:select_agents({5, 6});       -- Optimality  ,Feasibility 
            time_age = conv_file:select_agents({7, 8});       -- Forw. time, Back. time
        
            chart:add_area_range(conv_file:select_agents({2}),conv_file:select_agents({4}),{color={zsup_inter_sup[j],zsup_inter_inf[j]},xAllowDecimals = false,showInLegend = false}); -- Confidence interval
            chart:add_line(conv_file:select_agents({1}):rename_agent(case_dir_list[j].." - Zinf"), {color={zinf_avg_line[j]},  xAllowDecimals = false }); -- Zinf
            chart:add_line(conv_file:select_agents({3}):rename_agent(case_dir_list[j].." - ZSup"), {color={zsup_avg_line[j]},  xAllowDecimals = false }); -- Zsup
        end
        dashboard:push(chart);
    end
end 

local function make_costs(dashboard)

    local costs;
    
    local chart = Chart("Average operating costs");
    
    for i=1,N do
        local objcop = require("sddp/costs");
        local costs = ifelse(objcop(i):ge(0), objcop(i), 0) / discount_rate;

        -- sddp_dashboard_cost_tot
        costs_agg = costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):select_agents(costs:gt(0.0));;
    
        chart:add_categories(costs_agg, case_dir_list[i]);
    end
    dashboard:push(chart);
end 

local function make_marg_costs(dashboard)

    local cmg = {};
    local cmg_aggsum;
    local cmg_aggyear;
    
    -- Loading cases without generic collection
    local sys = {};
    for i=1,N do
        sys[i] = System(i);
    end
    
    for i=1,N do
        cmg[i] = sys[i]:load("cmgdem");

        if(not cmg[i]:loaded()) then -- If any output couldn't be loaded, do not create de graphic
            error("Could not load output");
            return
        end 
    end
	
	-- Marginal cost aggregated by average
    chart_subsys = Chart("Annual marginal cost by sub-system"); 
	for i=1,N do
        cmg_aggyear = cmg[i]:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),Collection.SYSTEM);
    
        -- Add marginal costs outputs
        chart_subsys:add_categories(cmg_aggyear, case_dir_list[i]);  -- Annual Marg. cost     
    end
    dashboard:push(chart_subsys);
    
    -- Assuming agents in reference case(1st case) are the same as the ones in the others
    agents = cmg[1]:agents();
    for i, agent in ipairs(agents) do
        local chart_per_stg = Chart("Average marginal costs per stage per subsystem".." - "..agent);
        for j=1,N do
            cmg_aggsum = cmg[j]:select_agent(agent):rename_agent(case_dir_list[j]):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE())
            chart_per_stg:add_line(cmg_aggsum);  -- Average marg. cost per stage
        end 
        dashboard:push(chart_per_stg);
    end
    
end

local function make_sddp_total_gen(dashboard)
	
    -- Color preferences
    local color_hydro       = '#4E79A7';
    local color_thermal     = '#F28E2B';
    local color_wind        = '#8CD17D';
    local color_solar       = '#F1CE63';
    local color_small_hydro = '#A0CBE8';
    local color_battery     = '#B07AA1';
    local color_deficit     = '#000000';
    local color_pinj        = '#BAB0AC';

    local gerter = {};
	local gerhid = {};
	local gergnd = {};
    local wind   = {};
    local solar  = {};
	local gerbat = {};
	local potinj = {};
	local defcit = {};
    
    -- Loading generations files
    for i=1,N do
        gerter[i] = Thermal(i):load("gerter");
        gerhid[i] = Hydro(i):load("gerhid");
        gergnd[i] = Renewable(i):load("gergnd");
        gerbat[i] = Battery(i):load("gerbat");
        potinj[i] = PowerInjection(i):load("powinj");
        defcit[i] = System(i):load("defcit");
    end
    
    chart_tot_gerhid  = Chart("Total Hydro");
    chart_tot_sml_hid = Chart("Total Small Hydro");
    chart_tot_gerter  = Chart("Total Thermal");
    chart_tot_renw    = Chart("Total Renewable");
    chart_tot_gerbat  = Chart("Total Battery");
    chart_tot_potinj  = Chart("Total Power Injection");
    chart_tot_defcit  = Chart("Total Deficit");
    
    local total_small_hydro_gen;
    local total_hydro_gen;      
    local total_batt_gen;   
    local total_deficit;    
    local total_pot_inj;    
    local total_wind_gen;   
    local total_solar_gen;  
    local total_thermal_gen;    
    
    -- Total generation report
    for i=1,N do
       
        -- Data processing
        total_hydro_gen   = gerhid[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),case_dir_list[i] .. " - Total Hydro");
        total_batt_gen    = gerbat[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),case_dir_list[i] .. " - Total Battery");
        total_deficit     = defcit[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),case_dir_list[i] .. " - Total Deficit");
        total_pot_inj     = potinj[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),case_dir_list[i] .. " - Total P. Inj.");
        total_renw_gen    = gergnd[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),case_dir_list[i] .. " - Total Renewable");
        total_thermal_gen = gerter[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),case_dir_list[i] .. " - Total Thermal");

        if total_hydro_gen:loaded() then
            chart_tot_gerhid:add_area_stacking(total_hydro_gen); 
        end
        if total_thermal_gen:loaded() then
            chart_tot_gerter:add_area_stacking(total_thermal_gen); 
        end
        if total_renw_gen:loaded() then
            chart_tot_renw:add_area_stacking(total_renw_gen);    
        end
        if total_batt_gen:loaded() then
            chart_tot_gerbat:add_area_stacking(total_batt_gen);  
        end
        if total_pot_inj:loaded() then
            chart_tot_potinj:add_area_stacking(total_pot_inj);  
        end
        if total_deficit:loaded() then
            chart_tot_defcit:add_area_stacking(total_deficit);  
        end
    end
    
    if #chart_tot_gerhid > 0 then
        dashboard:push(chart_tot_gerhid);
    end
    if #chart_tot_gerter > 0 then
        dashboard:push(chart_tot_gerter);
    end
    if #chart_tot_renw > 0 then
        dashboard:push(chart_tot_renw);
    end 
    if #chart_tot_gerbat > 0 then
        dashboard:push(chart_tot_gerbat);
    end
    if #chart_tot_potinj > 0 then
        dashboard:push(chart_tot_potinj);
    end 
    if #chart_tot_defcit > 0 then
        dashboard:push(chart_tot_defcit);
    end
    
    -- Generation per system report
    agents = cases[1]:load("cmgdem"):agents();
    for i, agent in ipairs(agents) do
    
        chart_tot_gerhid  = Chart("Total Hydro - "..agent);
        chart_tot_gerter  = Chart("Total Thermal - "..agent);
        chart_tot_renw    = Chart("Total Renewable - "..agent);
        chart_tot_gerbat  = Chart("Total Battery - "..agent);
        chart_tot_potinj  = Chart("Total Power Injection - "..agent);
        chart_tot_defcit  = Chart("Total Deficit - "..agent);
    
        for i=1,N do
            -- Data processing
            total_hydro_gen   = gerhid[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),Collection.SYSTEM):select_agent(agent):rename_agent(case_dir_list[i] .. " - Total Hydro");
            total_batt_gen    = gerbat[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),Collection.SYSTEM):select_agent(agent):rename_agent(case_dir_list[i] .. " - Total Battery");
            total_deficit     = defcit[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),Collection.SYSTEM):select_agent(agent):rename_agent(case_dir_list[i] .. " - Total Deficit");
            total_pot_inj     = potinj[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),Collection.SYSTEM):select_agent(agent):rename_agent(case_dir_list[i] .. " - Total P. Inj.");
            total_renw_gen    = gergnd[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),Collection.SYSTEM):select_agent(agent):rename_agent(case_dir_list[i] .. " - Total Renewable");
            total_thermal_gen = gerter[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),Collection.SYSTEM):select_agent(agent):rename_agent(case_dir_list[i] .. " - Total Thermal");
    
            info("Aqui");
            info(total_hydro_gen:loaded());
            if total_hydro_gen:loaded() then
                chart_tot_gerhid:add_area_stacking(total_hydro_gen); 
            end
            if total_thermal_gen:loaded() then
                chart_tot_gerter:add_area_stacking(total_thermal_gen); 
            end
            if total_renw_gen:loaded() then
                chart_tot_renw:add_area_stacking(total_renw_gen);    
            end
            if total_batt_gen:loaded() then
                chart_tot_gerbat:add_area_stacking(total_batt_gen);  
            end
            if total_pot_inj:loaded() then
                chart_tot_potinj:add_area_stacking(total_pot_inj);  
            end
            if total_deficit:loaded() then
                chart_tot_defcit:add_area_stacking(total_deficit);  
            end
        end
        
        if #chart_tot_gerhid > 0 then
            dashboard:push(chart_tot_gerhid);
        end
        if #chart_tot_gerter > 0 then
            dashboard:push(chart_tot_gerter);
        end
        if #chart_tot_renw > 0 then
            dashboard:push(chart_tot_renw);
        end 
        if #chart_tot_gerbat > 0 then
            dashboard:push(chart_tot_gerbat);
        end
        if #chart_tot_potinj > 0 then
            dashboard:push(chart_tot_potinj);
        end 
        if #chart_tot_defcit > 0 then
            dashboard:push(chart_tot_defcit);
        end     
    end
       
end

-----------------------------------------------------------------------------------------------
-- DASHBOARD
-----------------------------------------------------------------------------------------------

-- The dashboard is separated into tabs. One tab contains the solution quality outputs and the other the outputs of the optimization model

-- Main tabs
local sddp_input   = Tab("Input data");
local sddp_solqual = Tab("Solution quality");
local sddp_results = Tab("Results");

-- Subtabs of "Solution quality"
local sddp_pol = Tab("Policy");
local sddp_sim = Tab("Simulation");

-- Subtabs of "Results"
local sddp_marg_costs = Tab("Marginal costs");
local sddp_generation = Tab("Generation");

-- Tabs are initially colapsed when first opening the dash
sddp_input:set_collapsed(false);
sddp_pol:set_collapsed(false);
sddp_sim:set_collapsed(false);
sddp_solqual:set_collapsed(true);
sddp_results:set_collapsed(true);

-- Main tabs have no content to show, hence they are disabled
sddp_input:set_disabled();
sddp_solqual:set_disabled();
sddp_results:set_disabled();

-- Subtabs of "Input data"
local sddp_inferg = Tab("Inflow energy");

-- Set icons of the main tabs
sddp_input:set_icon("file-input"); -- Alternative: arrow-big-right
sddp_solqual:set_icon("alert-triangle");
sddp_results:set_icon("line-chart");


make_inflow_energy(sddp_inferg);
make_policy(sddp_pol);
make_costs(sddp_sim);
make_marg_costs(sddp_marg_costs);
make_sddp_total_gen(sddp_generation);

sddp_input:push(sddp_inferg);
sddp_solqual:push(sddp_pol);
sddp_solqual:push(sddp_sim);
sddp_results:push(sddp_marg_costs);
sddp_results:push(sddp_generation);

local sddp_dashboard = Dashboard();
sddp_dashboard:push(sddp_input);
sddp_dashboard:push(sddp_solqual);
sddp_dashboard:push(sddp_results);
sddp_dashboard:save("SDDPDashboardCompare");