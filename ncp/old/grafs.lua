function CMO_grf(N_cases,cgraf,chart_vec,NCP_data)
    if cgraf then
        chart = Chart();
    end
    for case = 1,N_cases do
        local case_n = tostring(case)
        local CMO = NCP_data[case].CMO[2];

        if( N_cases > 1 ) then
            CMO = CMO:add_suffix(" (C"..case_n..")");
        end
        
        if not cgraf then
            chart = Chart();
        end
        chart:add_line(CMO,{color = main_global_color[case]})
        if not cgraf then
            table.insert(chart_vec,chart);
        end
    end
    if cgraf then
        table.insert(chart_vec,chart);
    end

end

function Gen_Dem_grf(N_cases,cgraf,chart_vec,NCP_data)
    if cgraf then
        chart = Chart();
    end
    for case = 1,N_cases do
        local case_n = tostring(case)

        local Demand = NCP_data[case].demand[2]:aggregate_agents(BY_SUM(),"Demand");
        local Gerhid = NCP_data[case].genhid[2]:aggregate_agents(BY_SUM(),"Hydro Generation");
        local Gergnd = NCP_data[case].genren[2]:aggregate_agents(BY_SUM(),"Renewable Generation");
        local Gerter = NCP_data[case].genter[2]:aggregate_agents(BY_SUM(),"Thermal Generation");
        local Losses = NCP_data[case].losses[2]:aggregate_agents(BY_SUM(),"Losses");
        
        if( N_cases > 1 ) then
            Demand = Demand:add_suffix(" (C"..case_n..")");
            Gerhid = Gerhid:add_suffix(" (C"..case_n..")");
            Gergnd = Gergnd:add_suffix(" (C"..case_n..")");
            Gerter = Gerter:add_suffix(" (C"..case_n..")");
            Losses = Losses:add_suffix(" (C"..case_n..")");
        end
        if not cgraf then
            chart = Chart();
        end
        chart:add_line(Demand,{color = technology_color.demand})
        chart:add_area_stacking(Gerhid,{color = technology_color.hydro})
        chart:add_area_stacking(Gergnd,{color = technology_color.renewable})
        chart:add_area_stacking(Gerter,{color = technology_color.thermal})
        chart:add_area_stacking(Losses,{color = technology_color.losses})
        if not cgraf then
            table.insert(chart_vec,chart);
        end
    end
    if cgraf then
        table.insert(chart_vec,chart);
    end
    
end

function Tot_Gen_grf(N_cases,cgraf,chart_vec,NCP_data)
    if cgraf then
        chart = Chart();
    end
    for case = 1,N_cases do
        local case_n = tostring(case)

        local Gerhid = NCP_data[case].genhid[2]:aggregate_agents(BY_SUM(),"Hydro Generation")
                                               :aggregate_blocks(BY_SUM())
                                               :aggregate_stages(BY_SUM());
        local Gergnd = NCP_data[case].genren[2]:aggregate_agents(BY_SUM(),"Renewable Generation")
                                               :aggregate_blocks(BY_SUM())
                                               :aggregate_stages(BY_SUM());
        local Gerter = NCP_data[case].genter[2]:aggregate_agents(BY_SUM(),"Thermal Generation")
                                               :aggregate_blocks(BY_SUM())
                                               :aggregate_stages(BY_SUM());

        if( N_cases > 1 ) then
            Gerhid = Gerhid:add_suffix(" (C"..case_n..")");
            Gergnd = Gergnd:add_suffix(" (C"..case_n..")");
            Gerter = Gerter:add_suffix(" (C"..case_n..")");
        end

        if not cgraf then
            chart = Chart();
        end
        chart:add_pie(Gerhid,{color = technology_color.hydro})
        chart:add_pie(Gergnd,{color = technology_color.renewable})
        chart:add_pie(Gerter,{color = technology_color.thermal})

        if not cgraf then
            table.insert(chart_vec,chart);
        end
    end
    if cgraf then
        table.insert(chart_vec,chart);
    end
    
end

function OBJ_grf(N_cases,cgraf,chart_vec,NCP_data)
    if cgraf then
        chart = Chart();
    end
    for case = 1,N_cases do
        local case_n = tostring(case)

        local OBJ_cost = NCP_data[case].OBJ[2]:remove_zeros();

        if( N_cases > 1 ) then
            OBJ_cost = OBJ_cost:add_suffix(" (C"..case_n..")");
        end

        if not cgraf then
            chart = Chart();
        end

        chart:add_pie(OBJ_cost)

        if not cgraf then
            table.insert(chart_vec,chart);
        end
    end
    if cgraf then
        table.insert(chart_vec,chart);
    end
    
end