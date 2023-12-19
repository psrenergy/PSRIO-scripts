-- Macros
EXECUTION_MODE_OPERATION     = 0
EXECUTION_MODE_EXPANSION_IT  = 1
EXECUTION_MODE_EXPANSION_SIM = 2
LANGUAGE = "en"

REP_DIFF_TOL = 0.05 -- 10%

-- Setting global colors
main_global_color = { "#4E79A7", "#F28E2B", "#8CD17D", "#B6992D", "#E15759", "#76B7B2", "#FF9DA7", "#D7B5A6", "#B07AA1", "#59A14F", "#F1CE63", "#A0CBE8", "#E15759" };
light_global_color = { "#B7C9DD", "#FAD2AA", "#D1EDCB", "#E9DAA4", "#F3BCBD", "#C8E2E0", "#FFD8DC", "#EFE1DB", "#DFCAD9", "#BBDBB7", "#F9EBC1", "#D9EAF6", "#F3BCBD" };

PSR.set_global_colors(main_global_color);

-- Initialization of Advisor class
local advisor = Advisor();

-- Study dimension
studies = PSR.studies();

-----------------------------------------------------------------------------------------------
--Usefull fuctions
-----------------------------------------------------------------------------------------------

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function subrange(t, first, last)
    return table.move(t, first, last, 1, {})
end
-----------------------------------------------------------------------------------------------
-- Overloads
-----------------------------------------------------------------------------------------------

-- Temporary solution to SDDP remap executions (including typical days)
function Expression.aggregate_blocks_by_duracipu(self,i)
    local generic = Generic(i or 1);
    local duracipu = generic:load("duracipu");
    return (self * duracipu):aggregate_blocks(BY_SUM());
end

-----------------------------------------------------------------------------------------------
-- Auxiliary functions
-----------------------------------------------------------------------------------------------

function fix_conv_map_file(file_name, col_struct, study_index)

    -- Local
    local convertion_status = -1; -- -1: unsuccessful, 0: successful
    local header            = {};
    local indexes           = {};
    local input_lines       = {};
    local output_lines      = {};
    local stage_indexes     = {};
    local scenario_indexes  = {};
    
    local file_name_csv = file_name .. ".csv";
    local reader = col_struct.generic[study_index]:create_reader(file_name_csv);
    
    if(not reader:is_open()) then
        return convertion_status;
    end
   
    -- Read graph file header (first 4 lines)
    table.insert(header,reader:get_line()); 
    table.insert(header,reader:get_line());
    table.insert(header,reader:get_line());
    table.insert(header,reader:get_line());
    
    -- Iterate over remaining lines
    local counter = 0;
    while reader:good() do
        counter = counter + 1;
        table.insert(indexes, counter);
        
        local row = reader:get_line();
        table.insert(input_lines,row);
        
        -- Get stage and scenario indexes (1st and 2nd columns)
        columns          = string.gmatch(row, '([^,]+),');
        col1 = columns();
        col2 = columns();
        
        if col1 == nil or col2 == nil then
            break;
        end
        
        table.insert(stage_indexes   ,tonumber(col1));
        table.insert(scenario_indexes,tonumber(col2));
    end
    reader:close();
    
    -- Apply sorting procedure using stage and scenario indexes as criteria
    table.sort(indexes, function(a,b)
                            if stage_indexes[a] ~= nil and scenario_indexes[b] ~= nil then
                                if stage_indexes[a] == stage_indexes[b] then
                                    return scenario_indexes[a] < scenario_indexes[b];
                                elseif stage_indexes[a] < stage_indexes[b] then
                                    return true;
                                else
                                    return false;
                                end
                            end
                        end);
    
    -- Load sorted lines into array
    for _,i in ipairs(indexes) do
        table.insert(output_lines,input_lines[i]);
    end
    
    -- Write fixed file
    local writer = col_struct.generic[study_index]:create_writer(file_name_csv);
    
    local is_open = writer:is_open();
    
    if is_open then
        for iheader = 1, #header do
            writer:write_line(header[iheader]);
        end
        for iline = 1, #output_lines do
            writer:write_line(output_lines[iline]);
        end
        writer:close();
        
        convertion_status = 0;
    end

    return convertion_status;
end


function push_tab_to_tab(tab_from, tab_to)
    if #tab_from > 0 then
        tab_to:push(tab_from);
    end
end

function is_greater_than_zero(output)

    if not output:loaded() then
        return false;
    end 
    
    local x = output:abs():aggregate_agents(BY_SUM(), "CheckZeros"):aggregate_stages(BY_SUM()):to_list();
    if x[1] > 0.0 then
        return true;
    else
        return false;
    end
end

function load_info_file(file_name,case_index)

    -- Initialize struct
    info_struct = {{model = ""}, {user = ""}, {version = ""}, {hash = ""}, {model = ""}, {status = ""}, {infrep = ""}, {dash_name = ""}, {cloud = ""}, {exe_mode=0}};

    local toml = Generic(case_index):load_toml(file_name);
    model      = toml:get_string("model", "-");
    user       = toml:get_string("user", "-");
    version    = toml:get_string("version", "-");
    hash       = toml:get_string("hash", "-");
    status     = toml:get_string("status", "-");
    infrep     = toml:get_string("infrep", "-");
    dash_name  = toml:get_string("dash", "-");
    cloud      = toml:get_string("cloud", "-");
    exe_mode   = toml:get_integer("mode", 0);

    info_struct.model     = model;
    info_struct.user      = user;
    info_struct.version   = version;
    info_struct.hash      = hash;
    info_struct.status    = tonumber(status);
    info_struct.infrep    = infrep;
    info_struct.dash_name = dash_name;
    info_struct.cloud     = cloud;
    info_struct.exe_mode  = exe_mode;

    return info_struct;
end

function load_model_info(generic_cols, info_struct)
    local file_exists;
    local info_file_name = "SDDP.info";
    local existence_log = {}

    for i = 1, studies do
        -- Verify whether info file exists for each case
        file_exists = generic_cols[i]:file_exists(info_file_name);
        table.insert(existence_log,file_exists);

        -- Loading info files from each case
        if existence_log[i] then
            info_struct[i] = load_info_file(info_file_name,i);
        end
    end

    return existence_log;
end

function load_collections(col_struct, info_struct)
    for i = 1, studies do
        table.insert(col_struct.battery        , Battery(i));
        table.insert(col_struct.bus            , Bus(i));
        table.insert(col_struct.circuit        , Circuit(i));
        table.insert(col_struct.dclink         , DCLink(i));
        table.insert(col_struct.generic        , Generic(i));
        table.insert(col_struct.hydro          , Hydro(i));
        table.insert(col_struct.interconnection, Interconnection(i));
        table.insert(col_struct.power_injection, PowerInjection(i));
        table.insert(col_struct.renewable      , Renewable(i));
        table.insert(col_struct.csp            , ConcentratedSolarPower(i));
        table.insert(col_struct.study          , Study(i));
        table.insert(col_struct.system         , System(i));
        table.insert(col_struct.thermal        , Thermal(i));

        table.insert(col_struct.case_dir_list  , Generic(i):dirname());
    end
end

function remove_case_info(col_struct, info_struct, case_index)
    table.remove(col_struct.battery        , case_index);
    table.remove(col_struct.bus            , case_index);
    table.remove(col_struct.circuit        , case_index);
    table.insert(col_struct.dclink         , case_index);
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

local function load_language()
    local language = Study(1):get_parameter("Idioma", 0);

    if language == 1 then
        return "es";
    elseif language == 2 then
        return "pt";
    else -- language == 0
        return "en";
    end
end

function Expression.select_stages_of_outputs(self)
    if self:loaded() then
        local index = self:study_index();
        local last_stage = Study(index):stages_without_buffer_years();
        if Study(index):get_parameter("NumeroAnosAdicionaisParm2",-1) == 1 then
            last_stage = Study(index):stages();
        end

        return self:select_stages(1,last_stage)
    end
    return self
end
-----------------------------------------------------------------------------------------------
-- Get language
-----------------------------------------------------------------------------------------------
LANGUAGE = load_language();

-----------------------------------------------------------------------------------------------
-- Infeasibility report function
-----------------------------------------------------------------------------------------------
function dash_infeasibility(tab,file_name,case_index)

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

function get_nonconv_info(col_struct, file_name, nonconv_list, dimension, case_index)
    -- Loading file
    local nonconv = col_struct.generic[case_index]:load_table(file_name);

    for i = 1, #nonconv do
        nonconv_list[i] = trim(nonconv[i]["Type"]);
        dimension[i]    = trim(nonconv[i]["Dimension"]);
    end
end

function create_tab_summary(col_struct, info_struct)

    local tab = Tab(dictionary.tab_info[LANGUAGE]);
    tab:set_icon("info");

    tab:push("# " .. dictionary.case_summary[LANGUAGE]);

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

    local case = dictionary.cell_case[LANGUAGE];
    local directory_name = dictionary.cell_directory_name[LANGUAGE];
    local path_cell = dictionary.cell_path[LANGUAGE];
    local execution_status = dictionary.cell_execution_status[LANGUAGE];
    local model = dictionary.cell_model[LANGUAGE];
    local user = dictionary.cell_user[LANGUAGE];
    local version = dictionary.cell_version[LANGUAGE];
    local ID = dictionary.cell_ID[LANGUAGE];
    local title = dictionary.cell_title[LANGUAGE];

    if studies == 1 then 
        tab:push("| " .. directory_name .. " | " .. path_cell .. " | " .. execution_status .. " |");
        tab:push("|:--------------:|:----:|:----------------:|");
        for i = 1, studies do
            exe_status_str = dictionary.cell_success[LANGUAGE];
            if info_struct[i].status > 0 then
                exe_status_str = "FAIL";
            end

            tab:push("| " .. label[i] .. " | " .. path[i].. " | " .. exe_status_str);
        end
    else
        tab:push("| " .. case .. " | " .. directory_name .. " | " .. path_cell .. " | " .. execution_status .. " |");
        tab:push("|:----:|:--------------:|:----:|:----------------:|");
        for i = 1, studies do
            exe_status_str = dictionary.cell_success[LANGUAGE];
            if info_struct[i].status > 0 then
                exe_status_str = "FAIL";
            end

            tab:push("| " .. i .. " | " .. label[i] .. " | " .. path[i] .. " | " .. exe_status_str);
        end
    end

    tab:push("## " .. dictionary.about_model[LANGUAGE]);
    if studies == 1 then
        tab:push("| " .. model .. " | " .. user .. " | " .. version .. " | " .. ID .. " |");
        tab:push("|:-----:|:----:|:-------:|:----:|");
        for i = 1, studies do
            tab:push("| " .. info_struct[i].model .. " | " .. info_struct[i].user .. " | " .. info_struct[i].version .. " | " .. info_struct[i].hash .. " |");
        end
    else
        tab:push("| " .. case .. " | " .. model .. " | " .. user .. " | " .. version .." | " .. ID .. " |");
        tab:push("|:----:|:-----:|:----:|:-------:|:----:|");
        for i = 1, studies do
            tab:push("| " .. i .. " | " .. info_struct[i].model .. " | " .. info_struct[i].user .. " | " .. info_struct[i].version .. " | " .. info_struct[i].hash .. " |");
        end
    end

    tab:push("## " .. dictionary.case_title[LANGUAGE]);
    if studies == 1 then
        tab:push("| " .. title .. " |");
        tab:push("|:-----------:|");
        for i = 1, studies do
            tab:push("| " .. description[i] .. " | ");
        end
    else
        tab:push("| " .. case .. " | " .. title .. " |");
        tab:push("|:----:|:-----------:|");
        for i = 1, studies do
            tab:push("| " .. i .. " | " .. description[i] .. " | ");
        end
    end

    tab:push("## " .. dictionary.hor_resol_exec[LANGUAGE]);

    local header_string              = "| " .. dictionary.cell_case_parameters[LANGUAGE];
    local lower_header_string        = "|---------------";
    local exe_type_string            = "| " .. dictionary.cell_execution_type[LANGUAGE];
    local case_type_string           = "| " .. dictionary.cell_case_type[LANGUAGE];
    local nstg_string                = "| " .. dictionary.cell_stages[LANGUAGE];
    local ini_year_string            = "| " .. dictionary.cell_ini_year[LANGUAGE];
    local plc_resolution             = "| " .. dictionary.cell_plc_resolution[LANGUAGE];
    local sim_resolution             = "| " .. dictionary.cell_sim_resolution[LANGUAGE];
    local nforw_string               = "| " .. dictionary.cell_fwd_series[LANGUAGE];
    local nback_string               = "| " .. dictionary.cell_bwd_series[LANGUAGE];
    local hrep_string                = "| " .. dictionary.cell_hourly_representation[LANGUAGE];
    local netrep_string              = "| " .. dictionary.cell_network_representation[LANGUAGE];
    local typday_string              = "| " .. dictionary.cell_typicalday_representation[LANGUAGE];
    local loss_representation_string = "| " .. dictionary.cell_loss_representation[LANGUAGE];

    local hrep_val   = {};
    local netrep_val = {};
    local typday_val = {};
    local loss_repr  = {};
    local exe_type   = {};
    local case_type  = {};

    local show_net_data = false;

    for i = 1, studies do
        -- Number of stages
        local number_of_stages = col_struct.study[i]:stages_without_buffer_years();
        if col_struct.study[i]:get_parameter("NumeroAnosAdicionaisParm2",-1) == 1 then
            number_of_stages = col_struct.study[i]:stages();
        end

        -- type of execution
        exe_type[i] = dictionary.cell_policy[LANGUAGE];
        local number_of_blocks = col_struct.study[i]:get_parameter("NumberBlocks", -1);
        local policy_number_of_blocks = number_of_blocks .. " " .. dictionary.cell_blocks[LANGUAGE]
        local resolution_of_simulation = policy_number_of_blocks;
        if col_struct.study[i]:get_parameter("Objetivo", -100) == 2 then
            policy_number_of_blocks = " - ";
            exe_type[i] = dictionary.cell_simulation[LANGUAGE];
        end
        if col_struct.study[i]:get_parameter("Objetivo", -100) == -2 then
            policy_number_of_blocks = " - ";
            exe_type[i] = dictionary.cell_commercial_simulation[LANGUAGE];
        end
        exe_type_string = exe_type_string .. " | " .. exe_type[i];

        if col_struct.study[i]:is_hourly() then
            resolution_of_simulation = dictionary.cell_hourly[LANGUAGE];
        end

        -- type of resolution
        case_type[i] = dictionary.cell_monthly[LANGUAGE];
        if col_struct.study[i]:stage_type() == 1 then
            case_type[i] = dictionary.cell_weekly[LANGUAGE];
        end
        case_type_string = case_type_string .. " | " .. case_type[i];


        header_string = header_string             .. " | " .. col_struct.case_dir_list[i];
        lower_header_string = lower_header_string .. "|-----------";

        nstg_string      = nstg_string      .. " | " .. tostring(number_of_stages);
        ini_year_string  = ini_year_string  .. " | " .. tostring(col_struct.study[i]:initial_year());
        plc_resolution   = plc_resolution   .. " | " .. policy_number_of_blocks;
        sim_resolution   = sim_resolution   .. " | " .. resolution_of_simulation;
        nforw_string     = nforw_string     .. " | " .. tostring(col_struct.study[i]:scenarios());
        nback_string     = nback_string     .. " | " .. tostring(col_struct.study[i]:openings());

        hrep_val[i] = "❌";
        if col_struct.study[i]:get_parameter("SIMH", -1) == 2 then
            hrep_val[i] = "✔️";
        end
        hrep_string = hrep_string .. " | " .. hrep_val[i];

        netrep_val[i] = "❌";
        if col_struct.study[i]:get_parameter("Rede", -1) == 1 then
            netrep_val[i] = "✔️";
            if not show_net_data then
                show_net_data = true
            end
        end
        netrep_string = netrep_string .. " | " .. netrep_val[i];

        typday_val[i] = "❌";
        if col_struct.study[i]:get_parameter("TDAY", -1) == 1 then
            typday_val[i] = "✔️";
        end
        typday_string = typday_string .. " | " .. typday_val[i];

        loss_repr[i] = "❌";
        if col_struct.study[i]:get_parameter("Perdas", -1) == 1 then
            loss_repr[i] = "✔️";
        end
        loss_representation_string = loss_representation_string .. " | " .. loss_repr[i];
    end
    header_string                    = header_string              .. "|";
    lower_header_string              = lower_header_string        .. "|";
    exe_type_string                  = exe_type_string            .. "|";
    case_type_string                 = case_type_string           .. "|";
    nstg_string                      = nstg_string                .. "|";
    ini_year_string                  = ini_year_string            .. "|";
    plc_resolution                   = plc_resolution             .. "|";
    sim_resolution                   = sim_resolution             .. "|";
    nforw_string                     = nforw_string               .. "|";
    nback_string                     = nback_string               .. "|";
    hrep_string                      = hrep_string                .. "|";
    netrep_string                    = netrep_string              .. "|";
    typday_string                    = typday_string              .. "|";
    loss_representation_string       = loss_representation_string .. "|";

    tab:push(header_string);
    tab:push(lower_header_string);
    tab:push(exe_type_string);
    tab:push(case_type_string);
    tab:push(nstg_string);
    tab:push(ini_year_string);
    tab:push(plc_resolution);
    tab:push(sim_resolution);
    tab:push(nforw_string);
    tab:push(nback_string);
    tab:push(hrep_string);
    tab:push(netrep_string);
    tab:push(typday_string);
    tab:push(loss_representation_string);

    tab:push("## " .. dictionary.dimentions[LANGUAGE]);

    local sys_string        = "| " .. dictionary.cell_system[LANGUAGE];
    local battery_string    = "| " .. dictionary.cell_batteries[LANGUAGE];
    local bus_string        = "| " .. dictionary.cell_buses[LANGUAGE];
    local ac_circuit_string = "| " .. dictionary.cell_ac_circuits[LANGUAGE];
    local dc_circuit_string = "| " .. dictionary.cell_dc_circuits[LANGUAGE];
    local interc_string     = "| " .. dictionary.cell_interconnections[LANGUAGE];
    local hydro_string      = "| " .. dictionary.cell_hydro_plants[LANGUAGE];
    local pinj_string       = "| " .. dictionary.cell_power_injections[LANGUAGE];
    local renw_w_string     = "| " .. dictionary.cell_renewable_wind[LANGUAGE];
    local renw_s_string     = "| " .. dictionary.cell_renewable_solar[LANGUAGE];
    local renw_sh_string    = "| " .. dictionary.cell_renewable_small_hydro[LANGUAGE];
    local renw_csp_string   = "| " .. dictionary.cell_renewable_csp[LANGUAGE];
    local renw_oth_string   = "| " .. dictionary.cell_renewable_other[LANGUAGE];
    local thermal_string    = "| " .. dictionary.cell_thermal_plants[LANGUAGE];

    for i = 1, studies do
        sys_string = sys_string             .. " | " .. tostring(#col_struct.system[i]:labels());
        battery_string = battery_string     .. " | " .. tostring(#col_struct.battery[i]:labels());

        if show_net_data then
            bus_string        = bus_string        .. " | " .. tostring(#col_struct.bus[i]:labels());
            ac_circuit_string = ac_circuit_string .. " | " .. tostring(#col_struct.circuit[i]:labels());
            dc_circuit_string = dc_circuit_string .. " | " .. tostring(#col_struct.dclink[i]:labels());
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

        renw_csp = #col_struct.csp[i]:labels();

        renw_sh_string  = renw_sh_string  .. " | " .. tostring(renw_sh);
        renw_w_string   = renw_w_string   .. " | " .. tostring(renw_wind);
        renw_s_string   = renw_s_string   .. " | " .. tostring(renw_solar);
        renw_csp_string = renw_csp_string .. " | " .. tostring(renw_csp);
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
    tab:push(renw_csp_string);
    tab:push(battery_string);
    tab:push(pinj_string);
    if show_net_data then
        tab:push(bus_string);
        tab:push(ac_circuit_string);
        tab:push(dc_circuit_string);
    else
        tab:push(interc_string);
    end

    -- Non-convexities dimension report

    -- Use first case to build non-convexities type column
    local nconv_file_name = "nonconvrep.csv";
    local nonconv_list = {};
    local dimension    = {};
    local nconv_table_strings = {};
    local has_nconv_data = {};

    get_nonconv_info(col_struct,nconv_file_name,nonconv_list,dimension,1);

    has_nconv_data[1] = false;
    if #nonconv_list > 0 then
        has_nconv_data[1] = true;

        for i = 1, #nonconv_list do
            nconv_table_strings[i] = nonconv_list[i] .. "|" .. tostring(dimension[i]);
        end
    end

    if has_nconv_data[1] then
        tab:push("## " .. dictionary.non_convexities[LANGUAGE]);

        header_string       = "| " .. dictionary.cell_non_convexities_type[LANGUAGE];
        lower_header_string = "|-------------------";

        if studies == 1 then
            header_string       = header_string       .. "| " .. dictionary.cell_count[LANGUAGE];
            lower_header_string = lower_header_string .. "|-------------------";
        else
            header_string       = header_string       .. "|" .. col_struct.case_dir_list[1];
            lower_header_string = lower_header_string .. "|-------------------";

            for i = 2, studies do
                nonconv_list = {};
                dimension    = {};

                get_nonconv_info(col_struct,nconv_file_name,nonconv_list,dimension,i);

                has_nconv_data[i] = false;
                if #nonconv_list > 0 then
                    has_nconv_data[i] = true;

                    header_string       = header_string       .. "|" .. col_struct.case_dir_list[i];
                    lower_header_string = lower_header_string .. "|-------------------";

                    for j = 1, #nonconv_list do
                        nconv_table_strings[j] = nconv_table_strings[j] .. " | " .. tostring(dimension[j]);
                    end
                end

            end
        end
    end

    if has_nconv_data[1] then
        header_string       = header_string       .. "|";
        lower_header_string = lower_header_string .. "|";
        tab:push(header_string);
        tab:push(lower_header_string);

        for i = 1, #nconv_table_strings do
            nconv_table_strings[i] = nconv_table_strings[i] .. "|";
            tab:push(nconv_table_strings[i]);
        end
    end

    return tab;
end

-----------------------------------------------------------------------------------------------
-- Inflow energy report function
-----------------------------------------------------------------------------------------------

function create_inflow_energy(col_struct)
    local tab = Tab(dictionary.tab_inflow_energy[LANGUAGE]);

    local inferg = {};
    for i = 1, studies do
        inferg[i] = col_struct.generic[i]:load("sddp_dashboard_input_enaflu");
    end

    -- Color vectors
    local chart = Chart(dictionary.inflow_energy[LANGUAGE]);
    if studies > 1 then
        for i = 1, studies do

            -- Confidence interval
            chart:add_area_range(inferg[i]:select_agent(1):add_prefix(col_struct.case_dir_list[i] .. " - "), inferg[i]:select_agent(3), { xUnit=dictionary.cell_stages[LANGUAGE], colors = { light_global_color[i], light_global_color[i] } });
            chart:add_line(inferg[i]:select_agent(2):add_prefix(col_struct.case_dir_list[i] .. " - ")); -- average
        end
    else
        -- Confidence interval
        chart:add_area_range(inferg[1]:select_agent(1), inferg[1]:select_agent(3), { xUnit=dictionary.cell_stages[LANGUAGE], colors = { light_global_color[1], light_global_color[1] } });
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

function get_conv_file_info(col_struct, file_name, file_list, systems, horizons, case_index)
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

function get_convergence_file_agents(col_struct, file_list, conv_age, cuts_age, time_age, case_index)
    for i, file in ipairs(file_list) do
        local conv_file = col_struct.generic[case_index]:load(file);
        conv_age[i] = conv_file:select_agents({ 1, 2, 3, 4 }); -- Zinf, Zsup - Tol, Zsup, Zsup + Tol
        cuts_age[i] = conv_file:select_agents({ 5, 6 }); -- Optimality, Feasibility
        time_age[i] = conv_file:select_agents({ 7, 8 }); -- Forw. time, Back. time
    end
end

function get_convergence_map_status(col_struct, file_list, conv_status, case_index)
    local convertion_status = {};
    for i, file in ipairs(file_list) do
        -- Rewrite file
        local status = fix_conv_map_file(file,col_struct,case_index);
        table.insert(convertion_status,status);
        
        -- Load file
        local conv_map_file = col_struct.generic[case_index]:load(file);
        conv_status[i] = conv_map_file; -- Convergence status
    end
    
    for i = 1, #convertion_status do
        info("Convergence map rewrite status" .. tostring(convertion_status[i]));
    end
    
    return convertion_status;
end

function make_convergence_graphs(dashboard, conv_age, systems, horizon)
    for i, conv in ipairs(conv_age) do
        local chart = Chart(dictionary.convergence[LANGUAGE] .. " | " .. dictionary.system[LANGUAGE] .. " : " .. systems[i] .. " | " .. dictionary.horizon[LANGUAGE] .. " : " .. horizon[i]);
        chart:add_area_range(conv:select_agents({ 2 }), conv:select_agents({ 4 }), { colors = { "#ACD98D", "#ACD98D" }, xAllowDecimals = false }); -- Confidence interval
        chart:add_line(conv:select_agents({ 1 }), { colors = { "#3CB7CC" }, xAllowDecimals = false }); -- Zinf
        chart:add_line(conv:select_agents({ 3 }), { colors = { "#32A251" }, xAllowDecimals = false }); -- Zsup
        dashboard:push(chart);
    end
end

function make_added_cuts_graphs(dashboard, cuts_age, systems, horizon)
    for i, cuts in ipairs(cuts_age) do
        local chart = Chart(dictionary.number_of_added_cut[LANGUAGE] .. " | " .. dictionary.system[LANGUAGE] .. " : " .. systems[i] .. dictionary.horizon[LANGUAGE] .. " : " .. horizon[i]);
        chart:add_column(cuts:select_agents({ 1 }), { xAllowDecimals = false }); -- Opt
        chart:add_column(cuts:select_agents({ 2 }), { xAllowDecimals = false }); -- Feas
        dashboard:push(chart);
    end
end

function calculate_number_of_systems(sys_vec)
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

function create_penalty_proportion_graph(tab, col_struct, i)
    local output_name  = "sddppenp";
    local report_title = dictionary.violation_penalties[LANGUAGE];
    local penp = col_struct.generic[i]:load(output_name);

    if not penp:loaded() then
        info(output_name .. " could not be loaded. ".. "'" .. report_title .. "'" .. "report will not be displayed");
        return
    end

    penp:convert("%");

    local chart = Chart(report_title .. " (%)");
    chart:add_heatmap_series(penp, { yLabel = "Scenario", xLabel = dictionary.cell_stages[LANGUAGE], showInLegend = false, stops = { { 0.0, "#4E79A7" }, { 0.5, "#FBEEB3" }, { 1.0, "#C64B3E" } }, stopsMin = 0.0, stopsMax = 100.0 });
    tab:push(chart);
end

function create_conv_map_graph(tab, file_name, col_struct, i)
    local conv_map = col_struct.generic[i]:load(file_name);
    local report_title = dictionary.convergence_map[LANGUAGE];

    if not conv_map:loaded() then
        info(file_name .. " could not be loaded. ".. "'" .. report_title .. "'" .. "report will not be displayed");
        return
    end

    local options = {
        yLabel = "Iteration",
        xLabel = dictionary.cell_stages[LANGUAGE],
        showInLegend = false,
        stopsMin = 0,
        stopsMax = 2,
        dataClasses = {
            { color = "#C64B3E", from = -0.5, to = 0.5, name = "not converged" },
            { color = "#4E79A7", from =  0.5, to = 1.5, name = "converged"     },
            { color = "#FBEEB3", from =  1.5, to = 2.5, name = "warning"       }
        }
    };

    local chart = Chart(report_title);
    chart:add_heatmap(conv_map,options);
    tab:push(chart);
end

function create_hourly_sol_status_graph(tab, col_struct, i)
    local output_name  = "hrstat";
    local report_title = dictionary.solution_status[LANGUAGE];
    local status = col_struct.generic[i]:load(output_name);

    if not status:loaded() then
        info(output_name .. " output could not be loaded. ".. "'" .. report_title .. "'" .. "report will not be displayed");
        return
    end

    local options = {
    yLabel = "Scenario",
    xLabel = dictionary.cell_stages[LANGUAGE],
    showInLegend = false,
    stopsMin = 0,
    stopsMax = 3,
    dataClasses = {
                  { color = "#8ACE7E", to = 0          , name = "Optimal solution" },
                  { color = "#4E79A7", from = 1, to = 2, name = "Feasible solution"},
                  { color = "#C64B3E", from = 2, to = 3, name = "No solution"      },
                  { color = "#FBEEB3", from = 3        , name = "Relaxed solution" }
                  }
    };

    local chart = Chart(report_title);
    chart:add_heatmap(status,options);
    tab:push(chart);

    if status:remove_zeros():loaded() then
        advisor:push_warning("mip_convergence");
    end
end

-- Execution times per scenario (dispersion)
function create_exe_timer_per_scen(tab, col_struct, i)
    local extime_chart;
    local output_name  = "extime";
    local extime = col_struct.generic[i]:load(output_name);

    if not extime:loaded() then
        info(output_name .. " output could not be loaded. 'Dispersion of execution times per scenario' report will not be displayed");
        return
    end
    
    local extime_disp = concatenate(extime:aggregate_agents(BY_SUM(), "MIN"):aggregate_scenarios(BY_MIN()), extime:aggregate_agents(BY_SUM(), "Average"):aggregate_scenarios(BY_AVERAGE()), extime:aggregate_agents(BY_SUM(), "MAX"):aggregate_scenarios(BY_MAX()));
    if is_greater_than_zero(extime_disp) then
        local unit = "hour";
        local extime_disp_data = extime_disp:aggregate_scenarios(BY_MAX()):aggregate_stages(BY_MAX()):to_list();

        if extime_disp_data[1] < 1.0 then
            unit = "ms";
        elseif extime_disp_data[1] < 3600.0 then
            unit = "s";
        end

        extime_chart = Chart(dictionary.dispersion_of_time[LANGUAGE]);
        extime_chart:add_area_range(extime_disp:select_agent("MIN"):convert(unit),
                                    extime_disp:select_agent("MAX"):convert(unit),
                                    { xUnit = dictionary.cell_stages[LANGUAGE], colors = { "#EA6B73", "#EA6B73" } }); -- Confidence interval
        extime_chart:add_line(extime_disp:select_agent("Average"):convert(unit),
                              { xUnit = dictionary.cell_stages[LANGUAGE], colors = { "#F02720" } });                  -- Average

        if #extime_chart > 0 then
            tab:push(extime_chart);
        end
    end
end

function create_pol_report(col_struct)
    local tab = Tab(dictionary.tab_policy[LANGUAGE]);

    local total_cost_age;
    local future_cost_age;
    local immediate_cost;
    local fcf_last_stage_cost;
    local rel_diff;

    local file_list = {};
    local convm_file_list = {};
    local systems = {};
    local horizon = {};

    local conv_data         = {};
    local cuts_data         = {};
    local time_data         = {};
    local conv_status       = {};
    local convertion_status = {};

    local conv_file;

    local has_results_for_add_years;
    local zsup_is_visible = true;

    -- Convergence map report
    get_conv_file_info(col_struct, "sddpconvm.csv", convm_file_list, systems, horizon, 1);
    convertion_status = get_convergence_map_status(col_struct, convm_file_list, conv_status, 1);
    for i = 1, #convertion_status do
        if not convertion_status[i] then
            error("Error converting convergence map file " .. convm_file_list[i]);
        end
    end
    
    -- Convergence report
    get_conv_file_info(col_struct, "sddppol.csv", file_list, systems, horizon, 1);
    get_convergence_file_agents(col_struct, file_list, conv_data, cuts_data, time_data, 1);

    -- Creating policy report
    for i, file in ipairs(file_list) do
        tab:push("## " .. dictionary.system[LANGUAGE] .. ": " .. systems[i] .. " | " .. dictionary.horizon[LANGUAGE] .. ": " .. horizon[i]);

        if studies > 1 then
            local chart_conv      = Chart(dictionary.convergence[LANGUAGE]);
            local chart_cut_opt   = Chart(dictionary.new_cut_per_iteration_optimality[LANGUAGE]);
            local chart_cut_feas  = Chart(dictionary.new_cut_per_iteration_feasibility[LANGUAGE]);

            for j = 1, studies do

                conv_file = col_struct.generic[j]:load(file);
                if conv_file:loaded() then
                    conv_age = conv_file:select_agents({ 1, 2, 3, 4 }); -- Zinf        ,Zsup - Tol  ,Zsup        ,Zsup + Tol
                    cuts_age = conv_file:select_agents({ 5, 6 }); -- Optimality  ,Feasibility

                    -- Confidence interval
                    chart_conv:add_area_range(conv_age:select_agents({ 2 }):rename_agent(col_struct.case_dir_list[j] .. " - Zsup - Tol"), conv_age:select_agents({ 4 }):rename_agent(col_struct.case_dir_list[j] .. " - Zsup + Tol"), { colors = { light_global_color[j], light_global_color[j] }, xUnit = "Iteration", xAllowDecimals = false, showInLegend = true });

                    -- Zsup
                    chart_conv:add_line(conv_age:select_agents({ 3 }):rename_agent(col_struct.case_dir_list[j] .. " - Zsup"), { colors = { main_global_color[j] }, xAllowDecimals = false, visible = zsup_is_visible });

                    -- Zinf
                    chart_conv:add_line(conv_age:select_agents({ 1 }):rename_agent(col_struct.case_dir_list[j] .. " - Zinf"), { colors = { main_global_color[j] }, xAllowDecimals = false, dashStyle = "dash" }); -- Zinf

                    -- Cuts - optimality
                    chart_cut_opt:add_column(cuts_age:select_agents({ 1 }):rename_agent(col_struct.case_dir_list[j]), { xUnit = "Iteration", xAllowDecimals = false });

                    -- Cuts - feasibility
                    if is_greater_than_zero(cuts_age:select_agents({ 2 })) then
                        chart_cut_feas:add_column(cuts_age:select_agents({ 2 }):rename_agent(col_struct.case_dir_list[j]), { xUnit = "Iteration", xAllowDecimals = false });
                    end
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
        else
            -- Get operation mode parameter
            oper_mode = col_struct.study[1]:get_parameter("Opcion", -1); -- 1=AIS; 2=COO; 3=INT;

            has_results_for_add_years = col_struct.study[1]:get_parameter("NumeroAnosAdicionaisParm2",-1) == 1;

            nsys = calculate_number_of_systems(systems);
            
            conv_file = col_struct.generic[1]:load(file);
            conv_age = conv_file:select_agents({ 1, 2, 3, 4 }); -- Zinf        ,Zsup - Tol  ,Zsup        ,Zsup + Tol
            cuts_age = conv_file:select_agents({ 5, 6 }); -- Optimality  ,Feasibility
            
            -- If there is only one FCF file in the case and no rolling horizons, print final simulation cost as columns
            show_sim_cost = false;
            if ( ((oper_mode < 3 and nsys == 1) or oper_mode == 3) and col_struct.study[1]:get_parameter("RHRZ", 0) == 0) then
                show_sim_cost = true;

                local objcop = col_struct.generic[1]:load("objcop");
                local discount_rate = require("sddp/discount_rate")(1);

                immediate_cost = 0.0;
                if col_struct.study[1]:get_parameter("SIMH", -1) == 2 then -- Hourly model writes objcop with different columns
                    if not has_results_for_add_years then
                        future_cost_age = objcop:select_agent(1):aggregate_scenarios(BY_AVERAGE());
                    end

                    -- Remove first column(Future cost) of hourly objcop
                    immediate_cost = (objcop:remove_agent(1) / discount_rate):aggregate_agents(BY_SUM(), "Immediate cost"):aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):to_list()[1];
                else
                    -- Select total cost and future cost agents
                    total_cost_age = objcop:select_agent(1):aggregate_scenarios(BY_AVERAGE());
                    future_cost_age = objcop:select_agent(-1):aggregate_scenarios(BY_AVERAGE());

                    -- Calculating total cost as sum of immediate costs per stage
                    immediate_cost = ((total_cost_age - future_cost_age) / discount_rate):aggregate_stages(BY_SUM()):rename_agent("Total cost"):to_list()[1];
                end

                if not has_results_for_add_years then
                    fcf_last_stage_index = future_cost_age:last_stage();
                    fcf_last_stage_cost  = future_cost_age:select_stage(fcf_last_stage_index):to_list()[1];
                    last_stage_disc      = discount_rate:select_stage(fcf_last_stage_index):to_list()[1];

                    immediate_cost = immediate_cost + fcf_last_stage_cost / last_stage_disc;
                end

                -- Take expression and use it as mask for "final_sim_cost"
                conv_age_aux = conv_age:select_agent(1):rename_agent("Final simulation");
                final_sim_cost = conv_age_aux:fill(immediate_cost);

            end

            -----------------------------------------------------------------------------------------------------------
            -- Convergence chart
            -----------------------------------------------------------------------------------------------------------
            local chart = Chart(dictionary.convergence[LANGUAGE]);
            -- Zinf
            chart:add_line(conv_age:select_agents({ 1 }), { xUnit = "Iteration", colors = { "#3CB7CC" }, xAllowDecimals = false });
            -- Zsup
            chart:add_line(conv_age:select_agents({ 3 }):rename_agent("Zsup"), { colors = { "#32A251" }, xAllowDecimals = false });
            -- Confidence interval
            chart:add_area_range(conv_age:select_agents({ 2 }):rename_agent(""), conv_age:select_agents({ 4 }):rename_agent("Zsup +- Tol"), { colors = { "#ACD98D", "#ACD98D" }, xUnit = "Iteration", xAllowDecimals = false, visible = zsup_is_visible });
            
            local tolerance_for_convergence = tonumber(col_struct.study[1]:get_parameter("CriterioConvergencia", -1));

            local total_iter = conv_age:stages();
            local zinf_final = tonumber(conv_age:select_agents({ 1 }):select_stage(total_iter):to_list()[1]);
            local zsup_tol_final = tonumber(conv_age:select_agents({ 4 }):select_stage(total_iter):to_list()[1]);
            local gap = ( zsup_tol_final - zinf_final );
            if gap > 0 then
                if (gap + 0.0000001) > tolerance_for_convergence then
                    advisor:push_warning("convergence_gap",1);
                end
            else
                -- to_do: negative gap msg
            end

            if (show_sim_cost and has_results_for_add_years) then
                -- Final simulation cost
                chart:add_line(final_sim_cost:rename_agent("Final simulation"), { colors = { "#D37295" }, xAllowDecimals = false });

                -- Deviation error
                zsup = conv_file:select_agent(3);
                last_zsup = zsup:to_list()[zsup:last_stage()];
                rel_diff = (immediate_cost - last_zsup)/immediate_cost;
                if rel_diff > REP_DIFF_TOL or -rel_diff < -REP_DIFF_TOL then
                    advisor:push_warning("simulation_cost");
                end
            end
            tab:push(chart);

            -----------------------------------------------------------------------------------------------------------
            -- Final simulation chart
            -----------------------------------------------------------------------------------------------------------
            if (show_sim_cost and not has_results_for_add_years) then
                local chart = Chart(dictionary.policy_simulation[LANGUAGE]);

                conv_age = conv_file:select_agents({ 9, 10, 11}); -- Zsup - Tol  ,Zsup        ,Zsup + Tol   (With FCF added in the last stage before additional years)

                -- Zsup
                chart:add_line(conv_age:select_agents({ 2 }):rename_agent("Zsup (IC+FCF)"), { colors = { "#FF9DA7" }, xAllowDecimals = false });

                -- Confidence interval
                chart:add_area_range(conv_age:select_agents({ 1 }):rename_agent(""), conv_age:select_agents({ 3 }):rename_agent("Zsup (IC+FCF) +- Tol"), { colors = { "#FFD8DC", "#FFD8DC" }, xUnit = "Iteration", xAllowDecimals = false, showInLegend = true });

                -- Final simulation cost
                chart:add_line(final_sim_cost:rename_agent("Final simulation"), { colors = { "#D37295" }, xAllowDecimals = false });

                -- Deviation error
                zsup = conv_file:select_agent(10);
                last_zsup = zsup:to_list()[zsup:last_stage()];
                rel_diff = (immediate_cost - last_zsup)/immediate_cost;
                if rel_diff > REP_DIFF_TOL or -rel_diff < -REP_DIFF_TOL then
                    tab:push("**WARNING**");
                    tab:push("The objective function value of the final simulation deviates by " .. string.format("%.1f",100*rel_diff) .. "% from objective function of the last iteration of the policy phase.");
                    tab:push("This indicates that the policy representation lacks critical system characteristics, potentially resulting in a suboptimal solution in final simulation.");
                end

                tab:push(chart);

                tab:push("**" ..dictionary.additional_years_mensage[LANGUAGE].."**");
                tab:push("* **"..dictionary.final_simulation[LANGUAGE].."**: "..dictionary.final_simulation_mensage[LANGUAGE]);
                tab:push("* **Zsup (IC + FCF)**: "..dictionary.zsup_mensage[LANGUAGE]);
            end

            -----------------------------------------------------------------------------------------------------------
            -- Cuts per iteration
            -----------------------------------------------------------------------------------------------------------
            chart = Chart(dictionary.new_cuts_per_iteration[LANGUAGE]);

            chart:add_column(cuts_age:select_agents({ 1 }), { xUnit = "Iteration", xAllowDecimals = false }); -- Optimality

            -- For feas. cuts, plot only if at least one cut
            if is_greater_than_zero(cuts_age:select_agents({ 2 })) then
                chart:add_column(cuts_age:select_agents({ 2 }), { xUnit = "Iteration", xAllowDecimals = false }); -- Feasibility
            end
            tab:push(chart);

            -----------------------------------------------------------------------------------------------------------
            -- Convergence map
            -----------------------------------------------------------------------------------------------------------
            create_conv_map_graph(tab, convm_file_list[i], col_struct, 1);
        end
    end

    return tab;
end

-----------------------------------------------------------------------------------------------
-- Simulation objetive function cost terms report function
-----------------------------------------------------------------------------------------------

function create_sim_report(col_struct)
    local tab = Tab(dictionary.tab_simulation[LANGUAGE]);

    local costs;
    local costs_agg;
    local exe_times;

    local cost_chart    = Chart(dictionary.breakdown_cost_time[LANGUAGE]);
    local revenue_chart = Chart(dictionary.breakdown_revenue_time[LANGUAGE]);

    local objcop = require("sddp/costs");
    local discount_rate = require("sddp/discount_rate");

    if studies > 1 then
        for i = 1, studies do
            costs = objcop(i) / discount_rate(i):select_stages_of_outputs();
            -- sddp_dashboard_cost_tot
            costs_agg = costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):remove_zeros();
            cost_chart:add_categories(costs_agg, col_struct.case_dir_list[i]);
        end
    else
        costs = objcop() / discount_rate():select_stages_of_outputs();
        costs_agg = costs:aggregate_scenarios(BY_AVERAGE()):aggregate_stages(BY_SUM()):remove_zeros();

        if is_greater_than_zero(costs_agg) then
            cost_chart:add_pie(ifelse(costs_agg:gt(0), costs_agg, 0):remove_zeros(), {colors = main_global_color});
            revenue_chart:add_pie(ifelse(costs_agg:lt(0), costs_agg, 0):remove_zeros():abs(), {colors = subrange(main_global_color, #cost_chart + 1, #main_global_color)});
            
            if #revenue_chart > 0 then
                cost_chart = {cost_chart,revenue_chart};
            end
        end
    end

    if #cost_chart > 0 then
        tab:push(cost_chart);
    end

    -- Add stage-wise cost reports
    create_costs_and_revs(col_struct,tab);
    
    -- Heatmap after the pizza graph in dashboard
    if studies == 1 then
        -- Creating simulation heatmap graphics
        if col_struct.study[1]:get_parameter("SIMH", -1) == 2 then
            create_hourly_sol_status_graph(tab, col_struct, 1);
        end

        create_penalty_proportion_graph(tab, col_struct, 1);
    end

    return tab;
end

-----------------------------------------------------------------------------------------------
-- Execution times report function
-----------------------------------------------------------------------------------------------

function create_times_report(col_struct)
    local tab = Tab(dictionary.execution_times[LANGUAGE]);

    ---------
    -- Policy
    ---------
    tab:push("## " .. dictionary.tab_policy[LANGUAGE]);
    
    local file_list = {};
    local systems = {};
    local horizon = {};
    
    local conv_data         = {};
    local cuts_data         = {};
    local time_data         = {};
    local conv_status       = {};
    
    -- Loading convergence data
    get_conv_file_info(col_struct, "sddppol.csv", file_list, systems, horizon, 1);
    get_convergence_file_agents(col_struct, file_list, conv_data, cuts_data, time_data, 1);
    
    for i, file in ipairs(file_list) do
        tab:push("# " .. dictionary.system[LANGUAGE] .. ": " .. systems[i] .. " | " .. dictionary.horizon[LANGUAGE] .. ": " .. horizon[i]);
    
        if studies > 1 then
            local chart_time_forw = Chart(dictionary.forward_time[LANGUAGE]);
            local chart_time_back = Chart(dictionary.backward_time[LANGUAGE]);

            for jstudy = 1, studies do
                conv_file = col_struct.generic[jstudy]:load(file);
                time_age = conv_file:select_agents({ 7, 8 }); -- Forw. time, Back. time
                
                if conv_file:loaded() then
                    -- Execution time - forward
                    chart_time_forw:add_column(time_age:select_agents({ 1 }):rename_agent(col_struct.case_dir_list[jstudy]), { xUnit = "Iteration", xAllowDecimals = false });
    
                    -- Execution time - backward
                    chart_time_back:add_column(time_age:select_agents({ 2 }):rename_agent(col_struct.case_dir_list[jstudy]), { xUnit = "Iteration", xAllowDecimals = false });
                else
                    info("Comparing cases have different policy horizons! Policy will only contain the main case data.");
                end
            end
            
            if #chart_time_forw > 0 then
                tab:push(chart_time_forw);
            end
            if #chart_time_back > 0 then
                tab:push(chart_time_back);
            end
        else
            conv_file = col_struct.generic[1]:load(file);
            time_age = conv_file:select_agents({ 7, 8 }); -- Forw. time, Back. time
            
            chart = Chart(dictionary.fwd_bwd_time[LANGUAGE]);
            chart:add_line(time_age:rename_agents({"Forward","Backward"}), { xUnit = "Iteration", xAllowDecimals = false }); -- Forw. and Back. times
            
            if #chart > 0 then
                tab:push(chart);
            end
            
        end
    end
    
    -------------
    -- Simulation
    -------------
    tab:push("## " .. dictionary.tab_simulation[LANGUAGE]);
    
    if studies > 1 then
        local chart_exe_sim = Chart(dictionary.exe_sim_times[LANGUAGE]);
        local chart_exe_pol = Chart(dictionary.exe_pol_times[LANGUAGE]);
        
        for istudy = 1, studies do
            -- Execution times
            exe_times = col_struct.generic[istudy]:load("sddptimes");
            chart_exe_sim:add_column(exe_times:select_agent(1):rename_agent(col_struct.case_dir_list[istudy]));
            chart_exe_pol:add_column(exe_times:select_agent(2):rename_agent(col_struct.case_dir_list[istudy]));
        end
        
        if #chart_exe_sim > 0 then
           tab:push(chart_exe_sim);
        end
        if #chart_exe_pol > 0 then
           tab:push(chart_exe_pol);
        end
    else
        -- Simulation execution times
        local exet_chart = Chart(dictionary.execution_times[LANGUAGE]);
        
        exe_times = col_struct.generic[1]:load("sddptimes");
        exet_chart:add_column(exe_times);
        
        if #exet_chart > 0 then
           tab:push(exet_chart);
        end
        
        -- Execution times per scenario
        if col_struct.study[1]:get_parameter("SCEN", 0) == 0 then -- SDDP scenarios does not have execution times per scenario
            create_exe_timer_per_scen(tab, col_struct, 1);
        end
    end
    
    return tab;
end 

-----------------------------------------------------------------------------------------------
-- Simulation costs report function
-----------------------------------------------------------------------------------------------

function create_costs_and_revs(col_struct, tab)

    local chart = Chart(dictionary.disp_of_operation_cost[LANGUAGE]);
    local chart_avg = Chart(dictionary.avg_operation_cost[LANGUAGE]);

    for i = 1, studies do
        local objcop = require("sddp/costs");
        local discount_rate = require("sddp/discount_rate");
        local costs = ifelse(objcop(i):ge(0), objcop(i), 0) / discount_rate(i):select_stages_of_outputs();

        -- sddp_dashboard_cost_tot
        if studies == 1 then
            costs:remove_zeros():save("sddp_dashboard_cost_tot", { csv = true });
        end

        local disp = concatenate(costs:aggregate_agents(BY_SUM(), "P10"):aggregate_scenarios(BY_PERCENTILE(10)), costs:aggregate_agents(BY_SUM(), "Average"):aggregate_scenarios(BY_AVERAGE()), costs:aggregate_agents(BY_SUM(), "P90"):aggregate_scenarios(BY_PERCENTILE(90)));

        if studies > 1 then
            if is_greater_than_zero(disp) then
                chart:add_area_range(disp:select_agent(1):add_prefix(col_struct.case_dir_list[i] .. " - "), disp:select_agent(3), { xUnit=dictionary.cell_stages[LANGUAGE], colors = light_global_color[i] }); -- Confidence interval
                chart:add_line(disp:select_agent(2):add_prefix(col_struct.case_dir_list[i] .. " - "),{xUnit=dictionary.cell_stages[LANGUAGE], colors = {main_global_color[i]} }); -- Average
            end
        else
            if is_greater_than_zero(disp) then
                chart:add_area_range(disp:select_agent(1), disp:select_agent(3), { xUnit=dictionary.cell_stages[LANGUAGE], colors = { "#EA6B73", "#EA6B73" } }); -- Confidence interval
                chart:add_line(disp:select_agent(2), { xUnit=dictionary.cell_stages[LANGUAGE], colors = { "#F02720" } }); -- Average
            end
        end

        -- sddp_dashboard_cost_avg
        local costs_avg = costs:aggregate_scenarios(BY_AVERAGE()):remove_zeros();
        if studies == 1 and is_greater_than_zero(costs_avg) then
            chart_avg:add_column_stacking(costs_avg,{xUnit=dictionary.cell_stages[LANGUAGE]});
        end
    end

    if #chart_avg > 0 then
        tab:push(chart_avg);
    end

    if #chart > 0 then
        tab:push(chart);
    end
    
    return;
end

-----------------------------------------------------------------------------------------------
-- Marginal cost report function
-----------------------------------------------------------------------------------------------

function create_marg_costs(col_struct)
    local tab = Tab(dictionary.tab_cmo[LANGUAGE]);

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
    local chart = Chart(dictionary.annual_cmo[LANGUAGE]);
    if studies > 1 then
        for i = 1, studies do
            cmg_aggyear = cmg[i]:aggregate_blocks_by_duracipu(i):aggregate_stages_weighted(BY_AVERAGE(), col_struct.study[i].hours:select_stages_of_outputs(), Profile.PER_YEAR):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM);

            -- Add marginal costs outputs
            chart:add_categories(cmg_aggyear, col_struct.case_dir_list[i], { xUnit=dictionary.cell_year[LANGUAGE] }); -- Annual Marg. cost
        end
    else
        cmg_aggyear = cmg[1]:aggregate_blocks_by_duracipu():aggregate_stages_weighted(BY_AVERAGE(), col_struct.study[1].hours:select_stages_of_outputs(), Profile.PER_YEAR):aggregate_scenarios(BY_AVERAGE());
        chart:add_column(cmg_aggyear, { xUnit=dictionary.cell_year[LANGUAGE] });
    end
    tab:push(chart);

    if studies > 1 then
        tab:push("## " .. dictionary.stg_cmo[LANGUAGE]);
        local agents = cmg[1]:agents();
        for i, agent in ipairs(agents) do
            local chart = Chart(agent);
            for j = 1, studies do
                cmg_aggsum = cmg[j]:select_agent(agent):rename_agent(col_struct.case_dir_list[j]):aggregate_blocks_by_duracipu(j):aggregate_scenarios(BY_AVERAGE())
                chart:add_line(cmg_aggsum,{xUnit=dictionary.cell_stages[LANGUAGE]}); -- Average marg. cost per stage
            end
            tab:push(chart);
        end
    else
        local chart = Chart(dictionary.stg_cmo[LANGUAGE]);
        cmg_aggsum = cmg[1]:aggregate_blocks_by_duracipu():aggregate_scenarios(BY_AVERAGE());
        chart:add_column(cmg_aggsum,{xUnit=dictionary.cell_stages[LANGUAGE]}, {colors = main_global_color});
        tab:push(chart);
    end

    if studies == 1 then
        local systems = col_struct.system[1]:labels();
        for i,system in ipairs(systems) do
            local chart = Chart(system .. dictionary.stg_cmo_ind[LANGUAGE]);
            local cmg_agg = cmg[1]:aggregate_blocks_by_duracipu():select_agents({system});
            chart:add_box_plot(
                cmg_agg:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_MIN()),
                cmg_agg:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_PERCENTILE(25)),
                cmg_agg:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_PERCENTILE(50)),
                cmg_agg:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_PERCENTILE(75)),
                cmg_agg:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_MAX())
                ,{showInLegend = false, color = main_global_color[i]}
            );
            tab:push(chart);
        end
    end

    return tab;
end

-----------------------------------------------------------------------------------------------
-- Generation report function
-----------------------------------------------------------------------------------------------

function create_gen_report(col_struct)
    local tab = Tab(dictionary.tab_generation[LANGUAGE]);

    -- Color preferences
    local color_hydro = '#4E79A7';
    local color_thermal = '#F28E2B';
    local color_renw_other = '#7a5950';
    local color_wind = '#8CD17D';
    local color_solar = '#F1CE63';
    local color_small_hydro = '#A0CBE8';
    local color_csp = '#70AD47';
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
    local total_csp_gen;
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
    local total_csp_gen_age;

    local hydro_agent_name;
    local thermal_agent_name;
    local battery_agent_name;
    local deficit_agent_name;
    local pinj_agent_name;
    local renw_ot_agent_name;
    local renw_wind_agent_name;
    local renw_solar_agent_name;
    local renw_shydro_agent_name;
    local renw_csp_agent_name;

    local hydro_report_name;
    local thermal_report_name;
    local battery_report_name;
    local deficit_report_name;
    local pinj_report_name;

    local renw_ot_report_name;
    local renw_wind_report_name;
    local renw_solar_report_name;
    local renw_shydro_report_name;

    local gerter = {};
    local gerhid = {};
    local gergnd = {};
    local gercsp = {};
    local wind = {};
    local solar = {};
    local gerbat = {};
    local potinj = {};
    local defcit = {};

    -- Loading generations files
    for i = 1, studies do

        gerter[i] = col_struct.thermal[i]:load("gerter"):select_stages_of_outputs();
        gerhid[i] = col_struct.hydro[i]:load("gerhid"):select_stages_of_outputs();
        gergnd[i] = col_struct.renewable[i]:load("gergnd"):select_stages_of_outputs();
        gercsp[i] = col_struct.csp[i]:load("cspgen"):convert("GWh"):select_stages_of_outputs();
        gerbat[i] = col_struct.battery[i]:load("gerbat"):convert("GWh"):select_stages_of_outputs(); -- Explicitly converting to GWh
        potinj[i] = col_struct.power_injection[i]:load("powinj"):select_stages_of_outputs();
        defcit[i] = col_struct.system[i]:load("defcit"):select_stages_of_outputs();
    end

    if studies > 1 then
        chart_tot_gerhid     = Chart(dictionary.total_hydro[LANGUAGE]);
        chart_tot_sml_hid    = Chart(dictionary.total_small_hydro[LANGUAGE]);
        chart_tot_gerter     = Chart(dictionary.total_thermal[LANGUAGE]);
        chart_tot_other_renw = Chart(dictionary.total_renewable_other[LANGUAGE]);
        chart_tot_renw_wind  = Chart(dictionary.total_renewable_wind[LANGUAGE]);
        chart_tot_renw_solar = Chart(dictionary.total_renewable_solar[LANGUAGE]);
        chart_tot_renw_shyd  = Chart(dictionary.total_renewable_small_hydro[LANGUAGE]);
        chart_tot_renw_csp   = Chart(dictionary.total_renewable_csp[LANGUAGE]);
        chart_tot_gerbat     = Chart(dictionary.total_battery[LANGUAGE]);
        chart_tot_potinj     = Chart(dictionary.total_power_injection[LANGUAGE]);
        chart_tot_defcit     = Chart(dictionary.total_deficit[LANGUAGE]);
    else
        chart = Chart(dictionary.total_generation[LANGUAGE]);
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
            total_csp_gen_age         = col_struct.case_dir_list[i] .. " - ";
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
            total_csp_gen_age         = "";
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
        total_csp_gen_age         = total_csp_gen_age         .. "Total Renewable - CSP";

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
        total_csp_gen         = gercsp[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), total_csp_gen_age);
        total_thermal_gen = gerter[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), total_thermal_gen_age);

        if studies > 1 then
            if total_hydro_gen:loaded() then
                chart_tot_gerhid:add_column(total_hydro_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
            if total_thermal_gen:loaded() then
                chart_tot_gerter:add_column(total_thermal_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
            if total_other_renw_gen:loaded() then
                chart_tot_other_renw:add_column(total_other_renw_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
            if total_wind_gen:loaded() then
                chart_tot_renw_wind:add_column(total_wind_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
            if total_solar_gen:loaded() then
                chart_tot_renw_solar:add_column(total_solar_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
            if total_small_hydro_gen:loaded() then
                chart_tot_renw_shyd:add_column(total_small_hydro_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
            if total_csp_gen:loaded() then
                chart_tot_renw_csp:add_column(total_csp_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
            if total_batt_gen:loaded() then
                chart_tot_gerbat:add_column(total_batt_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
            if total_pot_inj:loaded() then
                chart_tot_potinj:add_column(total_pot_inj, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
            if total_deficit:loaded() then
                chart_tot_defcit:add_column(total_deficit, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
        else
            chart:add_area_stacking(total_thermal_gen    , { xUnit=dictionary.cell_stages[LANGUAGE], colors = { color_thermal     } });
            chart:add_area_stacking(total_hydro_gen      , { xUnit=dictionary.cell_stages[LANGUAGE], colors = { color_hydro       } });
            chart:add_area_stacking(total_wind_gen       , { xUnit=dictionary.cell_stages[LANGUAGE], colors = { color_wind        } });
            chart:add_area_stacking(total_solar_gen      , { xUnit=dictionary.cell_stages[LANGUAGE], colors = { color_solar       } });
            chart:add_area_stacking(total_small_hydro_gen, { xUnit=dictionary.cell_stages[LANGUAGE], colors = { color_small_hydro } });
            chart:add_area_stacking(total_csp_gen        , { xUnit=dictionary.cell_stages[LANGUAGE], colors = { color_csp } });
            chart:add_area_stacking(total_other_renw_gen , { xUnit=dictionary.cell_stages[LANGUAGE], colors = { color_renw_other  } });
            chart:add_area_stacking(total_batt_gen       , { xUnit=dictionary.cell_stages[LANGUAGE], colors = { color_battery     } });
            chart:add_area_stacking(total_pot_inj        , { xUnit=dictionary.cell_stages[LANGUAGE], colors = { color_pinj        } });
            chart:add_area_stacking(total_deficit        , { xUnit=dictionary.cell_stages[LANGUAGE], colors = { color_deficit     } });
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
        if #chart_tot_renw_csp > 0 then
            tab:push(chart_tot_renw_csp);
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
    hydro_report_name   = dictionary.total_hydro[LANGUAGE];
    thermal_report_name = dictionary.total_thermal[LANGUAGE];
    battery_report_name = dictionary.total_battery[LANGUAGE];
    deficit_report_name = dictionary.total_deficit[LANGUAGE];
    pinj_report_name    = dictionary.total_power_injection[LANGUAGE];

    renw_ot_report_name     = dictionary.total_renewable_other[LANGUAGE];
    renw_wind_report_name   = dictionary.total_renewable_wind[LANGUAGE];
    renw_solar_report_name  = dictionary.total_renewable_solar[LANGUAGE];
    renw_shydro_report_name = dictionary.total_small_hydro[LANGUAGE];
    renw_csp_report_name = dictionary.total_renewable_csp[LANGUAGE];

    -- Generation per system report
    local agents = col_struct.system[1]:labels();
    local code   = col_struct.system[1]:codes();
    for s, agent in ipairs(agents) do
        chart_tot_gerhid     =  Chart(dictionary.total_hydro[LANGUAGE]);
        chart_tot_gerter     =  Chart(dictionary.total_thermal[LANGUAGE]);
        chart_tot_renw_other =  Chart(dictionary.total_renewable_other[LANGUAGE]);
        chart_tot_renw_wind  =  Chart(dictionary.total_renewable_wind[LANGUAGE]);
        chart_tot_renw_solar =  Chart(dictionary.total_renewable_solar[LANGUAGE]);
        chart_tot_renw_shyd  =  Chart(dictionary.total_renewable_small_hydro[LANGUAGE]);
        chart_tot_renw_csp   =  Chart(dictionary.total_renewable_csp[LANGUAGE]);
        chart_tot_gerbat     =  Chart(dictionary.total_battery[LANGUAGE]);
        chart_tot_potinj     =  Chart(dictionary.total_power_injection[LANGUAGE]);
        chart_tot_defcit     =  Chart(dictionary.total_deficit[LANGUAGE]);

        for i = 1, studies do

            if studies > 1 then
                hydro_agent_name   = col_struct.case_dir_list[i] .. " - " .. hydro_report_name;
                thermal_agent_name = col_struct.case_dir_list[i] .. " - " .. thermal_report_name;
                battery_agent_name = col_struct.case_dir_list[i] .. " - " .. battery_report_name;
                deficit_agent_name = col_struct.case_dir_list[i] .. " - " .. deficit_report_name;
                pinj_agent_name    = col_struct.case_dir_list[i] .. " - " .. pinj_report_name;

                renw_ot_agent_name     = col_struct.case_dir_list[i] .. " - " .. renw_ot_report_name;
                renw_wind_agent_name   = col_struct.case_dir_list[i] .. " - " .. renw_wind_report_name;
                renw_solar_agent_name  = col_struct.case_dir_list[i] .. " - " .. renw_solar_report_name;
                renw_shydro_agent_name = col_struct.case_dir_list[i] .. " - " .. renw_shydro_report_name;
                renw_csp_agent_name    = col_struct.case_dir_list[i] .. " - " .. renw_csp_report_name;
            else
                hydro_agent_name   = hydro_report_name;
                thermal_agent_name = thermal_report_name;
                battery_agent_name = battery_report_name;
                deficit_agent_name = deficit_report_name;
                pinj_agent_name    = pinj_report_name;

                renw_ot_agent_name     = renw_ot_report_name;
                renw_wind_agent_name   = renw_wind_report_name;
                renw_solar_agent_name  = renw_solar_report_name;
                renw_shydro_agent_name = renw_shydro_report_name;
                renw_csp_agent_name    = renw_csp_report_name;
            end

            -- Data processing
            total_hydro_gen = gerhid[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(hydro_agent_name);
            total_batt_gen  = gerbat[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(battery_agent_name);
            total_deficit   = defcit[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(deficit_agent_name);
            total_pot_inj   = potinj[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(pinj_agent_name);
            total_csp_gen   = gercsp[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(renw_csp_agent_name);

            -- Renewable generation is broken into 3 types

            total_other_renw_gen = ifelse(col_struct.renewable[i].tech_type:ne(1):select_stages_of_outputs() &
                                          col_struct.renewable[i].tech_type:ne(2):select_stages_of_outputs() &
                                          col_struct.renewable[i].tech_type:ne(4):select_stages_of_outputs(),
                                          gergnd[i],
                                          0);
            total_wind_gen = ifelse(col_struct.renewable[i].tech_type:eq(1):select_stages_of_outputs(),
                                          gergnd[i],
                                          0);
            total_solar_gen = ifelse(col_struct.renewable[i].tech_type:eq(2):select_stages_of_outputs(),
                                          gergnd[i],
                                          0);
            total_small_hydro_gen = ifelse(col_struct.renewable[i].tech_type:eq(4):select_stages_of_outputs(),
                                          gergnd[i],
                                          0);

            total_other_renw_gen  = total_other_renw_gen:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(renw_ot_agent_name);
            total_wind_gen        = total_wind_gen:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(renw_wind_agent_name);
            total_solar_gen       = total_solar_gen:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(renw_solar_agent_name);
            total_small_hydro_gen = total_small_hydro_gen:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(renw_shydro_agent_name);
            total_thermal_gen     = gerter[i]:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):aggregate_agents(BY_SUM(), Collection.SYSTEM):select_agent(agent):rename_agent(thermal_agent_name);

            if total_hydro_gen:loaded() and col_struct.hydro[i].system:eq(code[s]):remove_zeros():loaded() then
                chart_tot_gerhid:add_column(total_hydro_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
            if total_thermal_gen:loaded() and col_struct.thermal[i].system:eq(code[s]):remove_zeros():loaded() then
                chart_tot_gerter:add_column(total_thermal_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
            if col_struct.renewable[i].system:eq(code[s]):remove_zeros():loaded() then
                if total_other_renw_gen:loaded() and (col_struct.renewable[i].tech_type:ne(1) + col_struct.renewable[i].tech_type:ne(2) + col_struct.renewable[i].tech_type:ne(4)):remove_zeros():loaded() then
                    chart_tot_renw_other:add_column(total_other_renw_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
                end
                if total_wind_gen:loaded() and col_struct.renewable[i].tech_type:eq(1):remove_zeros():loaded() then
                    chart_tot_renw_wind:add_column(total_wind_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
                end
                if total_solar_gen:loaded() and col_struct.renewable[i].tech_type:eq(2):remove_zeros():loaded() then
                    chart_tot_renw_solar:add_column(total_solar_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
                end
                if total_small_hydro_gen:loaded() and col_struct.renewable[i].tech_type:eq(4):remove_zeros():loaded() then
                    chart_tot_renw_shyd:add_column(total_small_hydro_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
                end
            end
            if total_csp_gen:loaded() and col_struct.csp[i].system:eq(code[s]):remove_zeros():loaded() then
                chart_tot_renw_csp:add_column(total_csp_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
            if total_batt_gen:loaded() and col_struct.battery[i].system:eq(code[s]):remove_zeros():loaded() then
                chart_tot_gerbat:add_column(total_batt_gen, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
            if total_pot_inj:loaded() and col_struct.power_injection[i].system:eq(code[s]):remove_zeros():loaded() then
                chart_tot_potinj:add_column(total_pot_inj, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
            if total_deficit:loaded() then
                chart_tot_defcit:add_column(total_deficit, { xUnit=dictionary.cell_stages[LANGUAGE]});
            end
        end

        tab:push("## ".. dictionary.total_generation_system[LANGUAGE] .. " - " .. agent);
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
        if #chart_tot_renw_csp > 0 then
            tab:push(chart_tot_renw_csp);
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

function create_risk_report(col_struct)
    local tab = Tab(dictionary.tab_defict_risk[LANGUAGE]);
    local chart = Chart(dictionary.total_defict_risk[LANGUAGE]);

    if studies > 1 then
        for i = 1, studies do
            risk_file = col_struct.system[i]:load("sddprisk"):aggregate_agents(BY_AVERAGE(), Collection.SYSTEM):aggregate_stages(BY_AVERAGE());

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

function create_viol_report(tab, col_struct, viol_struct, suffix)
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
                        chart:add_column_stacking(viol_file, {xUnit=dictionary.cell_stages[LANGUAGE]});
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
                chart:add_column_stacking(viol_file, {xUnit=dictionary.cell_stages[LANGUAGE]});
                tab:push(chart);
            end
        end
    end
end

function create_viol_report_from_list(tab, col_struct, viol_list, viol_struct, suffix)
    local viol_name;
    local tokens = {};

    for _, file in ipairs(viol_list) do
        -- Look for file title in violation structure
        for _, struct in ipairs(viol_struct) do
            viol_name = "sddp_dashboard_viol_" .. suffix .. "_" .. struct.name;
            if file == viol_name then
                viol_file = col_struct.generic[1]:load(file);
                if viol_file:loaded() then
                    local chart = Chart(struct.title);
                    chart:add_column_stacking(viol_file, {xUnit=dictionary.cell_stages[LANGUAGE]});
                    tab:push(chart);
                end
            end
        end
    end
end

-----------------------------------------------------------------------------------------------
-- Warning and errors
-----------------------------------------------------------------------------------------------

function create_warning_and_errors_tab()
    local tab = Tab(dictionary.error_and_warnings_tab[LANGUAGE]);
    tab:set_icon("shield-alert");
    tab:push_advices(advisor);
    return tab
end

function create_operation_report(dashboard, studies, info_struct, info_existence_log, create_dashboard)

    -- Function parameters
    -- dashboard: tab or dashboard object
    -- studies: number of studies loaded by PSRIO
    -- info_struct: struct containing SDDP execution information
    -- info_existence_log: array cointaing flags whether the information was loaded or not
    -- create_dashboard: flag that indicates if dashboard html must be created

    -- Collection arrays struct
    local col_struct = {
        battery         = {},
        bus             = {},
        circuit         = {},
        dclink          = {},
        generic         = {},
        hydro           = {},
        interconnection = {},
        power_injection = {},
        renewable       = {},
        csp             = {},
        study           = {},
        system          = {},
        thermal         = {},
        case_dir_list   = {}  -- Cases' directory names
    };

    -- Violation outputs and titles struct
    local viol_report_structs = {
        { name = "defcit"  , title = dictionary.defcit[LANGUAGE]},
        { name = "nedefc"  , title = dictionary.nedefc[LANGUAGE]},
        { name = "defbus"  , title = dictionary.defbus[LANGUAGE]},
        { name = "defbusp"  , title = dictionary.defbusp[LANGUAGE]},
        { name = "gncivio" , title = dictionary.gncivio[LANGUAGE]},
        { name = "gncvio"  , title = dictionary.gncvio[LANGUAGE]},
        { name = "vrestg"  , title = dictionary.vrestg[LANGUAGE]},
        { name = "excbus"  , title = dictionary.excbus[LANGUAGE]},
        { name = "excsis"  , title = dictionary.excsis[LANGUAGE]},
        { name = "vvaler"  , title = dictionary.vvaler[LANGUAGE]},
        { name = "vioguide", title = dictionary.vioguide[LANGUAGE]},
        { name = "vriego"  , title = dictionary.vriego[LANGUAGE]},
        { name = "vmxost"  , title = dictionary.vmxost[LANGUAGE]},
        { name = "vimxsp"  , title = dictionary.vimxsp[LANGUAGE]},
        { name = "vdefmx"  , title = dictionary.vdefmx[LANGUAGE]},
        { name = "vvolmn"  , title = dictionary.vvolmn[LANGUAGE]},
        { name = "vdefmn"  , title = dictionary.vdefmn[LANGUAGE]},
        { name = "vturmn"  , title = dictionary.vturmn[LANGUAGE]},
        { name = "vimnsp"  , title = dictionary.vimnsp[LANGUAGE]},
        { name = "rampvio" , title = dictionary.rampvio[LANGUAGE]},
        { name = "vreseg"  , title = dictionary.vreseg[LANGUAGE]},
        { name = "vsarhd"  , title = dictionary.vsarhd[LANGUAGE]},
        { name = "vsarhden", title = dictionary.vsarhden[LANGUAGE]},
        { name = "viocar"  , title = dictionary.viocar[LANGUAGE]},
        { name = "vgmint"  , title = dictionary.vgmint[LANGUAGE]},
        { name = "vgmntt"  , title = dictionary.vgmntt[LANGUAGE]},
        { name = "vioemiq" , title = dictionary.vioemiq[LANGUAGE]},
        { name = "vsecset" , title = dictionary.vsecset[LANGUAGE]},
        { name = "valeset" , title = dictionary.valeset[LANGUAGE]},
        { name = "vespset" , title = dictionary.vespset[LANGUAGE]},
        { name = "fcoffvio", title = dictionary.fcoffvio[LANGUAGE]},
        { name = "vflmnww" , title = dictionary.vflmnww[LANGUAGE]},
        { name = "vflmxww" , title = dictionary.vflmxww[LANGUAGE]},
        { name = "finjvio" , title = dictionary.finjvio[LANGUAGE]},
        {name = "lsserac_positive", title = dictionary.lsserac_pos[LANGUAGE]},
        {name = "lsserac_negative", title = dictionary.lsserac_neg[LANGUAGE]},
        {name = "lsserdc_positive", title = dictionary.lsserdc_pos[LANGUAGE]},
        {name = "lsserdc_negative", title = dictionary.lsserdc_neg[LANGUAGE]}
    }

    -- Loading study collections
    load_collections(col_struct);

    -- If at least one case does not have the .info file, info report is not displayed
    local create_info_report = true;
    for i = 1, #info_existence_log do
        if not info_existence_log[i] then
            create_info_report = false;
            break;
        end
    end

    -----------------------------------------------------------------------------------------------
    -- Dashboard tabs configuration
    -----------------------------------------------------------------------------------------------

    -- Dashboard name configuration
    local dashboard_name = "SDDP";
    if #info_struct > 0 and not (info_struct[1].dash_name == "-") then
        dashboard_name = info_struct[1].dash_name;
    end

    if studies > 1 then
        dashboard_name = dashboard_name .. "-compare";
    end

    ----------------
    -- Infeasibility
    ----------------
    local tab_inf = Tab(dictionary.tab_infeasibility[LANGUAGE]);
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

    local tab_solution_quality = Tab(dictionary.tab_solution_quality[LANGUAGE]);
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
    
    -- Execution times
    push_tab_to_tab(create_times_report(col_struct),tab_solution_quality);
    
    -- Finish solution quality
    push_tab_to_tab(tab_solution_quality, dashboard);

    ------------
    -- Violation
    ------------

    -- Violation tabs
    local tab_violations = Tab(dictionary.tab_violations[LANGUAGE]);
    local tab_viol_avg   = Tab(dictionary.tab_average[LANGUAGE]);
    local tab_viol_max   = Tab(dictionary.tab_maximum[LANGUAGE]);

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

    local tab_results = Tab(dictionary.tab_results[LANGUAGE]);
    tab_results:set_collapsed(true);
    tab_results:set_disabled();
    tab_results:set_icon("line-chart");
    
    push_tab_to_tab(create_marg_costs(col_struct)    ,tab_results);
    push_tab_to_tab(create_gen_report(col_struct)    ,tab_results);
    push_tab_to_tab(create_risk_report(col_struct)   ,tab_results);
    push_tab_to_tab(create_inflow_energy(col_struct) ,tab_results);

    push_tab_to_tab(tab_results,dashboard);

    ---------------------------
    -- Warning and error
    ---------------------------
    local warning_error_tab = create_warning_and_errors_tab();
    if #warning_error_tab > 0 then
        push_tab_to_tab(warning_error_tab,dashboard);
    end

    ---------------------------
    -- Case information summary
    ---------------------------
    if create_info_report then
        push_tab_to_tab(create_tab_summary(col_struct, info_struct),dashboard);
    end

    -- Save dashboard and return execution mode
    -- All cases must be of the same type (operation or expansion)
    if create_dashboard then
        dashboard:save(dashboard_name);
    end

end
