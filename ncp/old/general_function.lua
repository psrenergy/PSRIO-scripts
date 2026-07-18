--load func
function load(filename,N_cases)
    local NCP_base_vec = {};
    local NCP_dim_vec = {};
    local NCP_data_vec = {};

    for case = 1,N_cases do

        NCP_base.load_base(self,filename,case);
        NCP_dim.load_base(self,filename,case);
        NCP_data.load_data(self,case)

        table.insert(NCP_base_vec,NCP_base)
        table.insert(NCP_dim_vec,NCP_dim)
        table.insert(NCP_data_vec,NCP_data)
    end
    return NCP_base_vec, NCP_dim_vec, NCP_data_vec
end

-- trim
function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- sec to min
function sec_2_min(data)
    local time_sec = tonumber(data);
    local time_m = time_sec/60;
    return string.format("%.2f", tostring(time_m));
end
-- map name
function map_name(data,map_from,map_to,neather)
    if not( #map_from == #map_to) then
        error("map_from and map_to must be the same size")
    end
    for i,name in ipairs(map_from) do
        if( trim(data) == trim(name) ) then
            return map_to[i]
        end
    end
    if( neather ) then
        return neather
    end
    print(neather)
    error(data .. "was not mapped in the rigth way")
end

-- check existence
function check_ex(data,attribut,zero)
    local existence = data:loaded();
    if data:loaded() then
        table.insert(attribut ,data);
    else
        table.insert(attribut ,zero);
    end
    table.insert(attribut ,existence);
end

-- check status
function case_status(case,ele_status)
    local generic = Generic(case);
    if not( generic:file_exists("cpplus.ok") ) then
        ele_status = false;
        return "FAIL"
    end
    return "SUCCESS"
end

-- get cell
function get_cell(case,filename,col,line)
    local generic = Generic(case);
    local table_read = generic:load_table_without_header(filename);
    if( table_read[col][line] ) then
        return table_read[col][line]
    end
    return nil
end

-- load NCPCOPE
function load_NCPCOPE(case)
    local generic = Generic(case);

    local filename = "ncpcope.csv";

    local table_read = generic:load_table_without_header(filename);

    local aux = {};
    for lin = 2,#table_read do
        local name = table_read[lin][1];
        local data = table_read[lin][2];
        if( name ) then
            local data_graf = generic:create(name, "k$", { tonumber(data) });
            table.insert(aux,data_graf)
        end
    end

    return concatenate(aux)
    
end

-- DASHBOARD
-----------------------------------------------------------------------------------
-- case summary
function case_summary(N_cases,NCP_base,NCP_dim)

    local tab_main = Tab("Case Summary");

    --case_summary
    tab_main:push("# Case Summary");
    tab_main:push("| Case | Directory Name | Execution status | Execution Date |");
    tab_main:push("|:----:|:--------------:|:----------------:|:--------------:|");
    for case = 1,N_cases do
        table.insert(STATUS,true)

        local study = Study(case);
        local case_name = get_cell(case,"Sddpcp.dat",1,1)
        local case_dir = study:cloudname();
        local status = case_status(case,STATUS[case])
        local data = NCP_base[case].date[2];
        tab_main:push("| " .. case_name .. " | " .. case_dir .. " | " .. status .. " | " .. data .. " |");

    end

    --About the model
    tab_main:push("## About the model");
    tab_main:push("| Case | Model | User | Xpress Optimizer | Xpress Mosel |");
    tab_main:push("|:----:|:-----:|:----:|:----------------:|:------------:|");
    for case = 1,N_cases do
        local case_name = get_cell(case,"Sddpcp.dat",1,1)
        local modelo = NCP_base[case].modelo[2];
        local user = NCP_base[case].user[2];
        local xp_opt = NCP_base[case].xp_opt[2];
        local xp_mos = NCP_base[case].xp_mod[2];
        tab_main:push("| " .. case_name .. " | " .. modelo .. " | " .. user .. " | " .. xp_opt .. " | " .. xp_mos .. " |");

    end

    
    -- Horizon, resolution and execution options
    tab_main:push("## Horizon, resolution and execution options");
    local header_string       = "| Case parameter ";
    local lower_header_string = "|:--------------";
    local execution_mode      = "| Execution Mode ";
    local execution_criterion = "| Execution Criterion ";
    local execution_type      = "| Execution Type ";
    local rolling_horizon     = "| Rolling Horizon ";
    local heuristic_threads   = "| Heuristic Threads ";
    local MIP_threads         = "| MIP Threads ";
    local solver_heuristics   = "| Solver Heuristics ";
    local stage_number        = "| Stage Number ";
    local stage_resolution    = "| Stage Resolution ";
    local network             = "| Network Representation ";
    local transmission_losses = "| Transmission Losses ";
    for case = 1,N_cases do
        header_string       = header_string       .."| "..tostring(case).." ";
        lower_header_string = lower_header_string ..":|:--------------";
        execution_mode      = execution_mode      .."| "..NCP_base[case].mode[2];
        execution_criterion = execution_criterion .."| "..NCP_base[case].criteri[2];
        execution_type      = execution_type      .."| "..NCP_base[case].type[2];
        rolling_horizon     = rolling_horizon     .."| "..NCP_base[case].horizo[2];
        heuristic_threads   = heuristic_threads   .."| "..NCP_base[case].heuris[2];
        MIP_threads         = MIP_threads         .."| "..NCP_base[case].MIP[2];
        solver_heuristics   = solver_heuristics   .."| "..NCP_base[case].s_heuri[2];
        stage_number        = stage_number        .."| "..NCP_base[case].stages[2];
        stage_resolution    = stage_resolution    .."| "..NCP_base[case].stg_res[2];
        network             = network             .."| "..NCP_base[case].network[2];
        transmission_losses = transmission_losses .."| "..NCP_base[case].t_losse[2];
        

    end

    header_string       = header_string       .." |";
    lower_header_string = lower_header_string ..":|";
    execution_mode      = execution_mode      .." |";
    execution_criterion = execution_criterion .." |";
    execution_type      = execution_type      .." |";
    rolling_horizon     = rolling_horizon     .." |";
    heuristic_threads   = heuristic_threads   .." |";
    MIP_threads         = MIP_threads         .." |";
    solver_heuristics   = solver_heuristics   .." |";
    stage_number        = stage_number        .." |";
    stage_resolution    = stage_resolution    .." |";
    network             = network             .." |";
    transmission_losses = transmission_losses .." |";

    tab_main:push(header_string       );
    tab_main:push(lower_header_string );
    tab_main:push(execution_mode      );
    tab_main:push(execution_criterion );
    tab_main:push(execution_type      );
    tab_main:push(rolling_horizon     );
    tab_main:push(heuristic_threads   );
    tab_main:push(MIP_threads         );
    tab_main:push(solver_heuristics   );
    tab_main:push(stage_number        );
    tab_main:push(stage_resolution    );
    tab_main:push(network             );
    tab_main:push(transmission_losses );
    
    --Dimensions
    tab_main:push("## Dimensions");
    local header_string           = "| Case parameter ";
    local lower_header_string     = "|:--------------";
    local variables               = "| Decision Variables ";
    local constraints             = "| Constraints ";
    local entities                = "| Binary Variables ";
    local hydro_plant             = "| Hydro Plant ";
    local hydro_plant_commitment  = "| Hydro Plant Commitment ";
    local hydro_unit              = "| Hydro Unit ";
    local hydro_unit_commitment   = "| Hydro Unit Commitment ";
    local thermal_unit            = "| Thermal Unit ";
    local thermal_unit_commitment = "| Thermal Unit Commitment ";
    local renewable               = "| Renewable ";
    local battery                 = "| Battery ";
    local circuit                 = "| Circuit ";
    local bus                     = "| Bus ";
    
    for case = 1,N_cases do
        header_string           = header_string           .."| "..tostring(case).." ";
        lower_header_string     = lower_header_string     ..":|:--------------";
        variables               = variables               .."| "..NCP_dim[case].variabl[2];
        constraints             = constraints             .."| "..NCP_dim[case].constra[2];
        entities                = entities                .."| "..NCP_dim[case].entitie[2];
        hydro_plant             = hydro_plant             .."| "..NCP_dim[case].hyd_pla.normal[2];
        hydro_plant_commitment  = hydro_plant_commitment  .."| "..NCP_dim[case].hyd_pla.commt[2];
        hydro_unit              = hydro_unit              .."| "..NCP_dim[case].hyd_uni.normal[2];
        hydro_unit_commitment   = hydro_unit_commitment   .."| "..NCP_dim[case].hyd_uni.commt[2];
        thermal_unit            = thermal_unit            .."| "..NCP_dim[case].the_uni[2];
        thermal_unit_commitment = thermal_unit_commitment .."| "..NCP_dim[case].the_commt[2];
        renewable               = renewable               .."| "..NCP_dim[case].ren_pla[2];
        battery                 = battery                 .."| "..NCP_dim[case].battery[2];
        circuit                 = circuit                 .."| "..NCP_dim[case].circuit[2];
        bus                     = bus                     .."| "..NCP_dim[case].bus[2];
        
    end

    header_string           = header_string          .." |";
    lower_header_string     = lower_header_string    ..":|";
    variables               = variables              .." |";
    constraints             = constraints            .." |";
    entities                = entities               .." |";
    hydro_plant             = hydro_plant            .." |";
    hydro_plant_commitment  = hydro_plant_commitment .." |";
    hydro_unit              = hydro_unit             .." |";
    hydro_unit_commitment   = hydro_unit_commitment  .." |";
    thermal_unit            = thermal_unit           .." |";
    thermal_unit_commitment = thermal_unit_commitment.." |";
    renewable               = renewable              .." |";
    battery                 = battery                .." |";
    circuit                 = circuit                .." |";
    bus                     = bus                    .." |";

    tab_main:push(header_string           );
    tab_main:push(lower_header_string     );
    tab_main:push(variables               );
    tab_main:push(constraints             );
    tab_main:push(entities                );
    tab_main:push(hydro_plant             );
    tab_main:push(hydro_plant_commitment  );
    tab_main:push(hydro_unit              );
    tab_main:push(hydro_unit_commitment   );
    tab_main:push(thermal_unit            );
    tab_main:push(thermal_unit_commitment );
    tab_main:push(renewable               );
    tab_main:push(battery                 );
    tab_main:push(circuit                 );
    tab_main:push(bus                     );

    return tab_main

end

-- results
function results(N_cases,NCP_base,NCP_data_vec)

    local tab_res = Tab("Results");

    --Results
    tab_res:push("# Results Base");
    tab_res:push("| Case | Solver Time (min) | Relative Gap (%) |");
    tab_res:push("|:----:|:-----------------:|:----------------:|");
    for case = 1,N_cases do
        local case_name = get_cell(case,"Sddpcp.dat",1,1);
        if( N_cases>1 ) then
            case_name = case_name .. " (C" .. tostring(case) .. ")";
        end
        local s_time = NCP_base[case].s_time[2];
        local r_gap = NCP_base[case].r_gap[2];
        tab_res:push("| " .. case_name .. " | " .. s_time .. " | " .. r_gap .. " |");

    end

    -- charts
    local CMO_charts      = {};
    local Gen_Dem_charts  = {};
    local GenTotal_charts = {};
    local ObjC_charts     = {};

    -- CMO chart
    tab_res:push("## Marginal Cost of Demand")
    CMO_grf(N_cases,single,CMO_charts,NCP_data_vec)
    for _,chart in ipairs(CMO_charts) do
        if ( chart ) then
            tab_res:push(chart);
        else
            tab_res:push("cmgdemcp was not found");
        end
    end

    -- Generation x Demand chart
    tab_res:push("## Generation x Demand")
    Gen_Dem_grf(N_cases,mult,Gen_Dem_charts,NCP_data_vec)
    for _,chart in ipairs(Gen_Dem_charts) do
        if ( chart ) then
            tab_res:push(chart);
        else
            tab_res:push("Any Generation x Demand data was not found");
        end
    end

    -- Total Generation
    tab_res:push("## Total Generation")
    Tot_Gen_grf(N_cases,mult,GenTotal_charts,NCP_data_vec)
    for _,chart in ipairs(GenTotal_charts) do
        if ( chart ) then
            tab_res:push(chart);
        else
            tab_res:push("Any Total Generation data was not found");
        end
    end

    -- Operating Cost
    tab_res:push("## Operating Cost")
    OBJ_grf(N_cases,mult,ObjC_charts,NCP_data_vec)
    for _,chart in ipairs(ObjC_charts) do
        if ( chart ) then
            tab_res:push(chart);
        else
            tab_res:push("Any Operating Cost data was not found");
        end
    end

    return tab_res
end
-----------------------------------------------------------------------------------