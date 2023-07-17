-- Setting global colors
local main_global_color = { "#4E79A7", "#F28E2B", "#8CD17D", "#B6992D", "#E15759", "#76B7B2", "#FF9DA7", "#D7B5A6", "#B07AA1", "#59A14F", "#F1CE63", "#A0CBE8", "#E15759" };
local light_global_color = { "#B7C9DD", "#FAD2AA", "#D1EDCB", "#E9DAA4", "#F3BCBD", "#C8E2E0", "#FFD8DC", "#EFE1DB", "#DFCAD9", "#BBDBB7", "#F9EBC1", "#D9EAF6", "#F3BCBD" };

PSR.set_global_colors(main_global_color);

-- Study dimension
local studies = PSR.studies();

-----------------------------------------------------------------------------------------------
-- Auxiliary functions
-----------------------------------------------------------------------------------------------

local function push_tab_to_tab(tab_from, tab_to)
    if #tab_from > 0 then
        tab_to:push(tab_from);
    end 
end

local function is_greater_than_zero(output)
    local x = output:abs():aggregate_agents(BY_SUM(), "CheckZeros"):aggregate_stages(BY_SUM()):to_list();
    if x[1] > 0.0 then
        return true;
    else
        return false;
    end
end

local function load_info_file(file_name,case_index)

    -- Initialize struct
    info_struct = {{model = ""}, {user = ""}, {version = ""}, {hash = ""}, {model = ""}, {status = ""}, {infrep = ""}, {dash_name = ""}};
    
    local toml = Generic(case_index):load_toml(file_name);
    model      = toml:get_string("model", "---");
    user       = toml:get_string("user", "---");
    version    = toml:get_string("version", "---");
    hash       = toml:get_string("hash", "---");
    status     = toml:get_string("status", "---");
    infrep     = toml:get_string("infrep", "---");
    dash_name  = toml:get_string("dash", "---");
    
    info_struct.model     = model;
    info_struct.user      = user;
    info_struct.version   = version;
    info_struct.hash      = hash;
    info_struct.status    = tonumber(status);
    info_struct.infrep    = infrep;
    info_struct.dash_name = dash_name;
      
    return info_struct;
end

local function load_model_info(col_struct, info_struct)
    local file_exists;
    local info_file_name = "SDDP.info";
    local existence_log = {}
    
    for i = 1, studies do
        -- Verify whether info file exists for each case
        file_exists = col_struct.generic[i]:file_exists(info_file_name);
        table.insert(existence_log,file_exists);
        
        -- Loading info files from each case
        if existence_log[i] then
            info_struct[i] = load_info_file(info_file_name,i);
        end
    end
    
    return existence_log;
end

local function load_collections(col_struct, info_struct)
    for i = 1, studies do
        table.insert(col_struct.battery        , Battery(i));
        table.insert(col_struct.bus            , Bus(i));
        table.insert(col_struct.circuit        , Circuit(i));
        table.insert(col_struct.generic        , Generic(i));
        table.insert(col_struct.hydro          , Hydro(i));
        table.insert(col_struct.interconnection, Interconnection(i));
        table.insert(col_struct.power_injection, PowerInjection(i));
        table.insert(col_struct.renewable      , Renewable(i));
        table.insert(col_struct.study          , Study(i));
        table.insert(col_struct.system         , System(i));
        table.insert(col_struct.thermal        , Thermal(i));
        
        table.insert(col_struct.case_dir_list  , Generic(i):dirname());
    end
end

local function remove_case_info(col_struct, info_struct, case_index)
    table.remove(col_struct.battery        , case_index);
    table.remove(col_struct.bus            , case_index);
    table.remove(col_struct.circuit        , case_index);
    table.remove(col_struct.generic        , case_index);
    table.remove(col_struct.hydro          , case_index);
    table.remove(col_struct.interconnection, case_index);
    table.remove(col_struct.power_injection, case_index);
    table.remove(col_struct.renewable      , case_index);
    table.remove(col_struct.study          , case_index);
    table.remove(col_struct.system         , case_index);
    table.remove(col_struct.thermal        , case_index);
          
    table.remove(col_struct.case_dir_list  , case_index);
    
    -- Loading info files from each case
    table.remove(info_struct, case_index);
end 

-----------------------------------------------------------------------------------------------
-- Infeasibility report function
-----------------------------------------------------------------------------------------------
local function dash_infeasibility(tab,file_name,case_index)

    local inv_table = Study(case_index):load_table_without_header(file_name);
    
    for lin=1,#inv_table do
        local data=(inv_table[lin][1]);
        local col = 2
        local stg_concat = data;
        if not data then
            tab:push(" ");
        else
            local data_2=(inv_table[lin][col]);
            while data_2 do
                stg_concat = stg_concat..","..data_2;
                col = col + 1;
                data_2=(inv_table[lin][col]);
            end
            tab:push(stg_concat);
        end
    end
end
-----------------------------------------------------------------------------------------------
-- Case summary report function
-----------------------------------------------------------------------------------------------

local function create_tab_summary(col_struct, info_struct)
       
    local tab = Tab("Info");
    tab:set_icon("info");
    
    tab:push("# Case summary");

    local exe_status_str;
    
    local label = {};
    local path = {};

    local model = {};
    local user = {}
    local version = {};
    local hash = {};
    local description = {};

    for i = 1, studies do
        table.insert(label,col_struct.generic[i]:cloudname());
        table.insert(path, col_struct.generic[i]:path());

        local study = Study(i);
        table.insert(description, study:get_parameter("Descricao", ""));
    end

    if studies == 1 then
        tab:push("| Directory Name | Path | Execution status |");
        tab:push("|:--------------:|:----:|:----------------:|");
        for i = 1, studies do
            exe_status_str = "SUCCESS";
            if info_struct[i].status > 0 then
                exe_status_str = "FAIL";
            end
            
            tab:push("| " .. label[i] .. " | " .. path[i].. " | " .. exe_status_str);
        end
    else
        tab:push("| Case | Directory Name | Path | Execution status |");
        tab:push("|:----:|:--------------:|:----:|:----------------:|");
        for i = 1, studies do
            exe_status_str = "SUCCESS";
            if info_struct[i].status > 0 then
                exe_status_str = "FAIL";
            end
            
            tab:push("| " .. i .. " | " .. label[i] .. " | " .. path[i] .. " | " .. exe_status_str);
        end
    end

    tab:push("## About the model");
    if studies == 1 then
        tab:push("| Model | User | Version | ID |");
        tab:push("|:-----:|:----:|:-------:|:----:|");
        for i = 1, studies do
            tab:push("| " .. info_struct[i].model .. " | " .. info_struct[i].user .. " | " .. info_struct[i].version .. " | " .. info_struct[i].hash .. " |");
        end
    else
        tab:push("| Case | Model | User | Version | ID |");
        tab:push("|:----:|:-----:|:----:|:-------:|:----:|");
        for i = 1, studies do
            tab:push("| " .. i .. " | " .. info_struct[i].model .. " | " .. info_struct[i].user .. " | " .. info_struct[i].version .. " | " .. info_struct[i].hash .. " |");
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

    local header_string       = "| Case parameter ";
    local lower_header_string = "|---------------";
    local exe_type_string     = "| Execution type ";
    local case_type_string    = "| Case type ";
    local nstg_string         = "| Stages ";
    local ini_year_string     = "| Initial year of study ";
    local nblk_string         = "| Blocks ";
    local nforw_string        = "| Forward series ";
    local nback_string        = "| Backward series ";
    local hrep_string         = "| Hourly representation ";
    local netrep_string       = "| Network representation ";

    local hrep_val   = {};
    local netrep_val = {};
    local exe_type   = {};
    local case_type  = {};
   
    for i = 1, studies do
        header_string = header_string             .. " | " .. col_struct.case_dir_list[i];
        lower_header_string = lower_header_string .. "|-----------";
        
        exe_type[i] = "Policy";
        if col_struct.study[i]:get_parameter("Objetivo", -1) == 2 then
            exe_type[i] = "Simulation";
        end
        exe_type_string = exe_type_string .. " | " .. exe_type[i];
        
        case_type[i] = "Monthly";
        if col_struct.study[i]:stage_type() == 1 then
            case_type[i] = "Weekly";
        end
        case_type_string = case_type_string .. " | " .. case_type[i];
        
        nstg_string      = nstg_string      .. " | " .. tostring(col_struct.study[i]:stages());
        ini_year_string  = ini_year_string  .. " | " .. tostring(col_struct.study[i]:initial_year());
        nblk_string      = nblk_string      .. " | " .. tostring(col_struct.study[i]:get_parameter("NumberBlocks", -1));
        nforw_string     = nforw_string     .. " | " .. tostring(col_struct.study[i]:scenarios());
        nback_string     = nback_string     .. " | " .. tostring(col_struct.study[i]:openings());
 
        hrep_val[i] = "no";
        if col_struct.study[i]:get_parameter("SIMH", -1) == 2 then
            hrep_val[i] = "yes";
        end
        hrep_string = hrep_string .. " | " .. hrep_val[i];

        netrep_val[i] = "no";
        if col_struct.study[i]:get_parameter("Rede", -1) == 1 then
            netrep_val[i] = "yes";
        end
        netrep_string = netrep_string .. " | " .. netrep_val[i];
    end
    header_string       = header_string       .. "|";
    lower_header_string = lower_header_string .. "|";
    exe_type_string     = exe_type_string     .. "|";
    case_type_string    = case_type_string    .. "|";
    nstg_string         = nstg_string         .. "|";
    ini_year_string     = ini_year_string     .. "|";
    nblk_string         = nblk_string         .. "|";
    nforw_string        = nforw_string        .. "|";
    nback_string        = nback_string        .. "|";
    hrep_string         = hrep_string         .. "|";
    netrep_string       = netrep_string       .. "|";

    tab:push(header_string);
    tab:push(lower_header_string);
    tab:push(exe_type_string);
    tab:push(case_type_string);
    tab:push(nstg_string);
    tab:push(ini_year_string);
    tab:push(nblk_string);
    tab:push(nforw_string);
    tab:push(nback_string);
    tab:push(hrep_string);
    tab:push(netrep_string);

    tab:push("## Dimensions");

    local sys_string      = "| Systems ";
    local battery_string  = "| Batteries ";
    local bus_string      = "| Buses ";
    local circuit_string  = "| Circuits ";
    local interc_string   = "| Interconnections ";
    local hydro_string    = "| Hydro plants ";
    local pinj_string     = "| Power injections ";
    local renw_w_string   = "| Renewable plants - Wind ";
    local renw_s_string   = "| Renewable plants - Solar";
    local renw_sh_string  = "| Renewable plants - Small hydro";
    local renw_oth_string = "| Renewable plants - Other tech.";
    local thermal_string  = "| Thermal plants ";

    for i = 1, studies do
        sys_string = sys_string             .. " | " .. tostring(#col_struct.system[i]:labels());
        battery_string = battery_string     .. " | " .. tostring(#col_struct.battery[i]:labels());
                                            
        if netrep_val == "yes" then         
            bus_string = bus_string         .. " | " .. tostring(#col_struct.bus[i]:labels());
            circuit_string = circuit_string .. " | " .. tostring(#col_struct.circuit[i]:labels());
        else
            interc_string = interc_string   .. " | " .. tostring(#col_struct.interconnection[i]:labels());
        end

        hydro_string    = hydro_string    .. " | " .. tostring(#col_struct.hydro[i]:labels());
        pinj_string     = pinj_string     .. " | " .. tostring(#col_struct.power_injection[i]:labels());
        
        total_renw = #col_struct.renewable[i]:labels();
        renw_wind  = col_struct.renewable[i].tech_type:select_agents(col_struct.renewable[i].tech_type:eq(1)):agents_size();
        renw_solar = col_struct.renewable[i].tech_type:select_agents(col_struct.renewable[i].tech_type:eq(2)):agents_size();
        renw_sh    = col_struct.renewable[i].tech_type:select_agents(col_struct.renewable[i].tech_type:eq(4)):agents_size();
        renw_oth   = total_renw - renw_wind - renw_solar - renw_sh;
        
        renw_sh_string  = renw_sh_string  .. " | " .. tostring(renw_sh);
        renw_w_string   = renw_w_string   .. " | " .. tostring(renw_wind);
        renw_s_string   = renw_s_string   .. " | " .. tostring(renw_solar);
        renw_oth_string = renw_oth_string .. " | " .. tostring(renw_oth);
        
        thermal_string  = thermal_string  .. " | " .. tostring(#col_struct.thermal[i]:labels());
    end

    tab:push(header_string);
    tab:push(lower_header_string);
    tab:push(sys_string);
    tab:push(hydro_string);
    tab:push(thermal_string);
    tab:push(renw_w_string);
    tab:push(renw_s_string);
    tab:push(renw_sh_string)
    tab:push(renw_oth_string);
    tab:push(battery_string);
    tab:push(pinj_string);
    if netrep_val == "yes" then
        tab:push(bus_string);
        tab:push(circuit_string);
    else
        tab:push(interc_string);
    end

    return tab;
end

-----------------------------------------------------------------------------------------------
-- Inflow energy report function
-----------------------------------------------------------------------------------------------

local function create_inflow_energy(col_struct)
    local tab = Tab("Inflow energy");

    local inferg = {};
    for i = 1, studies do
        inferg[i] = col_struct.generic[i]:load("sddp_dashboard_input_enaflu");
    end

    -- Color vectors
    local chart = Chart("Total inflow energy");
    if studies > 1 then
        for i = 1, studies do

            -- Confidence interval
            chart:add_area_range(inferg[i]:select_agent(1):add_prefix(col_struct.case_dir_list[i] .. " - "), inferg[i]:select_agent(3), { xUnit="Stage", color = { light_global_color[i], light_global_color[i] } });
            chart:add_line(inferg[i]:select_agent(2):add_prefix(col_struct.case_dir_list[i] .. " - ")); -- average
        end
    else
        -- Confidence interval
        chart:add_area_range(inferg[1]:select_agent(1), inferg[1]:select_agent(3), { xUnit="Stage", color = { light_global_color[1], light_global_color[1] } });
        chart:add_line(inferg[1]:select_agent(2)); -- average
    end

    if #chart > 0 then
        tab:push(chart);
    end

    return tab;
end

-----------------------------------------------------------------------------------------------
-- Policy report functions
-----------------------------------------------------------------------------------------------

local function get_conv_file_info(col_struct, file_name, file_list, systems, horizons, case_index)
    -- Loading file
    local sddppol = col_struct.generic[case_index]:load_table(file_name);

    local file_name = "";
    for i = 1, #sddppol do
        file_name = sddppol[i]["FileNames"]
        file_list[i] = string.sub(file_name, 1, #file_name - 4)
        systems[i] = sddppol[i]["System"]
        horizons[i] = sddppol[i]["InitialHorizon"] .. "-" .. sddppol[i]["FinalHorizon"];
    end
end

local function get_convergence_file_agents(col_struct, file_list, conv_age, cuts_age, time_age, case_index)
    for i, file in ipairs(file_list) do
        local conv_file = col_struct.generic[case_index]:load(file);
        conv_age[i] = conv_file:select_agents({ 1, 2, 3, 4 }); -- Zinf, Zsup - Tol, Zsup, Zsup + Tol  
        cuts_age[i] = conv_file:select_agents({ 5, 6 }); -- Optimality, Feasibility 
        time_age[i] = conv_file:select_agents({ 7, 8 }); -- Forw. time, Back. time
    end
end

local function get_convergence_map_status(col_struct, file_list, conv_status, case_index)
    for i, file in ipairs(file_list) do
        local conv_map_file = col_struct.generic[case_index]:load(file);
        conv_status[i] = conv_map_file; -- Convergence status
    end
end

local function make_convergence_graphs(dashboard, conv_age, systems, horizon)
    for i, conv in ipairs(conv_age) do
        local chart = Chart("Convergence | System: " .. systems[i] .. " | Horizon: " .. horizon[i]);
        chart:add_area_range(conv:select_agents({ 2 }), conv:select_agents({ 4 }), { color = { "#ACD98D", "#ACD98D" }, xAllowDecimals = false }); -- Confidence interval
        chart:add_line(conv:select_agents({ 1 }), { color = { "#3CB7CC" }, xAllowDecimals = false }); -- Zinf
        chart:add_line(conv:select_agents({ 3 }), { color = { "#32A251" }, xAllowDecimals = false }); -- Zsup
        dashboard:push(chart);
    end
end

local function make_added_cuts_graphs(dashboard, cuts_age, systems, horizon)
    for i, cuts in ipairs(cuts_age) do
        local chart = Chart("Number of added cuts | System: " .. systems[i] .. " Horizon: " .. horizon[i]);
        chart:add_column(cuts:select_agents({ 1 }), { xAllowDecimals = false }); -- Opt
        chart:add_column(cuts:select_agents({ 2 }), { xAllowDecimals = false }); -- Feas
        dashboard:push(chart);
    end
end

local function calculate_number_of_systems(sys_vec)
    local sys_name = sys_vec[1];
    local counter = 1;
    for i, name in ipairs(sys_vec) do
        if (sys_name ~= name) then
            counter = counter + 1;
            sys_name = name
        end
    end

    return counter;
end

-----------------------------------------------------------------------------------------------
-- Heatmap report functions
-----------------------------------------------------------------------------------------------

local function create_penalty_proportion_graph(tab, col_struct, i)
    local output_name  = "sddppenp";
    local report_title = "Share of violation penalties and deficit in the cost of each stage/scenario";
    local penp = col_struct.generic[i]:load(output_name);
    
    if not penp:loaded() then
        info(output_name .. " could not be loaded. ".. "'" .. report_title .. "'" .. "report will not be displayed");
        return
    end
    
    penp:convert("%");
    
    local chart = Chart(report_title .. " (%)");
    chart:add_heatmap_series(penp, { yLabel = "Scenario", xLabel = "Stage", showInLegend = false, stops = { { 0.0, "#4E79A7" }, { 0.5, "#FBEEB3" }, { 1.0, "#C64B3E" } }, stopsMin = 0.0, stopsMax = 100.0 });
    tab:push(chart);
end

local function create_conv_map_graph(tab, file_name, col_struct, i)
    local conv_map = col_struct.generic[i]:load(file_name);
    local report_title = "Convergence map";

    if not conv_map:loaded() then
        info(file_name .. " could not be loaded. ".. "'" .. report_title .. "'" .. "report will not be displayed");
        return
    end
    
    local options = {
    yLabel = "Iteration",
    xLabel = "Stage",
    showInLegend = false,
    stopsMin = 0,
    stopsMax = 2,
    dataClasses = {
                  { color = "#4E79A7", to = 0  , name = "converged" },
                  { color = "#FBEEB3", from = 1, to = 2, name = "warning" },
                  { color = "#C64B3E", from = 2, name = "not converged" }
                  }
    };

    local chart = Chart(report_title);
    chart:add_heatmap(conv_map,options);
    tab:push(chart);
end

local function create_hourly_sol_status_graph(tab, col_struct, i)
    local output_name  = "hrstat";
    local report_title = "Solution status per stage and scenario";
    local status = col_struct.generic[i]:load(output_name);
    
    if not status:loaded() then
        info(output_name .. " output could not be loaded. ".. "'" .. report_title .. "'" .. "report will not be displayed");
        return
    end
    
    local options = {
    yLabel = "Scenario",
    xLabel = "Stage",
    showInLegend = false,
    stopsMin = 0,
    stopsMax = 3,
    dataClasses = {
                  { color = "#8ACE7E", to = 0, name = "success" },
                  { color = "#4E79A7", from = 1, to = 2, name = "warning" },
                  { color = "#C64B3E", from = 2, to = 3, name = "error" },
                  { color = "#FBEEB3", from = 3, name = "linear" }
                  }
    };

    local chart = Chart(report_title);
    chart:add_heatmap(status,options);
    tab:push(chart);
end

-- Execution times per scenario (dispersion)
local function create_exe_timer_per_scen(tab, col_struct, i)
    local extime_chart;
    local output_name  = "extime";
    local extime = col_struct.generic[i]:load(output_name);
    
    if not extime:loaded() then
        info(output_name .. " output could not be loaded. 'Dispersion of execution times per scenario' report will not be displayed");
        return
    end
    
    local extime_disp = concatenate(extime:aggregate_agents(BY_SUM(), "P10"):aggregate_scenarios(BY_PERCENTILE(10)), extime:aggregate_agents(BY_SUM(), "Average"):aggregate_scenarios(BY_AVERAGE()), extime:aggregate_agents(BY_SUM(), "P90"):aggregate_scenarios(BY_PERCENTILE(90)));
    if is_greater_than_zero(extime_disp) then
        local unit = "hour";
        local extime_disp_data = extime_disp:aggregate_scenarios(BY_MAX()):aggregate_stages(BY_MAX()):to_list();
        
        if extime_disp_data[1] < 1.0 then
            unit = "ms";
        elseif extime_disp_data[1] < 3600.0 then
            unit = "s";
        end
        
        extime_chart = Chart("Dispersion of execution times per scenario");
        extime_chart:add_area_range(extime_disp:select_agent(1):convert(unit),
                                    extime_disp:select_agent(3):convert(unit), 
                                    { xUnit = "Stage", color = { "#EA6B73", "#EA6B73" } }); -- Confidence interval
        extime_chart:add_line(extime_disp:select_agent(2):convert(unit),
                              { xUnit = "Stage", color = { "#F02720" } });                  -- Average
                              
        if #extime_chart > 0 then
            tab:push(extime_chart);
        end
    end
end 

local function create_pol_report(col_struct)
    local tab = Tab("Policy");

    local total_cost_age;
    local future_cost_age;
    local immediate_cost;
    
    local file_list = {};
    local convm_file_list = {};
    local systems = {};
    local horizon = {};

    local conv_data = {};
    local cuts_data = {};
    local time_data = {};
    conv_status     = {};

    local conv_file;

    -- Convergence map report
    get_conv_file_info(col_struct, "sddpconvm.csv", convm_file_list, systems, horizon, 1);
    get_convergence_map_status(col_struct, convm_file_list, conv_status, 1);
            
    -- Convergence report
    get_conv_file_info(col_struct, "sddppol.csv", file_list, systems, horizon, 1);
    get_convergence_file_agents(col_struct, file_list, conv_data, cuts_data, time_data, 1);
    
    -- Creating policy report
    for i, file in ipairs(file_list) do
        tab:push("## System: " .. systems[i] .. " | Horizon: " .. horizon[i]);

        if studies > 1 then
            local chart_conv      = Chart("Convergence");
            local chart_cut_opt   = Chart("New cuts per iteration - Optimality");
            local chart_cut_feas  = Chart("New cuts per iteration - Feasibility");
            local chart_time_forw = Chart("Execution time - Forward");
            local chart_time_back = Chart("Execution time - Backward");

            for j = 1, studies do
                conv_file = col_struct.generic[j]:load(file);
                if conv_file:loaded() then
                    conv_age = conv_file:select_agents({ 1, 2, 3, 4 }); -- Zinf        ,Zsup - Tol  ,Zsup        ,Zsup + Tol  
                    cuts_age = conv_file:select_agents({ 5, 6 }); -- Optimality  ,Feasibility 
                    time_age = conv_file:select_agents({ 7, 8 }); -- Forw. time, Back. time
    
                    -- Confidence interval
                    chart_conv:add_area_range(conv_age:select_agents({ 2 }):rename_agent(col_struct.case_dir_list[j] .. " - Zsup - Tol"), conv_age:select_agents({ 4 }):rename_agent(col_struct.case_dir_list[j] .. " - Zsup + Tol"), { color = { light_global_color[j], light_global_color[j] }, xUnit = "Iteration", xAllowDecimals = false, showInLegend = true });
    
                    -- Zsup
                    chart_conv:add_line(conv_age:select_agents({ 3 }):rename_agent(col_struct.case_dir_list[j] .. " - Zsup"), { color = { main_global_color[j] }, xAllowDecimals = false });
    
                    -- Zinf
                    chart_conv:add_line(conv_age:select_agents({ 1 }):rename_agent(col_struct.case_dir_list[j] .. " - Zinf"), { color = { main_global_color[j] }, xAllowDecimals = false, dashStyle = "dash" }); -- Zinf
    
                    -- Cuts - optimality
                    chart_cut_opt:add_column(cuts_age:select_agents({ 1 }):rename_agent(col_struct.case_dir_list[j]), { xUnit = "Iteration", xAllowDecimals = false });
    
                    -- Cuts - feasibility
                    if is_greater_than_zero(cuts_age:select_agents({ 2 })) then
                        chart_cut_feas:add_column(cuts_age:select_agents({ 2 }):rename_agent(col_struct.case_dir_list[j]), { xUnit = "Iteration", xAllowDecimals = false });
                    end 
                    -- Execution time - forward
                    chart_time_forw:add_column(time_age:select_agents({ 1 }):rename_agent(col_struct.case_dir_list[j]), { xUnit = "Iteration", xAllowDecimals = false });
    
                    -- Execution time - backward
                    chart_time_back:add_column(time_age:select_agents({ 2 }):rename_agent(col_struct.case_dir_list[j]), { xUnit = "Iteration", xAllowDecimals = false });
                else
                    info("Comparing cases have different policy horizons! Policy will only contain the main case data.");
                end
            end

            if #chart_conv > 0 then
                tab:push(chart_conv);
            end
            if #chart_cut_opt > 0 then
                tab:push(chart_cut_opt);
            end
            if #chart_cut_feas > 0 then
                tab:push(chart_cut_feas);
            end
            if #chart_time_forw > 0 then
                tab:push(chart_time_forw);
            end
            if #chart_time_back > 0 then
                tab:push(chart_time_back);
            end
        else
            -- Get operation mode parameter
            oper_mode = col_struct.study[1]:get_parameter("Opcion", -1); -- 1=AIS; 2=COO; 3=INT;    

            nsys = calculate_number_of_systems(systems);
            graph_sim_cost = false;

            conv_file = col_struct.generic[1]:load(file);
            conv_age = conv_file:select_agents({ 1, 2, 3, 4 }); -- Zinf        ,Zsup - Tol  ,Zsup        ,Zsup + Tol  
            cuts_age = conv_file:select_agents({ 5, 6 }); -- Optimality  ,Feasibility 
            time_age = conv_file:select_agents({ 7, 8 }); -- Forw. time, Back. time

            -- If there is only one FCF file in the case, print final simulation cost as columns
            if ((oper_mode < 3 and nsys == 1) or oper_mode == 3) then
                graph_sim_cost = true;
                local objcop = col_struct.generic[1]:load("objcop");
                local discount_rate = require("sddp/discount_rate")(1);

                if col_struct.study[1]:get_parameter("SIMH", -1) == 2 then -- Hourly model writes objcop with different columns
                    -- Remove first column(Future cost) of hourly objcop
                    immediate_cost = (objcop:remove_agent(1) / discount_rate):aggregate_agents(BY_SUM(), "Immediate cost"):aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):to_list()[1];
                else
                    -- Select total cost and future cost agents
                    total_cost_age = objcop:select_agent(1):aggregate_scenarios(BY_AVERAGE());
                    future_cost_age = objcop:select_agent(-1):aggregate_scenarios(BY_AVERAGE());

                    -- Calculating total cost as sum of immediate costs per stage
                    immediate_cost = ((total_cost_age - future_cost_age) / discount_rate):aggregate_stages(BY_SUM()):rename_agent("Total cost"):to_list()[1];
                end

                -- Take expression and use it as mask for "final_sim_cost"
                conv_age_aux = conv_age:select_agent(1):rename_agent("Final simulation");
                final_sim_cost = conv_age_aux:fill(immediate_cost);
            end

            local chart = Chart("Convergence");
            chart:add_area_range(conv_age:select_agents({ 2 }), conv_age:select_agents({ 4 }), { color = { "#ACD98D", "#ACD98D" }, xUnit = "Iteration", xAllowDecimals = false }); -- Confidence interval
            chart:add_line(conv_age:select_agents({ 1 }), { color = { "#3CB7CC" }, xAllowDecimals = false }); -- Zinf
            chart:add_line(conv_age:select_agents({ 3 }), { color = { "#32A251" }, xAllowDecimals = false }); -- Zsup
            if (graph_sim_cost) then
                chart:add_line(final_sim_cost, { color = { "#D37295" }, xAllowDecimals = false }); -- Final simulation cost
            end
            tab:push(chart);

            chart = Chart("New cuts per iteration");
            
            chart:add_column(cuts_age:select_agents({ 1 }), { xUnit = "Iteration", xAllowDecimals = false }); -- Optimality
            
            -- For feas. cuts, plot only if at least one cut
            if is_greater_than_zero(cuts_age:select_agents({ 2 })) then
                chart:add_column(cuts_age:select_agents({ 2 }), { xUnit = "Iteration", xAllowDecimals = false }); -- Feasibility
            end
            tab:push(chart);

            chart = Chart("Forward and backward execution times");
            chart:add_line(time_age:rename_agents({"Forward","Backward"}), { xUnit = "Iteration", xAllowDecimals = false }); -- Forw. and Back. times
            tab:push(chart);
                    
            -- Convergence map
            create_conv_map_graph(tab, convm_file_list[i], col_struct, 1);
        end
    end

    return tab;
end

-----------------------------------------------------------------------------------------------
-- Simulation objetive function cost terms report function
-----------------------------------------------------------------------------------------------

local function create_sim_report(col_struct)
    local tab = Tab("Simulation");

    local costs;
    local costs_agg;
    local exe_times;
    
    local cost_chart = Chart("Breakdown of total operating costs");
    local exet_chart = Chart("Execution times");

    local objcop = require("sddp/costs");
    local discount_rate = require("sddp/discount_rate");

    if studies > 1 then
        for i = 1, studies do
            costs = ifelse(objcop(i):ge(0), objcop(i), 0) / discount_rate(i);

            -- sddp_dashboard_cost_tot
            costs_agg = costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):remove_zeros();
            cost_chart:add_categories(costs_agg, col_struct.case_dir_list[i]);
            
            -- Execution times (sim, post-processing and total time)
            exe_times = col_struct.generic[i]:load("sddptimes");
            exet_chart:add_categories(exe_times, col_struct.case_dir_list[i]);
        end
    else
        costs = ifelse(objcop():ge(0), objcop(), 0) / discount_rate();
        costs_agg = costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):remove_zeros();

        if is_greater_than_zero(costs_agg) then
            cost_chart:add_pie(costs_agg);
        end
        
        -- Execution times (sim, post-processing and total time)
        exe_times = col_struct.generic[1]:load("sddptimes");
        exet_chart:add_column(exe_times);
    end

    if #cost_chart > 0 then
        tab:push(cost_chart);
    end
    
    if #exet_chart > 0 then
        tab:push(exet_chart);
    end
    
    -- Heatmap after the pizza graph in dashboard
    if studies == 1 then
        -- Creating simulation heatmap graphics
        if col_struct.study[1]:get_parameter("SIMH", -1) == 2 then
            create_hourly_sol_status_graph(tab, col_struct, 1);
        end
        
        -- Execution times per scenario
        if col_struct.study[1]:get_parameter("SCEN", 0) == 0 then -- SDDP scenarios does not have execution times per scenario
            create_exe_timer_per_scen(tab, col_struct, 1);
        end
        
        create_penalty_proportion_graph(tab, col_struct, 1);
    end
    
    return tab;
end

-----------------------------------------------------------------------------------------------
-- Simulation costs report function
-----------------------------------------------------------------------------------------------

local function create_costs_and_revs(col_struct)
    local tab = Tab("Costs & revenues");

    local chart = Chart("Dispersion of operating costs per stage");
    local chart_avg = Chart("Average operating costs per stage");

    for i = 1, studies do
        local objcop = require("sddp/costs");
        local discount_rate = require("sddp/discount_rate");
        local costs = ifelse(objcop(i):ge(0), objcop(i), 0) / discount_rate(i);

        -- sddp_dashboard_cost_tot
        costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM());
        if studies == 1 then
            costs:remove_zeros():save("sddp_dashboard_cost_tot", { csv = true });
        end

        local disp = concatenate(costs:aggregate_agents(BY_SUM(), "P10"):aggregate_scenarios(BY_PERCENTILE(10)), costs:aggregate_agents(BY_SUM(), "Average"):aggregate_scenarios(BY_AVERAGE()), costs:aggregate_agents(BY_SUM(), "P90"):aggregate_scenarios(BY_PERCENTILE(90)));

        if studies > 1 then
            if is_greater_than_zero(disp) then
                chart:add_area_range(disp:select_agent(1):add_prefix(col_struct.case_dir_list[i] .. " - "), disp:select_agent(3), { xUnit="Stage", color = light_global_color[i] }); -- Confidence interval
                chart:add_line(disp:select_agent(2):add_prefix(col_struct.case_dir_list[i] .. " - "),{xUnit="Stage"}); -- Average
            end
        else
            if is_greater_than_zero(disp) then
                chart:add_area_range(disp:select_agent(1), disp:select_agent(3), { xUnit="Stage", color = { "#EA6B73", "#EA6B73" } }); -- Confidence interval
                chart:add_line(disp:select_agent(2), { xUnit="Stage", color = { "#F02720" } }); -- Average
            end
        end

        -- sddp_dashboard_cost_avg
        local costs_avg = costs:aggregate_scenarios(BY_AVERAGE()):remove_zeros();
        if studies == 1 and is_greater_than_zero(costs_avg) then
            chart_avg:add_column_stacking(costs_avg,{xUnit="Stage"});
        end
    end

    if #chart_avg > 0 then
        tab:push(chart_avg);
    end
    
    if #chart > 0 then
        tab:push(chart);
    end

    return tab;
end

-----------------------------------------------------------------------------------------------
-- Marginal cost report function
-----------------------------------------------------------------------------------------------

local function create_marg_costs(col_struct)
    local tab = Tab("Marginal costs");

    local cmg = {};
    local cmg_aggsum;
    local cmg_aggyear;

    local sys = {};
    for i = 1, studies do
        sys[i] = col_struct.system[i];
    end

    for i = 1, studies do
        cmg[i] = sys[i]:load("cmgdem");
    end

    -- Marginal cost aggregated by average
    local chart = Chart("Annual marginal cost by sub-system");
    if studies > 1 then
        for i = 1, studies do
            cmg_aggyear = cmg[i]:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM);

            -- Add marginal costs outputs
            chart:add_categories(cmg_aggyear, col_struct.case_dir_list[i], { xUnit="Year" }); -- Annual Marg. cost     
        end
    else
        cmg_aggyear = cmg[1]:aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR):aggregate_scenarios(BY_AVERAGE());
        chart:add_column(cmg_aggyear, { xUnit="Year" });
    end
    tab:push(chart);

    if studies > 1 then
        tab:push("## Average marginal costs per stage per subsystem");
        local agents = cmg[1]:agents();
        for i, agent in ipairs(agents) do
            local chart = Chart(agent);
            for j = 1, studies do
                cmg_aggsum = cmg[j]:select_agent(agent):rename_agent(col_struct.case_dir_list[j]):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE())
                chart:add_line(cmg_aggsum,{xUnit="Stage"}); -- Average marg. cost per stage
            end
            tab:push(chart);
        end
    else
        local chart = Chart("Average marginal costs per stage per subsystem");
        cmg_aggsum = cmg[1]:aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE());
        chart:add_column(cmg_aggsum,{xUnit="Stage"});
        tab:push(chart);
    end

    return tab;
end

-----------------------------------------------------------------------------------------------
-- Generation report function
-----------------------------------------------------------------------------------------------

local function create_gen_report(col_struct)
    local tab = Tab("Generation");

    -- Color preferences
    local color_hydro = '#4E79A7';
    local color_thermal = '#F28E2B';
    local color_renw_other = '#BAB0AC';
    local color_wind = '#8CD17D';
    local color_solar = '#F1CE63';
    local color_small_hydro = '#A0CBE8';
    local color_battery = '#B07AA1';
    local color_deficit = '#000000';
    local color_pinj = '#BAB0AC';

    local total_hydro_gen;
    local total_batt_gen;
    local total_deficit;
    local total_pot_inj;
    local total_other_renw_gen;
    local total_wind_gen;
    local total_solar_gen;
    local total_small_hydro_gen;
    local total_thermal_gen;

    local total_hydro_gen_age;
    local total_batt_gen_age;
    local total_deficit_age;
    local total_pot_inj_age;
    local total_other_renw_gen_age;
    local total_wind_gen_age;
    local total_solar_gen_age;
    local total_small_hydro_gen_age;
    local total_thermal_gen_age;
    
    local hydro_agent_name;
    local thermal_agent_name;
    local battery_agent_name;
    local deficit_agent_name;
    local pinj_agent_name;   
    local renw_ot_agent_name;     
    local renw_wind_agent_name;   
    local renw_solar_agent_name;  
    local renw_shydro_agent_name; 
    
    local gerter = {};
    local gerhid = {};
    local gergnd = {};
    local wind = {};
    local solar = {};
    local gerbat = {};
    local potinj = {};
    local defcit = {};

    -- Loading generations files
    for i = 1, studies do
        gerter[i] = col_struct.thermal[i]:load("gerter");
        gerhid[i] = col_struct.hydro[i]:load("gerhid");
        gergnd[i] = col_struct.renewable[i]:load("gergnd");
        gerbat[i] = col_struct.battery[i]:load("gerbat"):convert("GWh"); -- Explicitly converting to GWh
        potinj[i] = col_struct.power_injection[i]:load("powinj");
        defcit[i] = col_struct.system[i]:load("defcit");
    end

    if studies > 1 then
        chart_tot_gerhid     = Chart("Total Hydro");
        chart_tot_sml_hid    = Chart("Total Small Hydro");
        chart_tot_gerter     = Chart("Total Thermal");
        chart_tot_other_renw = Chart("Total Renewable - Other tech.");
        chart_tot_renw_wind  = Chart("Total Renewable - Wind");
        chart_tot_renw_solar = Chart("Total Renewable - Solar");
        chart_tot_renw_shyd  = Chart("Total Renewable - Small hydro");
        chart_tot_gerbat     = Chart("Total Battery");
        chart_tot_potinj     = Chart("Total Power Injection");
        chart_tot_defcit     = Chart("Total Deficit");
    else
        chart = Chart("Total generation");
    end

    -- Total generation report
    for i = 1, studies do

        if studies > 1 then
            total_hydro_gen_age       = col_struct.case_dir_list[i] .. " - ";
            total_batt_gen_age        = col_struct.case_dir_list[i] .. " - ";
            total_deficit_age         = col_struct.case_dir_list[i] .. " - ";
            total_pot_inj_age         = col_struct.case_dir_list[i] .. " - ";
            total_other_renw_gen_age  = col_struct.case_dir_list[i] .. " - ";
            total_wind_gen_age        = col_struct.case_dir_list[i] .. " - ";
            total_solar_gen_age       = col_struct.case_dir_list[i] .. " - ";
            total_small_hydro_gen_age = col_struct.case_dir_list[i] .. " - ";
            total_thermal_gen_age     = col_struct.case_dir_list[i] .. " - ";
        else 
            total_hydro_gen_age       = "";
            total_batt_gen_age        = "";
            total_deficit_age         = "";
            total_pot_inj_age         = "";
            total_other_renw_gen_age  = "";
            total_wind_gen_age        = "";
            total_solar_gen_age       = "";
            total_small_hydro_gen_age = "";
            total_thermal_gen_age     = "";
        end

        total_hydro_gen_age       = total_hydro_gen_age       .. "Total Hydro";
        total_batt_gen_age        = total_batt_gen_age        .. "Total Battery";
        total_deficit_age         = total_deficit_age         .. "Total Deficit";
        total_pot_inj_age         = total_pot_inj_age         .. "Total P. Inj.";
        total_other_renw_gen_age  = total_other_renw_gen_age  .. "Total Renewable - Other tech.";
        total_wind_gen_age        = total_wind_gen_age        .. "Total Renewable - Wind";
        total_solar_gen_age       = total_solar_gen_age       .. "Total Renewable - Solar";
        total_small_hydro_gen_age = total_small_hydro_gen_age .. "Total Renewable - Small hydro";
        total_thermal_gen_age     = total_thermal_gen_age     .. "Total Thermal";

        -- Data processing
        total_hydro_gen = gerhid[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), total_hydro_gen_age);
        total_batt_gen  = gerbat[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), total_batt_gen_age);
        total_deficit   = defcit[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), total_deficit_age);
        total_pot_inj   = potinj[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), total_pot_inj_age);

        -- Renewable generation is broken into 3 types
        total_other_renw_gen  = gergnd[i]:select_agents(col_struct.renewable[i].tech_type:ne(1) &
                                                        col_struct.renewable[i].tech_type:ne(2) & 
                                                        col_struct.renewable[i].tech_type:ne(4));
                                                        
        total_other_renw_gen  = total_other_renw_gen:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), total_other_renw_gen_age);
        total_wind_gen        = gergnd[i]:select_agents(col_struct.renewable[i].tech_type:eq(1)):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), total_wind_gen_age);
        total_solar_gen       = gergnd[i]:select_agents(col_struct.renewable[i].tech_type:eq(2)):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), total_solar_gen_age);
        total_small_hydro_gen = gergnd[i]:select_agents(col_struct.renewable[i].tech_type:eq(4)):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), total_small_hydro_gen_age);

        total_thermal_gen = gerter[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), total_thermal_gen_age);

        if studies > 1 then
            if total_hydro_gen:loaded() then
                chart_tot_gerhid:add_column(total_hydro_gen, { xUnit="Stage"});
            end
            if total_thermal_gen:loaded() then
                chart_tot_gerter:add_column(total_thermal_gen, { xUnit="Stage"});
            end
            if total_other_renw_gen:loaded() then
                chart_tot_other_renw:add_column(total_other_renw_gen, { xUnit="Stage"});
            end
            if total_wind_gen:loaded() then
                chart_tot_renw_wind:add_column(total_wind_gen, { xUnit="Stage"});
            end
            if total_solar_gen:loaded() then
                chart_tot_renw_solar:add_column(total_solar_gen, { xUnit="Stage"});
            end
            if total_small_hydro_gen:loaded() then
                chart_tot_renw_shyd:add_column(total_small_hydro_gen, { xUnit="Stage"});
            end
            if total_batt_gen:loaded() then
                chart_tot_gerbat:add_column(total_batt_gen, { xUnit="Stage"});
            end
            if total_pot_inj:loaded() then
                chart_tot_potinj:add_column(total_pot_inj, { xUnit="Stage"});
            end
            if total_deficit:loaded() then
                chart_tot_defcit:add_column(total_deficit, { xUnit="Stage"});
            end
        else
            chart:add_area_stacking(total_thermal_gen    , { xUnit="Stage", color = { color_thermal     } });
            chart:add_area_stacking(total_hydro_gen      , { xUnit="Stage", color = { color_hydro       } });
            chart:add_area_stacking(total_wind_gen       , { xUnit="Stage", color = { color_wind        } });
            chart:add_area_stacking(total_solar_gen      , { xUnit="Stage", color = { color_solar       } });
            chart:add_area_stacking(total_small_hydro_gen, { xUnit="Stage", color = { color_small_hydro } });
            chart:add_area_stacking(total_other_renw_gen , { xUnit="Stage", color = { color_renw_other  } });
            chart:add_area_stacking(total_batt_gen       , { xUnit="Stage", color = { color_battery     } });
            chart:add_area_stacking(total_pot_inj        , { xUnit="Stage", color = { color_pinj        } });
            chart:add_area_stacking(total_deficit        , { xUnit="Stage", color = { color_deficit     } });
        end
    end

    if studies > 1 then
        if #chart_tot_gerhid > 0 then
            tab:push(chart_tot_gerhid);
        end
        if #chart_tot_gerter > 0 then
            tab:push(chart_tot_gerter);
        end
        if #chart_tot_other_renw > 0 then
            tab:push(chart_tot_other_renw);
        end
        if #chart_tot_renw_wind > 0 then
            tab:push(chart_tot_renw_wind);
        end
        if #chart_tot_renw_solar > 0 then
            tab:push(chart_tot_renw_solar);
        end
        if #chart_tot_renw_shyd > 0 then
            tab:push(chart_tot_renw_shyd);
        end
        if #chart_tot_gerbat > 0 then
            tab:push(chart_tot_gerbat);
        end
        if #chart_tot_potinj > 0 then
            tab:push(chart_tot_potinj);
        end
        if #chart_tot_defcit > 0 then
            tab:push(chart_tot_defcit);
        end
    else
        tab:push(chart);
    end

    -- Name initialization
    hydro_agent_name   = "Total Hydro";
    thermal_agent_name = "Total Thermal";
    battery_agent_name = "Total Battery";
    deficit_agent_name = "Total Deficit";
    pinj_agent_name    = "Total P. Inj.";
    
    renw_ot_agent_name     = "Total Renewable - Other tech.";
    renw_wind_agent_name   = "Total Renewable - Wind";
    renw_solar_agent_name  = "Total Renewable - Solar";
    renw_shydro_agent_name = "Total Renewable - Small hydro";
        
    -- Generation per system report
    local agents = col_struct.generic[1]:load("cmgdem"):agents();
    for i, agent in ipairs(agents) do
        chart_tot_gerhid     = Chart("Total Hydro");
        chart_tot_gerter     = Chart("Total Thermal");
        chart_tot_renw_other = Chart("Total Renewable - Other tech.");
        chart_tot_renw_wind  = Chart("Total Renewable - Wind");
        chart_tot_renw_solar = Chart("Total Renewable - Solar");
        chart_tot_renw_shyd  = Chart("Total Renewable - Small hydro");
        chart_tot_gerbat     = Chart("Total Battery");
        chart_tot_potinj     = Chart("Total Power Injection");
        chart_tot_defcit     = Chart("Total Deficit");
            
        for i = 1, studies do
                
            if studies > 1 then
                hydro_agent_name   = col_struct.case_dir_list[i] .. " - " .. hydro_agent_name;
                thermal_agent_name = col_struct.case_dir_list[i] .. " - " .. thermal_agent_name;
                battery_agent_name = col_struct.case_dir_list[i] .. " - " .. battery_agent_name;
                deficit_agent_name = col_struct.case_dir_list[i] .. " - " .. deficit_agent_name;
                pinj_agent_name    = col_struct.case_dir_list[i] .. " - " .. pinj_agent_name;
                
                renw_ot_agent_name     = col_struct.case_dir_list[i] .. " - " .. renw_ot_agent_name;
                renw_wind_agent_name   = col_struct.case_dir_list[i] .. " - " .. renw_wind_agent_name;
                renw_solar_agent_name  = col_struct.case_dir_list[i] .. " - " .. renw_solar_agent_name;
                renw_shydro_agent_name = col_struct.case_dir_list[i] .. " - " .. renw_shydro_agent_name;               
            end
            
            -- Data processing
            total_hydro_gen = gerhid[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(hydro_agent_name);
            total_batt_gen  = gerbat[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(battery_agent_name);
            total_deficit   = defcit[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(deficit_agent_name);
            total_pot_inj   = potinj[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(pinj_agent_name);
 
            -- Renewable generation is broken into 3 types
            total_other_renw_gen = ifelse(col_struct.renewable[i].tech_type:ne(1) & 
                                          col_struct.renewable[i].tech_type:ne(2) & 
                                          col_struct.renewable[i].tech_type:ne(4),
                                          gergnd[i],
                                          0);
            total_wind_gen = ifelse(col_struct.renewable[i].tech_type:eq(1),
                                          gergnd[i],
                                          0);
            total_solar_gen = ifelse(col_struct.renewable[i].tech_type:eq(2),
                                          gergnd[i],
                                          0);                                          
            total_small_hydro_gen = ifelse(col_struct.renewable[i].tech_type:eq(4),
                                          gergnd[i],
                                          0);            
                                          
            total_other_renw_gen  = total_other_renw_gen:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(renw_ot_agent_name);
            total_wind_gen        = total_wind_gen:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(renw_wind_agent_name);
            total_solar_gen       = total_solar_gen:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(renw_solar_agent_name);
            total_small_hydro_gen = total_small_hydro_gen:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(renw_shydro_agent_name);

            total_thermal_gen = gerter[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(thermal_agent_name);

            if total_hydro_gen:loaded() then
                chart_tot_gerhid:add_column(total_hydro_gen, { xUnit="Stage"});
            end
            if total_thermal_gen:loaded() then
                chart_tot_gerter:add_column(total_thermal_gen, { xUnit="Stage"});
            end
            if total_other_renw_gen:loaded() then
                chart_tot_renw_other:add_column(total_other_renw_gen, { xUnit="Stage"});
            end
            if total_wind_gen:loaded() then
                chart_tot_renw_wind:add_column(total_wind_gen, { xUnit="Stage"});
            end
            if total_solar_gen:loaded() then
                chart_tot_renw_solar:add_column(total_solar_gen, { xUnit="Stage"});
            end
            if total_small_hydro_gen:loaded() then
                chart_tot_renw_shyd:add_column(total_small_hydro_gen, { xUnit="Stage"});
            end
            if total_batt_gen:loaded() then
                chart_tot_gerbat:add_column(total_batt_gen, { xUnit="Stage"});
            end
            if total_pot_inj:loaded() then
                chart_tot_potinj:add_column(total_pot_inj, { xUnit="Stage"});
            end
            if total_deficit:loaded() then
                chart_tot_defcit:add_column(total_deficit, { xUnit="Stage"});
            end
        end

        tab:push("## Total generation per subsystem - " .. agent);
        if #chart_tot_gerhid > 0 then
            tab:push(chart_tot_gerhid);
        end
        if #chart_tot_gerter > 0 then
            tab:push(chart_tot_gerter);
        end
        if #chart_tot_renw_other > 0 then
            tab:push(chart_tot_renw_other);
        end
        if #chart_tot_renw_wind > 0 then
            tab:push(chart_tot_renw_wind);
        end
        if #chart_tot_renw_solar > 0 then
            tab:push(chart_tot_renw_solar);
        end
        if #chart_tot_renw_shyd > 0 then
            tab:push(chart_tot_renw_shyd);
        end
        if #chart_tot_gerbat > 0 then
            tab:push(chart_tot_gerbat);
        end
        if #chart_tot_potinj > 0 then
            tab:push(chart_tot_potinj);
        end
        if #chart_tot_defcit > 0 then
            tab:push(chart_tot_defcit);
        end
    end

    return tab;
end

local function create_risk_report(col_struct)
    local tab = Tab("Deficit risk");
    local chart = Chart("Deficit risk by sub-system");
    local chart = Chart("Deficit risk by sub-system");

    if studies > 1 then
        for i = 1, studies do
            risk_file = col_struct.system[i]:load("sddprisk"):aggregate_agents(BY_AVERAGE(), Collection.SYSTEM);

            -- Add marginal costs outputs
            chart:add_categories(risk_file, col_struct.case_dir_list[i]); -- Annual Marg. cost     
        end
    else
        risk_file = col_struct.system[1]:load("sddprisk");
        chart:add_column(risk_file);
    end

    if #chart > 0 then
        tab:push(chart);
    end

    return tab;
end

-----------------------------------------------------------------------------------------------
-- Violation reports data and methods
-----------------------------------------------------------------------------------------------

local viol_report_structs = {
    { name = "defcit"  , title = "Deficit" },
    { name = "nedefc"  , title = "Deficit associated to non-electrical gas demand" },
    { name = "defbus"  , title = "Deficit per bus (% of load)" },
    { name = "gncivio" , title = "General interpolation constraint violation" },
    { name = "gncvio"  , title = "General constraint: linear" },
    { name = "vrestg"  , title = "Generation constraint violation" },
    { name = "excbus"  , title = "Generation excess per AC bus" },
    { name = "excsis"  , title = "Generation excess per system" },
    { name = "vvaler"  , title = "Alert storage violation" },
    { name = "vioguide", title = "Guide curve violation per hydro reservoir" },
    { name = "vriego"  , title = "Hydro: irrigation" },
    { name = "vmxost"  , title = "Hydro: maximum operative storage" },
    { name = "vimxsp"  , title = "Hydro: maximum spillage" },
    { name = "vdefmx"  , title = "Hydro: maximum total outflow" },
    { name = "vvolmn"  , title = "Hydro: minimum storage" },
    { name = "vdefmn"  , title = "Hydro: minimum total outflow" },
    { name = "vturmn"  , title = "Hydro: minimum turbining outflow" },
    { name = "vimnsp"  , title = "Hydro: mininum spillage" },
    { name = "rampvio" , title = "Hydro: outflow ramp" },
    { name = "vreseg"  , title = "Reserve: joint requirement" },
    { name = "vsarhd"  , title = "RAS target storage violation %" },
    { name = "vsarhden", title = "RAS target storage violation GWh" },
    { name = "viocar"  , title = "Risk Aversion Curve" },
    { name = "vgmint"  , title = "Thermal: minimum generation" },
    { name = "vgmntt"  , title = "NE" },
    { name = "vioemiq" , title = "Emission budget violation" },
    { name = "vsecset" , title = "Reservoir set: security energy constraint" },
    { name = "valeset" , title = "Reservoir set: alert energy constraint" },
    { name = "vespset" , title = "Reservoir set: flood control energy constraint" },
    { name = "fcoffvio", title = "Fuel contract minimum offtake rate violation" },
    { name = "vflmnww" , title = "Minimum hydro bypass flow violation" },
    { name = "vflmxww" , title = "Maximum hydro bypass flow violation" },
    { name = "finjvio" , title = "NE" }
}

local function create_viol_report(tab, col_struct, viol_struct, suffix)
    local file_name;
    local viol_file;

    if studies > 1 then
        for i, struct in ipairs(viol_struct) do

            file_name = "sddp_dashboard_viol_" .. suffix .. "_" .. struct.name;
            viol_file = col_struct.generic[1]:load(file_name);

            -- Assuming agents in reference case(1st case) are the same as the ones in the others
            local agents = viol_file:agents();
            for j, agent in ipairs(agents) do
                local chart = Chart(struct.title .. " - " .. agent);
                for k = 1, studies do
                    viol_file = col_struct.generic[k]:load(file_name):select_agent(agent):rename_agent(case_dir_list[k]);
                    if viol_file:loaded() then
                        chart:add_column_stacking(viol_file, {xUnit="Stage"});
                    end
                end
                tab:push(chart);
            end
        end
    else
        for i, struct in ipairs(viol_struct) do
            file_name = "sddp_dashboard_viol_" .. suffix .. "_" .. struct.name;
            viol_file = col_struct.generic[1]:load(file_name);
            if viol_file:loaded() then
                local chart = Chart(struct.title);
                chart:add_column_stacking(viol_file, {xUnit="Stage"});
                tab:push(chart); 
            end
        end
    end
end

local function create_viol_report_from_list(tab, col_struct, viol_list, viol_struct, suffix)
    local viol_name;
    local tokens = {};

    for i, file in ipairs(viol_list) do
        -- Look for file title in violation structure
        for j, struct in ipairs(viol_struct) do
            viol_name = "sddp_dashboard_viol_" .. suffix .. "_" .. struct.name;
            if file == viol_name then
                viol_file = col_struct.generic[1]:load(file);
                if viol_file:loaded() then
                    local chart = Chart(struct.title);
                    chart:add_column_stacking(viol_file, {xUnit="Stage"});
                    tab:push(chart); 
                end
            end
        end
    end
end

-- Collection arrays struct
local col_struct = {
    battery         = {},
    bus             = {},
    circuit         = {},
    generic         = {},
    hydro           = {},
    interconnection = {},
    power_injection = {},
    renewable       = {},
    study           = {},
    system          = {},
    thermal         = {},
    case_dir_list   = {}  -- Cases' directory names
};

-- Model info structure
local info_struct = {};

load_collections(col_struct);
local info_existence_log = load_model_info(col_struct, info_struct);

-- If at least one case does not have the .info file, info report is not displayed
local create_info_report = true;
for i = 1, #info_existence_log do
    if not info_existence_log[i] then
        create_info_report = false;
        break;
    end
end

-----------------------------------------------------------------------------------------------
-- Dashboard tab configuration
-----------------------------------------------------------------------------------------------

local dashboard = Dashboard();

-- Dashboard name configuration
local dashboard_name = "SDDP";
if #info_struct > 0 and not (info_struct[1].dash_name == "---") then
    dashboard_name = info_struct[1].dash_name;
end

if studies > 1 then
    dashboard_name = dashboard_name .. "-compare";
end

----------------
-- Infeasibility
----------------
local tab_inf = Tab("Infeasibility report");
tab_inf:set_icon("alert-triangle");

-- Infeasibility report
if create_info_report then
    local has_inf = {};
    if studies == 1 then
        if info_struct[1].status > 0 then
            dash_infeasibility(tab_inf,info_struct[1].infrep .. ".out",1);
            push_tab_to_tab(tab_inf,dashboard);                                     -- Infeasibility
            push_tab_to_tab(create_tab_summary(col_struct, info_struct),dashboard); -- Case information summary
            dashboard:save(dashboard_name);
            
            return
        end
    else
        for i = 1, studies do
            if info_struct[i].status > 0 then
                table.insert(has_inf, i)
            end
        end
        
        if #has_inf > 0 then
            for i = 1, #has_inf do
                j = has_inf[i]; -- Pointer to case
                local tab_inf_sub = Tab(col_struct.case_dir_list[j]);
                dash_infeasibility(tab_inf_sub,info_struct[j].infrep .. ".out",j);
                
                tab_inf:push(tab_inf_sub);
                
                -- Remove from vectors
                remove_case_info(col_struct, info_struct, j);
            end
            
            studies = studies - #has_inf;
                
            -- If only one study was successful, comparison does not exist
            if studies == 1 then
                push_tab_to_tab(tab_inf,dashboard);
                push_tab_to_tab(create_tab_summary(col_struct, info_struct),dashboard); -- Case information summary
                dashboard:save(dashboard_name);
                return
            end
        end
        
    end
    
    -- If infeasibilities are present, dashboard
    if #has_inf > 0 then
        push_tab_to_tab(tab_inf,dashboard);
    end
end

-------------------
-- Solution quality
-------------------

local tab_solution_quality = Tab("Solution quality");
tab_solution_quality:set_collapsed(false);
tab_solution_quality:set_disabled();
tab_solution_quality:set_icon("alert-triangle");

local create_policy_report = true;
local pol_file_name = "sddppol.csv"
for i = 1, studies do
    if not col_struct.study[i]:get_parameter("SCEN", 0) == 0 or 
       not col_struct.generic[i]:file_exists(pol_file_name) then 
        create_policy_report = false;
    end 
end

-- Policy report
if create_policy_report then -- SDDP scenarios does not have policy phase
    push_tab_to_tab(create_pol_report(col_struct),tab_solution_quality);
else
    info("file " .. pol_file_name .. " does not exist. Policy report will not be displayed.");
end

-- Simulation report
push_tab_to_tab(create_sim_report(col_struct),tab_solution_quality);

push_tab_to_tab(tab_solution_quality, dashboard);

------------
-- Violation
------------

-- Violation tabs
local tab_violations = Tab("Violations");
local tab_viol_avg   = Tab("Average");
local tab_viol_max   = Tab("Maximum");

tab_violations:set_collapsed(true);
tab_violations:set_disabled();
tab_violations:set_icon("siren");

if studies == 1 then
    local viol_files;
    local viol_list = {};
    
    local viol_file_name = "sddp_viol.out";
    
    -- Load list of violations
    viol_files = col_struct.generic[1]:load_table_without_header(viol_file_name);
    
    -- Check if violation list file is present
    if #viol_files > 0 then
        -- Create list of violation outputs to be considered
        for lin = 1, #viol_files do
            file = viol_files[lin][1];
            table.insert(viol_list,file);
        end
        
        create_viol_report_from_list(tab_viol_avg, col_struct, viol_list, viol_report_structs, "avg");
        create_viol_report_from_list(tab_viol_max, col_struct, viol_list, viol_report_structs, "max");
    else
        create_viol_report(tab_viol_avg, col_struct, viol_report_structs, "avg");
        create_viol_report(tab_viol_max, col_struct, viol_report_structs, "max");
    end 
    
    push_tab_to_tab(tab_viol_avg,tab_violations);
    push_tab_to_tab(tab_viol_max,tab_violations);
    
    push_tab_to_tab(tab_violations,dashboard);
end

----------
-- Results
----------

local tab_results = Tab("Results");
tab_results:set_collapsed(true);
tab_results:set_disabled();
tab_results:set_icon("line-chart");

push_tab_to_tab(create_costs_and_revs(col_struct),tab_results);
push_tab_to_tab(create_marg_costs(col_struct)    ,tab_results);
push_tab_to_tab(create_gen_report(col_struct)    ,tab_results);
push_tab_to_tab(create_risk_report(col_struct)   ,tab_results);
push_tab_to_tab(create_inflow_energy(col_struct) ,tab_results);

push_tab_to_tab(tab_results,dashboard);

---------------------------
-- Case information summary
---------------------------
if create_info_report then
    push_tab_to_tab(create_tab_summary(col_struct, info_struct),dashboard);
end

dashboard:save(dashboard_name);
