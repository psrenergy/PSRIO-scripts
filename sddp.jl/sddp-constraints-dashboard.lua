local hydro = require("collection/hydro");

function add_chart (dashboard, constraint)
    local constraint_agg = hydro:load(constraint);
    print("hello world")
    if type(constraint) ~= "string" then
        return nil, "Check argument type. Received a" .. type(constraint) ..". Should be a string."
    end
    print(type(constraint))
    print(constraint)
    name_agg = constraint .. "_agg"
    print(name_agg)
    constraint_agg = constraint_agg:aggregate_agents(BY_SUM(), "Total Hydro");
    constraint_agg = constraint_agg:aggregate_scenarios(BY_AVERAGE());
    constraint_agg = constraint_agg:aggregate_blocks(BY_SUM());
    constraint_agg:save(name_agg)
    chart = Chart();
    chart:push(name_agg, "line");
    dashboard:push(chart)
    return nil
end

dashboard = Dashboard();

add_chart(dashboard, "volfin_")
add_chart(dashboard, "constraint_max_total_outflow")
add_chart(dashboard, "constraint_min_total_outflow")
add_chart(dashboard, "constraint_min_turbining")
-- to do: irrigation
add_chart(dashboard, "constraint_max_spillage")
add_chart(dashboard, "constraint_min_spillage")
add_chart(dashboard, "constraint_max_target")
add_chart(dashboard, "constraint_min_target")
add_chart(dashboard, "MinBioSpillage")
add_chart(dashboard, "constraint_max_volume")
add_chart(dashboard, "constraint_min_volume")
add_chart(dashboard, "constraint_alert_storage")

dashboard:save("constraints_violation_report")
