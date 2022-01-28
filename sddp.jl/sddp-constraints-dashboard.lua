local hydro = Hydro();

function add_aggregated_chart(dashboard, output)
    local label = output .. "_aggregated";

    hydro:load(output)
        :aggregate_agents(BY_SUM(), "Total Hydro")
        :aggregate_scenarios(BY_AVERAGE())
        :aggregate_blocks(BY_SUM())
        :save(label);
    
    local chart = Chart();
    chart:push(label, "line");
    dashboard:push(chart);
end

local dashboard = Dashboard();
add_aggregated_chart(dashboard, "volfin_last_block");
add_aggregated_chart(dashboard, "constraint_max_total_outflow");
add_aggregated_chart(dashboard, "constraint_min_total_outflow");
add_aggregated_chart(dashboard, "constraint_min_turbining");
-- to do: irrigation
add_aggregated_chart(dashboard, "constraint_max_spillage");
add_aggregated_chart(dashboard, "constraint_min_spillage");
add_aggregated_chart(dashboard, "constraint_max_target");
add_aggregated_chart(dashboard, "constraint_min_target");
add_aggregated_chart(dashboard, "MinBioSpillage");
add_aggregated_chart(dashboard, "constraint_max_volume");
add_aggregated_chart(dashboard, "constraint_min_volume");
add_aggregated_chart(dashboard, "constraint_alert_storage");
dashboard:save("constraints_violation_report");
