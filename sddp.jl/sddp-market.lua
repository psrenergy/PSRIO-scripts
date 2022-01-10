local function get_percentiles_chart(output, title)
    local light_blue = "#ADD8E6";
    local orange = "#FFA500";

    local chart = Chart(title);
    chart:add_area_range(
        output:aggregate_scenarios(BY_PERCENTILE(10)):rename_agents({"p10"}), 
        output:aggregate_scenarios(BY_PERCENTILE(90)):rename_agents({"p90"}), 
        {color=light_blue}
    );
    chart:add_area_range(
        output:aggregate_scenarios(BY_PERCENTILE(25)):rename_agents({"p25"}), 
        output:aggregate_scenarios(BY_PERCENTILE(75)):rename_agents({"p75"}), 
        {color=light_blue}
    );
    chart:add_line(output:aggregate_scenarios(BY_AVERAGE()), {color=orange});

    return chart;
end

iterations = PSR.studies();

dashboard_cmgdem = Dashboard("Load Marginal Cost");
dashboard_cmgdem:set_icon("dollar-sign");

dashboard_generation = Dashboard("Generation");
dashboard_generation:set_icon("activity");

dashboard_volume = Dashboard("Initial Volume");
dashboard_volume:set_icon("cloud-drizzle");

dashboard_volume = Dashboard("Initial Volume");

for iteration = 1, iterations do 
    local iteration_label = "Iteration " .. (iteration - 2);
    local generic = Generic(iteration);

    local cmgdem = generic:load("cmgdem"):set_stage_type(1);
    local demand = generic:load("demand"):set_stage_type(1);
    local defcit = generic:load("defcit"):set_stage_type(1);
    local gerter = generic:load("gerter"):set_stage_type(1);
    local gerhid = generic:load("gerhid"):set_stage_type(1);
    local volini = generic:load("volini"):set_stage_type(1);

    local chart = get_percentiles_chart(cmgdem, iteration_label);
    dashboard_cmgdem:push(chart);

    local thermals = { gerter:aggregate_agents(BY_SUM(), "ag0") };
    local hydros = { gerhid:aggregate_agents(BY_SUM(), "ag0") };
    local volinis = { volini:aggregate_agents(BY_SUM(), "ag0") };

    local agents = generic:get_directories("(ag_.*)");
    for i = 1, #agents do 
        local agent = agents[i];
        table.insert(thermals, generic:load(agent .. "/gerter"):set_stage_type(1):aggregate_agents(BY_SUM(), agent));
        table.insert(hydros, generic:load(agent .. "/gerhid"):set_stage_type(1):aggregate_agents(BY_SUM(), agent));
        table.insert(volinis, generic:load(agent .. "/volini"):set_stage_type(1):aggregate_agents(BY_SUM(), agent));
    end
    local thermals_concatenated = concatenate(thermals):save_and_load("gerter-iter_" .. iteration);
    local hydros_concatenated = concatenate(hydros):save_and_load("gerhid-iter_" .. iteration);
    local volinis_concatenated = concatenate(volinis):save_and_load("volini-iter_" .. iteration);

    local chart = Chart(iteration_label);
    chart:add_area_stacking(thermals_concatenated:aggregate_agents(BY_SUM(), "Thermal"):aggregate_scenarios(BY_AVERAGE()));
    chart:add_area_stacking(hydros_concatenated:aggregate_agents(BY_SUM(), "Hydro"):aggregate_scenarios(BY_AVERAGE()));

    chart:add_line(demand:rename_agents({"Demand"}));
    chart:add_line(defcit:aggregate_scenarios(BY_AVERAGE()):rename_agents({"Deficit"}));
    dashboard_generation:push(chart);

    local chart = get_percentiles_chart(volinis_concatenated:aggregate_agents(BY_SUM(), "Initial Volume"), iteration_label);
    dashboard_volume:push(chart);
end

(dashboard_cmgdem + dashboard_generation + dashboard_volume):save("dashboard_market");
