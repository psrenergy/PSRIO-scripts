-- Setting global colors
PSR.set_global_colors({"#4E79A7","#F28E2B","#8CD17D","#B6992D","#E15759","#76B7B2","#FF9DA7","#D7B5A6","#B07AA1","#59A14F","#F1CE63","#A0CBE8","#E15759"});
main_global_color   = {"#4E79A7","#F28E2B","#8CD17D","#B6992D","#E15759","#76B7B2","#FF9DA7","#D7B5A6","#B07AA1","#59A14F","#F1CE63","#A0CBE8","#E15759"}
light_global_color  = {"#B7C9DD","#FAD2AA","#D1EDCB","#e9daa4","#f3bcbd","#c8e2e0","#ffd8dc","#efe1db","#dfcad9","#bbdbb7","#f9ebc1","#d9eaf6","#f3bcbd"};

-- Study dimension
local studies = PSR.studies();

-- Collection arrays
local battery = {};
local bus = {};
local circuit = {};
local generic = {};
local hydro = {};
local interconnection = {};
local power_injection = {};
local renewable = {};
local study = {};
local system = {};
local thermal = {};

-- Cases' directory names
local case_dir_list = {};

for i = 1, studies do
    table.insert(battery, Battery(i));
    table.insert(bus, Bus(i));
    table.insert(circuit, Circuit(i));
    table.insert(generic, Generic(i));
    table.insert(hydro, Hydro(i));
    table.insert(interconnection, Interconnection(i));
    table.insert(power_injection, PowerInjection(i));
    table.insert(renewable, Renewable(i));
    table.insert(study, Study(i));
    table.insert(system, System(i));
    table.insert(thermal, Thermal(i));
    
    table.insert(case_dir_list, generic[i]:dirname());
end

-----------------------------------------------------------------------------------------------
-- Auxiliary functions
-----------------------------------------------------------------------------------------------

local function is_greater_than_zero(output)
	local x = output:aggregate_agents(BY_SUM(), "CheckZeros"):aggregate_stages(BY_SUM()):to_list();
	if x[1] > 0.0 then
		return true;
	else
		return false;
	end
end

-----------------------------------------------------------------------------------------------
-- Case summary report function
-----------------------------------------------------------------------------------------------

local function create_tab_summary()
    local tab = Tab("Case summary");
    tab:push("# Case summary");

    local label = {};
    local path = {};

    local model = {};
    local user = {}
    local version = {};
    local hash = {};
    local description = {};

    for i = 1, studies do
        table.insert(label, generic[i]:cloudname());
        table.insert(path, generic[i]:path());

        local info = generic[i]:load_toml("sddp.info");
        table.insert(model, info:get_string("model", "---"));
        table.insert(user, info:get_string("user", "---"));
        table.insert(version, info:get_string("version", "---"));
        table.insert(hash, info:get_string("hash", "---"));
        
        local study = Study(i);
        table.insert(description, study:get_parameter("Descricao",""));
    end

    if studies == 1 then
        tab:push("| Directory Name | Path |");
        tab:push("|:--------------:|:----:|");
        for i = 1, studies do
            tab:push("| " .. label[i] .. " | " .. path[i]);
        end
    else
        tab:push("| Case | Directory Name | Path |");
        tab:push("|:----:|:--------------:|:----:|");
        for i = 1, studies do
            tab:push("| " .. i .. " | " .. label[i] .. " | " .. path[i]);
        end
    end

    tab:push("## About the model");
    if studies == 1 then
        tab:push("| Model | User | Version | Hash |");
        tab:push("|:-----:|:----:|:-------:|:----:|");
        for i = 1, studies do
            tab:push("| " .. model[i] .. " | " .. user[i] .. " | " .. version[i] .. " | " .. hash[i] .. " |");
        end
    else
        tab:push("| Case | Model | User | Version | Hash |");
        tab:push("|:----:|:-----:|:----:|:-------:|:----:|");
        for i = 1, studies do
            tab:push("| " .. i .. " | " .. model[i] .. " | " .. user[i] .. " | " .. version[i] .. " | " .. hash[i] .. " |");
        end
    end

    tab:push("## Case title");
        
    if studies == 1 then
        tab:push("| Title |");
        tab:push("|:-----------:|");
        for i = 1, studies do
            tab:push("| " .. description[i] .. " | ");
        end
    else
        tab:push("| Case | Title |");
        tab:push("|:----:|:-----------:|");
        for i = 1, studies do
            tab:push("| " .. i .. " | " .. description[i] .. " | ");
        end
    end
    
    tab:push("## Horizon, resolution and execution options");
    
    local header_string = "| Case parameter ";
    local lower_header_string = "|---------------";
    local nstg_string = "| Stages ";
    local ini_year_string = "| Initial year of study ";
    local nblk_string = "| Blocks ";
    local nforw_string = "| Forward series ";
    local nback_string = "| Backward series ";
    local hrep_string = "| Hourly representation ";
    local netrep_string = "| Network representation ";
    
    local hrep_val = {};
    local netrep_val = {};
    for i=1, studies do
        header_string       = header_string ..      " | " .. case_dir_list[i];
        lower_header_string = lower_header_string .. "|-----------";
        nstg_string         = nstg_string ..        " | " .. tostring(study[i]:stages());
        ini_year_string     = ini_year_string ..    " | " .. tostring(study[i]:initial_year());
        nblk_string         = nblk_string ..        " | " .. tostring(study[i]:get_parameter("NumberBlocks",-1));
        nforw_string        = nforw_string ..       " | " .. tostring(study[i]:scenarios());
        nback_string        = nback_string ..       " | " .. tostring(study[i]:openings());
        
        hrep_val[i] = "no";
        if study[i]:get_parameter("SIMH",-1) == 2 then
            hrep_val[i] = "yes";
        end
        hrep_string         = hrep_string ..        " | " .. hrep_val[i];
        
        netrep_val[i] = "no";
        if study[i]:get_parameter("Rede",-1) == 1 then
            netrep_val[i] = "yes";
        end
        netrep_string = netrep_string ..      " | " .. netrep_val[i];
    end
    header_string = header_string ..             "|";
    lower_header_string = lower_header_string .. "|";
    nstg_string = nstg_string ..                 "|";
    ini_year_string     = ini_year_string ..     "|";
    nblk_string         = nblk_string ..         "|";
    nforw_string        = nforw_string ..        "|";
    nback_string        = nback_string ..        "|";
    hrep_string         = hrep_string ..         "|";
    netrep_string         = netrep_string ..     "|";
    
    tab:push(header_string);
    tab:push(lower_header_string);
    tab:push(nstg_string);
    tab:push(ini_year_string);
    tab:push(nblk_string);
    tab:push(nforw_string);
    tab:push(nback_string);
    tab:push(hrep_string);
    tab:push(netrep_string);
    
    tab:push("## Dimensions");
    
    local sys_string = "| Systems ";
    local battery_string = "| Batteries ";
    local bus_string = "| Buses ";
    local circuit_string = "| Circuits ";
    local interc_string = "| Interconnections ";
    local hydro_string = "| Hydro plants ";
    local pinj_string = "| Power injections ";
    local renw_string = "| Renewable plants ";
    local thermal_string = "| Thermal plants ";
    
    for i=1, studies do
        sys_string         = sys_string ..     " | " .. tostring(#system[i]:labels());
        battery_string     = battery_string .. " | " .. tostring(#battery[i]:labels());
    
        if netrep_val == "yes" then
            bus_string         = bus_string ..     " | " .. tostring(#bus[i]:labels());
            circuit_string     = circuit_string .. " | " .. tostring(#circuit[i]:labels());
        else
            interc_string      = interc_string ..  " | " .. tostring(#interconnection[i]:labels());
        end
        
        hydro_string       = hydro_string ..   " | " .. tostring(#hydro[i]:labels());
        pinj_string        = pinj_string ..    " | " .. tostring(#power_injection[i]:labels());
        renw_string        = renw_string ..    " | " .. tostring(#renewable[i]:labels());
        thermal_string     = thermal_string .. " | " .. tostring(#thermal[i]:labels());
    end
    
    tab:push(header_string);
    tab:push(lower_header_string);
    tab:push(sys_string);
    tab:push(battery_string);
    if netrep_val == "yes" then
        tab:push(bus_string);
        tab:push(circuit_string);
    else
        tab:push(interc_string );
    end
    tab:push(hydro_string);
    tab:push(pinj_string);
    tab:push(renw_string);
    tab:push(thermal_string);
       
    return tab;
end

-----------------------------------------------------------------------------------------------
-- Inflow energy report function
-----------------------------------------------------------------------------------------------

local function create_inflow_energy()
    local inf_energ_rep = Tab("Inflow energy");
    
    local inferg = {};
    for i=1,studies do
        inferg[i] = generic[i]:load("sddp_dashboard_input_enaflu");
    end     
    
    -- Color vectors
    local chart = Chart("Total inflow energy");
    if studies > 1 then
        for i=1,studies do
        
           -- Confidence interval
           chart:add_area_range(inferg[i]:select_agent(1), inferg[i]:select_agent(3),{color={light_global_color[i],light_global_color[i]},showInLegend = false});
           chart:add_line(inferg[i]:select_agent(2):rename_agent(case_dir_list[i])); -- average
        end
    else
         -- Confidence interval
        chart:add_area_range(inferg[1]:select_agent(1), inferg[1]:select_agent(3),{color={light_global_color[1],light_global_color[1]}});
        chart:add_line(inferg[1]:select_agent(2)); -- average
    end 
    
    if #chart > 0 then
        inf_energ_rep:push(chart);
    end
    
    return inf_energ_rep;
end 

-----------------------------------------------------------------------------------------------
-- Policy report functions
-----------------------------------------------------------------------------------------------

local function get_conv_file_info(file_list, systems, horizons,case_index)
    -- Loading file
    local sddppol = generic[case_index]:load_table("sddppol.csv");

    local file_name = "";
    for i = 1, #sddppol do
        file_name = sddppol[i]["FileNames"]
        file_list[i] = string.sub(file_name, 1, #file_name - 4)
        systems[i]   = sddppol[i]["System"]
        horizons[i]  = sddppol[i]["InitialHorizon"] .. "-" .. sddppol[i]["FinalHorizon"];
    end
end

local function get_convergence_file_agents(file_list, conv_age, cuts_age, time_age,case_index)
    for i, file in ipairs(file_list) do
        local conv_file = generic[case_index]:load(file);
        conv_age[i] = conv_file:select_agents({1, 2, 3, 4}); -- Zinf        ,Zsup - Tol  ,Zsup        ,Zsup + Tol  
        cuts_age[i] = conv_file:select_agents({5, 6});       -- Optimality  ,Feasibility 
        time_age[i] = conv_file:select_agents({7, 8});       -- Forw. time, Back. time
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

-----------------------------------------------------------------------------------------------
-- Heatmap report functions
-----------------------------------------------------------------------------------------------

local function create_penalty_proportion_graph(tab,i)
    local penp = generic[i]:load("sddppenp");
    local chart = Chart("Share of violation penalties and deficit in the cost of each stage/scenario");
    chart:add_heatmap(penp, {showInLegend = false, stops = {{0.0,"#4E79A7"}, {0.5,"#FBEEB3"}, {1.0,"#C64B3E"}}, stopsMin = 0.0, stopsMax = 100.0 });
    tab:push(chart);
end

local function create_conv_map_graph(tab,i)
    local conv_map = generic[i]:load("sddpconvmap");
    local chart = Chart("Convergence map");
    chart:add_heatmap(conv_map,{ showInLegend = false, stops = {{0.0,"#C64B3E"}, {0.5,"#FBEEB3"}, {1.0,"#4E79A7"}}, stopsMin = 0, stopsMax = 2 });
    tab:push(chart);
end

local function create_hourly_sol_status_graph(tab,i)
    local status = generic[i]:load("sddpstatus");
    local chart = Chart("Execution status per stage and scenario");
    chart:add_heatmap(status,{ showInLegend = false, stops = {{0.0,"#8ACE7E"}, {0.33,"#4E79A7"}, {0.66,"#C64B3E"}, {1.0,"#FBEEB3"}}, stopsMin = 0, stopsMax = 3 });
    tab:push(chart);
end

local function create_pol_report()

    local pol_rep = Tab("Policy");
    
    local file_list = {};
    local systems   = {};
    local horizon   = {};
    
    local conv_data = {};
    local cuts_data = {};
    local time_data = {};
    
    local conv_file;
    
    -- Convergence report
    get_conv_file_info(file_list, systems, horizon,1);
    get_convergence_file_agents(file_list, conv_data, cuts_data, time_data,1);
    
    -- Creating policy report
    for i, file in ipairs(file_list) do 
        pol_rep:push("## System: " .. systems[i] .. " | Horizon: " .. horizon[i]);
        
        if studies > 1 then
            local chart_conv = Chart("Convergence report");
            local chart_cut_opt   = Chart("Added cuts - Optimality");
            local chart_cut_feas  = Chart("Added cuts - Feasibility");
            local chart_time_forw = Chart("Execution time - Forward");
            local chart_time_back = Chart("Execution time - Backward");
        
            for j=1,studies do
                conv_file = generic[j]:load(file);
                conv_age = conv_file:select_agents({1, 2, 3, 4}); -- Zinf        ,Zsup - Tol  ,Zsup        ,Zsup + Tol  
                cuts_age = conv_file:select_agents({5, 6});       -- Optimality  ,Feasibility 
                time_age = conv_file:select_agents({7, 8});       -- Forw. time, Back. time
            
                -- Confidence interval
                chart_conv:add_area_range(conv_age:select_agents({2}):rename_agent(case_dir_list[j] .. " - Zsup - Tol"), 
                                          conv_age:select_agents({4}):rename_agent(case_dir_list[j] .. " - Zsup + Tol"), 
                                          {color={light_global_color[j],
                                                  light_global_color[j]},
                                                  xAllowDecimals = false, 
                                                  showInLegend = true });
                
                -- Zsup
                chart_conv:add_line(conv_age:select_agents({3}):rename_agent(case_dir_list[j] .. " - Zsup"),
                                   {color={main_global_color[j]},
                                           xAllowDecimals = false});
                
                -- Zinf
                chart_conv:add_line(conv_age:select_agents({1}):rename_agent(case_dir_list[j] .. " - Zinf"),
                                   {color={main_global_color[j]}, 
                                           xAllowDecimals = false, 
                                           dashStyle = "dash"}); -- Zinf
                                        
                -- Cuts - optimality
                chart_cut_opt:add_column(cuts_age:select_agents({1}):rename_agent(case_dir_list[j]),
                                        {xAllowDecimals = false});
                
                -- Cuts - feasibility
                chart_cut_feas:add_column(cuts_age:select_agents({2}):rename_agent(case_dir_list[j]),
                                         {xAllowDecimals = false});
                
                -- Execution time - forward
                chart_time_forw:add_line(time_age:select_agents({1}):rename_agent(case_dir_list[j]),
                                        {xAllowDecimals = false});
                
                -- Execution time - backward
                chart_time_back:add_line(time_age:select_agents({2}):rename_agent(case_dir_list[j]),
                                        {xAllowDecimals = false});
            end
        
            if #chart_conv > 0 then
                pol_rep:push(chart_conv);
            end
            if #chart_cut_opt > 0 then
                pol_rep:push(chart_cut_opt);
            end
            if #chart_cut_feas > 0 then
                pol_rep:push(chart_cut_feas);
            end
            if #chart_time_forw > 0 then
                pol_rep:push(chart_time_forw);
            end
            if #chart_time_back > 0 then
                pol_rep:push(chart_time_back);
            end
        else
            -- Get operation mode parameter
            oper_mode = study[1]:get_parameter("Opcion", -1); -- 1=AIS; 2=COO; 3=INT;    
    
            nsys = calculate_number_of_systems(systems);
            graph_sim_cost = false;
            
            conv_file = generic[1]:load(file);
            conv_age = conv_file:select_agents({1, 2, 3, 4}); -- Zinf        ,Zsup - Tol  ,Zsup        ,Zsup + Tol  
            cuts_age = conv_file:select_agents({5, 6});       -- Optimality  ,Feasibility 
            time_age = conv_file:select_agents({7, 8});       -- Forw. time, Back. time
    
            -- If there is only one FCF file in the case, print final simulation cost as columns
            if( (oper_mode < 3 and nsys == 1) or  oper_mode == 3) then
                graph_sim_cost = true;
                local objcop = Generic():load("objcop");
                local discount_rate = require("sddp/discount_rate")(1);
            
                -- Select total cost and future cost agents
                local total_cost_age = objcop:select_agent(1):aggregate_scenarios(BY_AVERAGE());
                local future_cost_age = objcop:select_agent(-1):aggregate_scenarios(BY_AVERAGE());
                
                -- Calculating total cost as sum of immediate costs per stage
                immediate_cost = ((total_cost_age - future_cost_age)/discount_rate):aggregate_stages(BY_SUM()):rename_agent("Total cost"):to_list()[1];
                
                -- Take expression and use it as mask for "final_sim_cost"
                conv_age_aux = conv_age:select_agent(1):rename_agent("Final simulation");  
                final_sim_cost = conv_age_aux:fill(immediate_cost);
            end
            
            local chart = Chart("Convergence report");
            chart:add_area_range(conv_age:select_agents({2}), conv_age:select_agents({4}), {color={"#ACD98D","#ACD98D"},  xAllowDecimals = false }); -- Confidence interval
            chart:add_line(conv_age:select_agents({1}), {color={"#3CB7CC"},  xAllowDecimals = false }); -- Zinf
            chart:add_line(conv_age:select_agents({3}), {color={"#32A251"},  xAllowDecimals = false }); -- Zsup
            pol_rep:push(chart);
            
            chart = Chart("Number of added cuts report");
            chart:add_column(cuts_age, { xAllowDecimals = false }); -- Opt and Feas
            pol_rep:push(chart);
            
            chart = Chart("Forward and backward execution times");
            chart:add_line(time_age, { xAllowDecimals = false }); -- Forw. and Back. times
            pol_rep:push(chart);
        end
    end
    
    -- Convergence heatmap
    if studies == 1 then
        create_conv_map_graph(pol_rep,1);
    end
    
    return pol_rep;
end

-----------------------------------------------------------------------------------------------
-- Simulation objetive function cost terms report function
-----------------------------------------------------------------------------------------------

local function create_sim_report()
        
    local sim_rep = Tab("Simulation"); 
 
    local costs;
    local objcop;
    local discount_rate;
    local costs;
    local costs_agg;
    
    local chart = Chart("Breakdown of total operating costs");
    
    objcop = require("sddp/costs");
    discount_rate = require("sddp/discount_rate");
            
    if studies > 1 then
        for i=1,studies do
            objcop = require("sddp/costs");
            discount_rate = require("sddp/discount_rate");
            costs = ifelse(objcop(i):ge(0), objcop(i), 0) / discount_rate(i);
    
            -- sddp_dashboard_cost_tot
            costs_agg = costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):remove_zeros();
            chart:add_categories(costs_agg, case_dir_list[i]); 
        end
    else
        costs = ifelse(objcop(1):ge(0), objcop(1), 0) / discount_rate(1);
        costs_agg = costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):remove_zeros();
        
        if is_greater_than_zero(costs_agg) then
            chart:add_pie(costs_agg);
        end
      
    end
    
    if #chart > 0 then
        sim_rep:push(chart);
    end 
    
    -- Heatmap after the pizza graph in dashboard
    if studies == 1 then
        -- Creating simulation heatmap graphics
        if study[1]:get_parameter("SIMH",-1) == 2 then
            create_hourly_sol_status_graph(sim_rep,1);
        end
        create_penalty_proportion_graph(sim_rep,1);
    end
    
    return sim_rep;
end 

-----------------------------------------------------------------------------------------------
-- Simulation costs report function
-----------------------------------------------------------------------------------------------

local function create_costs_and_revs()
    local cost_rep = Tab("Costs & revenues");
    
    local objcop;
    local discount_rate;
    local costs;
    local costs_avg;
    
    local chart = Chart("Dispersion of operating costs per stage");	
    local chart_avg = Chart("Average operating costs per stage");		
            
    for i=1, studies do
        objcop = require("sddp/costs");
        discount_rate = require("sddp/discount_rate");
        costs = ifelse(objcop(i):ge(0), objcop(i), 0) / discount_rate(i);
    
        -- sddp_dashboard_cost_tot
        costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM());
        if studies == 1 then
            costs:save("sddp_dashboard_cost_tot", {remove_zeros = true, csv=true});
        end 
    
        -- sddp_dashboard_cost_disp
        local disp = concatenate(
            costs:aggregate_agents(BY_SUM(), "P10"):aggregate_scenarios(BY_PERCENTILE(10)),
            costs:aggregate_agents(BY_SUM(), "Average"):aggregate_scenarios(BY_AVERAGE()),
            costs:aggregate_agents(BY_SUM(), "P90"):aggregate_scenarios(BY_PERCENTILE(90))
        );
        
        if studies > 1 then
            if is_greater_than_zero(disp) then
                chart:add_area_range(disp:select_agent(1), disp:select_agent(3),{color = light_global_color[i], showInLegend = false}); -- Confidence interval
                chart:add_line(disp:select_agent(2):rename_agent(case_dir_list[i])); -- Average
            end 
        else
            if is_greater_than_zero(disp) then
                chart:add_area_range(disp:select_agent(1), disp:select_agent(3),{color={"#EA6B73","#EA6B73"}}); -- Confidence interval
                chart:add_line(disp:select_agent(2),{color={"#F02720"}}); -- Average
            end
        end 
        
        -- sddp_dashboard_cost_avg
        if studies > 1 then
            costs_avg = costs:aggregate_scenarios(BY_AVERAGE()):select_agent(1):rename_agent(case_dir_list[i] .. " - Average");
        else
            costs_avg = costs:aggregate_scenarios(BY_AVERAGE()):select_agent(1);
        end
        
        if is_greater_than_zero(costs_avg) then
            chart_avg:add_line(costs_avg);
        end        
    end
    
    if #chart > 0 then
        cost_rep:push(chart);
    end 
    
    if #chart_avg > 0 then
        cost_rep:push(chart_avg);
    end 
    
    return cost_rep;
end

-----------------------------------------------------------------------------------------------
-- Marginal cost report function
-----------------------------------------------------------------------------------------------

local function create_marg_costs()
    local marg_costs = Tab("Marginal costs");

    local cmg = {};
    local cmg_aggsum;
    local cmg_aggyear;
    
    local sys = {};
    for i=1,studies do
        sys[i] = System(i);
    end
    
    for i=1,studies do
        cmg[i] = sys[i]:load("cmgdem");
    end
	
	-- Marginal cost aggregated by average
    chart_subsys = Chart("Annual marginal cost by sub-system");
    if studies > 1 then
        for i=1,studies do
            cmg_aggyear = cmg[i]:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),Collection.SYSTEM);
        
            -- Add marginal costs outputs
            chart_subsys:add_categories(cmg_aggyear, case_dir_list[i]);  -- Annual Marg. cost     
        end
    else
        cmg_aggyear = cmg[1]:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR):aggregate_scenarios(BY_AVERAGE());
        chart_subsys:add_column(cmg_aggyear);
    end
    marg_costs:push(chart_subsys);
    
    if studies > 1 then
        agents = cmg[1]:agents();
        for i, agent in ipairs(agents) do
            local chart_per_stg = Chart("Average marginal costs per stage per subsystem".." - "..agent);
            for j=1,studies do
                cmg_aggsum = cmg[j]:select_agent(agent):rename_agent(case_dir_list[j]):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE())
                chart_per_stg:add_line(cmg_aggsum);  -- Average marg. cost per stage
            end 
            marg_costs:push(chart_per_stg);
        end
    else
        local chart_per_stg = Chart("Average marginal costs per stage per subsystem");
        cmg_aggsum  = cmg[1]:aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE());
        chart_per_stg:add_column(cmg_aggsum);
        marg_costs:push(chart_per_stg);
    end
    
    return marg_costs;
end

-----------------------------------------------------------------------------------------------
-- Generation report function
-----------------------------------------------------------------------------------------------

local function create_gen_report()
    local gen_rep = Tab("Generation");

-- Color preferences
    local color_hydro       = '#4E79A7';
    local color_thermal     = '#F28E2B';
    local color_wind        = '#8CD17D';
    local color_solar       = '#F1CE63';
    local color_small_hydro = '#A0CBE8';
    local color_battery     = '#B07AA1';
    local color_deficit     = '#000000';
    local color_pinj        = '#BAB0AC';

    local total_small_hydro_gen;
    local total_hydro_gen;      
    local total_batt_gen;   
    local total_deficit;    
    local total_pot_inj;    
    local total_wind_gen;   
    local total_solar_gen;  
    local total_thermal_gen;    
   
    local total_hydro_gen_age;
    local total_batt_gen_age;   
    local total_deficit_age;    
    local total_pot_inj_age;    
    local total_renw_gen_age;   
    local total_thermal_gen_age;
    
    local gerter = {};
	local gerhid = {};
	local gergnd = {};
    local wind   = {};
    local solar  = {};
	local gerbat = {};
	local potinj = {};
	local defcit = {};
    
    -- Loading generations files
    for i=1,studies do
        gerter[i] = thermal[i]:load("gerter");
        gerhid[i] = hydro[i]:load("gerhid");
        gergnd[i] = renewable[i]:load("gergnd");
        gerbat[i] = battery[i]:load("gerbat");
        potinj[i] = power_injection[i]:load("powinj");
        defcit[i] = system[i]:load("defcit");
    end
    
    if studies > 1 then
        chart_tot_gerhid  = Chart("Total Hydro");
        chart_tot_sml_hid = Chart("Total Small Hydro");
        chart_tot_gerter  = Chart("Total Thermal");
        chart_tot_renw    = Chart("Total Renewable");
        chart_tot_gerbat  = Chart("Total Battery");
        chart_tot_potinj  = Chart("Total Power Injection");
        chart_tot_defcit  = Chart("Total Deficit");
    else
        chart = Chart("Total generation");
    end
    
    -- Total generation report
    for i=1,studies do
    
        if studies > 1 then
            total_hydro_gen_age   = case_dir_list[i] .. " - ";
            total_batt_gen_age    = case_dir_list[i] .. " - ";
            total_deficit_age     = case_dir_list[i] .. " - ";
            total_pot_inj_age     = case_dir_list[i] .. " - ";
            total_renw_gen_age    = case_dir_list[i] .. " - ";
            total_thermal_gen_age = case_dir_list[i] .. " - ";
        else
            total_hydro_gen_age   = "";
            total_batt_gen_age    = "";
            total_deficit_age     = "";
            total_pot_inj_age     = "";
            total_renw_gen_age    = "";
            total_thermal_gen_age = "";
        end
        
        total_hydro_gen_age   = total_hydro_gen_age   .. "Total Hydro"
        total_batt_gen_age    = total_batt_gen_age    .. "Total Battery" 
        total_deficit_age     = total_deficit_age     .. "Total Deficit" 
        total_pot_inj_age     = total_pot_inj_age     .. "Total P. Inj." 
        total_renw_gen_age    = total_renw_gen_age    .. "Total Renewable"
        total_thermal_gen_age = total_thermal_gen_age .. "Total Thermal" 
        
        -- Data processing
        total_hydro_gen   = gerhid[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),total_hydro_gen_age);
        total_batt_gen    = gerbat[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),total_batt_gen_age);   
        total_deficit     = defcit[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),total_deficit_age);    
        total_pot_inj     = potinj[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),total_pot_inj_age);    
        total_renw_gen    = gergnd[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),total_renw_gen_age);
        total_thermal_gen = gerter[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(),total_thermal_gen_age);

        if studies > 1 then
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
        else
            chart:add_area_stacking(total_thermal_gen,{color={color_thermal}});
            chart:add_area_stacking(total_hydro_gen,{color={color_hydro}});
            chart:add_area_stacking(total_batt_gen,{color={color_battery}});
            chart:add_area_stacking(total_pot_inj,{color={color_pinj}});
            chart:add_area_stacking(total_deficit,{color={color_deficit}});
        end 
    end
    
    if studies > 1 then
        if #chart_tot_gerhid > 0 then
            gen_rep:push(chart_tot_gerhid);
        end
        if #chart_tot_gerter > 0 then
            gen_rep:push(chart_tot_gerter);
        end
        if #chart_tot_renw > 0 then
            gen_rep:push(chart_tot_renw);
        end 
        if #chart_tot_gerbat > 0 then
            gen_rep:push(chart_tot_gerbat);
        end
        if #chart_tot_potinj > 0 then
            gen_rep:push(chart_tot_potinj);
        end 
        if #chart_tot_defcit > 0 then
            gen_rep:push(chart_tot_defcit);
        end
    else
        gen_rep:push(chart);
    end 
    
    if studies > 1 then
        -- Generation per system report
        agents = generic[1]:load("cmgdem"):agents();
        for i, agent in ipairs(agents) do
        
            chart_tot_gerhid  = Chart("Total Hydro - "..agent);
            chart_tot_gerter  = Chart("Total Thermal - "..agent);
            chart_tot_renw    = Chart("Total Renewable - "..agent);
            chart_tot_gerbat  = Chart("Total Battery - "..agent);
            chart_tot_potinj  = Chart("Total Power Injection - "..agent);
            chart_tot_defcit  = Chart("Total Deficit - "..agent);
        
            for i=1,studies do
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
                gen_rep:push(chart_tot_gerhid);
            end
            if #chart_tot_gerter > 0 then
                gen_rep:push(chart_tot_gerter);
            end
            if #chart_tot_renw > 0 then
                gen_rep:push(chart_tot_renw);
            end 
            if #chart_tot_gerbat > 0 then
                gen_rep:push(chart_tot_gerbat);
            end
            if #chart_tot_potinj > 0 then
                gen_rep:push(chart_tot_potinj);
            end 
            if #chart_tot_defcit > 0 then
                gen_rep:push(chart_tot_defcit);
            end     
        end
    end
    
    return gen_rep;
end

local function create_risk_report()
    local risk_rep = Tab("Risk");
    local chart = Chart("Deficit risk by sub-system");
    
    if studies > 1 then
        for i=1,studies do
            risk_file = system[i]:load("sddprisk"):aggregate_agents(BY_AVERAGE(),Collection.SYSTEM);
        
            -- Add marginal costs outputs
            chart:add_categories(risk_file, case_dir_list[i]);  -- Annual Marg. cost     
        end
    else
        risk_file = system[1]:load("sddprisk");
        chart:add_column(risk_file);
    end
    
    if #chart > 0 then
        risk_rep:push(chart);
    end
    
    return risk_rep;
end

-----------------------------------------------------------------------------------------------
-- Violation reports data and methods
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

local function create_viol_report(tab, viol_struct, suffix)
    
    local file_name;
    local viol_file;
    
    if studies > 1 then
        for i, struct in ipairs(viol_struct) do
        
            file_name = "sddp_dashboard_viol_" .. suffix .. "_" .. struct.name;
            viol_file = generic[1]:load(file_name);
            
            -- Assuming agents in reference case(1st case) are the same as the ones in the others
            agents = viol_file:agents();
            for j, agent in ipairs(agents) do
                local chart = Chart(struct.title .. " - "..agent);
                for k=1,studies do
                    viol_file = generic[k]:load(file_name):select_agent(agent):rename_agent(case_dir_list[k]);
                    if viol_file:loaded() then
                        chart:add_column_stacking(viol_file);
                    end
                end
                tab:push(chart);
            end
        end
    else
        for i, struct in ipairs(viol_struct) do
            file_name = "sddp_dashboard_viol_" .. suffix .. "_" .. struct.name;
            viol_file = generic[1]:load(file_name);
            if viol_file:loaded() then
                local chart = Chart(struct.title);
                chart:add_column_stacking(viol_file);
                tab:push(chart);
            end
        end
    end 
end

-----------------------------------------------------------------------------------------------
-- Dashboard tab configuration
-----------------------------------------------------------------------------------------------

-- Main tabs
local tab_input_data = Tab("Input data");
local tab_sol_qual   = Tab("Solution quality");
local tab_violations = Tab("Violations");
local tab_results    = Tab("Results");

-- Violation tabs
local tab_viol_avg = Tab("Average");
local tab_viol_max = Tab("Maximum");

tab_input_data:set_collapsed(false);
tab_sol_qual:set_collapsed(true);
tab_violations:set_collapsed(true);
tab_results:set_collapsed(true);

tab_input_data:set_disabled();
tab_sol_qual:set_disabled();
tab_violations:set_disabled();
tab_results:set_disabled();

-- Set icons of the main tabs
tab_input_data:set_icon("file-input"); -- Alternative: arrow-big-right
tab_sol_qual:set_icon("alert-triangle");
tab_violations:set_icon("siren");
tab_results:set_icon("line-chart");

-- Input data
tab_input_data:push(create_tab_summary());
tab_input_data:push(create_inflow_energy());

-- Solution quality - Policy report
tab_sol_qual:push(create_pol_report());

-- Solution quality - Simulation report
tab_sol_qual:push(create_sim_report());

-- Violation
if studies == 1 then
    create_viol_report(tab_viol_avg,viol_report_structs,"avg");
    create_viol_report(tab_viol_max,viol_report_structs,"max");
    
    tab_violations:push(tab_viol_avg);
    tab_violations:push(tab_viol_max);
end

-- Results
tab_results:push(create_costs_and_revs());
tab_results:push(create_marg_costs());
tab_results:push(create_gen_report());
tab_results:push(create_risk_report());

local dashboard = Dashboard();
dashboard:push(tab_input_data);
dashboard:push(tab_sol_qual);

if studies == 1 then
    dashboard:push(tab_violations);
end

dashboard:push(tab_results);
dashboard:save("SDDPDashboard");