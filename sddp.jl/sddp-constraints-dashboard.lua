PSR.assert_version(">0.16.0");

local hydro = Hydro();

local function add_aggregated_chart(tab, output)
    local label = output .. "_aggregated";

    hydro:load(output)
        :aggregate_agents(BY_SUM(), "Total Hydro")
        :aggregate_scenarios(BY_AVERAGE())
        :aggregate_blocks(BY_SUM())
        :save(label);
    
    local chart = Chart();
    chart:push(label, "line");
    tab:push(chart);
end

local tab = Tab();
add_aggregated_chart(tab, "volfin_last_block");
add_aggregated_chart(tab, "constraint_max_total_outflow");
add_aggregated_chart(tab, "constraint_min_total_outflow");
add_aggregated_chart(tab, "constraint_min_turbining");
-- to do: irrigation
add_aggregated_chart(tab, "constraint_max_spillage");
add_aggregated_chart(tab, "constraint_min_spillage");
add_aggregated_chart(tab, "constraint_max_target");
add_aggregated_chart(tab, "constraint_min_target");
add_aggregated_chart(tab, "MinBioSpillage");
add_aggregated_chart(tab, "constraint_max_volume");
add_aggregated_chart(tab, "constraint_min_volume");
add_aggregated_chart(tab, "constraint_alert_storage");

local dashboard = Dashboard();
dashboard:push(tab);
dashboard:save("constraints_violation_report");
