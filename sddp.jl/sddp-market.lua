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

local function push_market_dashboard(iteration, demand, dashboard_cmgdem, dashboard_generation, dashboard_volume)
    local generic = Generic();

    local cmgdem = generic:load(iteration .. "/cmgdem");
    local defcit = generic:load(iteration .. "/defcit");
    local gerter = generic:load(iteration .. "/gerter");
    local gerhid = generic:load(iteration .. "/gerhid");
    local volini = generic:load(iteration .. "/volini");

    local chart = get_percentiles_chart(cmgdem, iteration);
    dashboard_cmgdem:push(chart);

    local thermals = { gerter:aggregate_agents(BY_SUM(), "ag0") };
    local hydros = { gerhid:aggregate_agents(BY_SUM(), "ag0") };
    local volinis = { volini:aggregate_agents(BY_SUM(), "ag0") };

    local agents = generic:get_directories(iteration, "(ag_[0-9]+$)");
    for i = 1, #agents do 
        local agent = agents[i];
        table.insert(thermals, generic:load(iteration .. "/" .. agent .. "/gerter"):aggregate_agents(BY_SUM(), agent));
        table.insert(hydros, generic:load(iteration .. "/" .. agent .. "/gerhid"):aggregate_agents(BY_SUM(), agent));
        table.insert(volinis, generic:load(iteration .. "/" .. agent .. "/volini"):aggregate_agents(BY_SUM(), agent));
    end
    concatenate(thermals):save("gerter-" .. iteration);
    concatenate(hydros):save("gerhid-" .. iteration);
    concatenate(volinis):save("volini-" .. iteration);

    local chart = Chart(iteration);
    chart:add_area_stacking(concatenate(thermals):aggregate_scenarios(BY_AVERAGE()):add_prefix("Thermal "), {color="red"});
    chart:add_area_stacking(concatenate(hydros):aggregate_scenarios(BY_AVERAGE()):add_prefix("Hydro "), {color="blue"});
    chart:add_line(demand, {color="purple"});
    chart:add_line(defcit:aggregate_scenarios(BY_AVERAGE()):rename_agents({"Deficit"}), {color="black"});
    dashboard_generation:push(chart);

    local chart = get_percentiles_chart(concatenate(volinis):aggregate_agents(BY_SUM(), "Initial Volume"), iteration);
    dashboard_volume:push(chart);
end

dashboard_cmgdem = Dashboard("Load Marginal Cost");
dashboard_cmgdem:set_icon("dollar-sign");

dashboard_generation = Dashboard("Generation");
dashboard_generation:set_icon("activity");

dashboard_volume = Dashboard("Initial Volume");
dashboard_volume:set_icon("cloud-drizzle");

generic = Generic();
demand = generic:load("iter_init/demand"):rename_agents({"Demand"});

push_market_dashboard("iter_init", demand, dashboard_cmgdem, dashboard_generation, dashboard_volume);

iterations = generic:get_directories("(iter_[0-9]*)");
for i = 1, #iterations do 
    local iteration = iterations[i];
    push_market_dashboard(iteration, demand, dashboard_cmgdem, dashboard_generation, dashboard_volume);
end

(dashboard_cmgdem + dashboard_generation + dashboard_volume):save("dashboard_market");