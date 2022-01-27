local Colors = {
    light_blue = "#ADD8E6",
    blue       = "#508EC1",
    red        = "#ff0029"
}

local function get_percentiles_chart(output, title)
    local chart = Chart(title);

    chart:add_area_range(
        output:aggregate_scenarios(BY_PERCENTILE(10)):rename_agents({"p10"}), 
        output:aggregate_scenarios(BY_PERCENTILE(90)):rename_agents({"p90"}), 
        {color = Colors.light_blue}
    );
    chart:add_line(output:aggregate_scenarios(BY_AVERAGE()), {color = Colors.red});

    return chart;
end

local function save_dashboard()
    local battery = Battery();
    local hydro = Hydro();
    local renewable = Renewable();
    local system = System();
    local thermal = Thermal();

    local dashboard_costs = Dashboard("Costs");
    dashboard_costs:set_icon("dollar-sign");
    dashboard_costs:push("# Costs");
    
    local cmgdem = system:load("cmgdem");
    if not cmgdem:is_hourly() then
        cmgdem = cmgdem:aggregate_blocks(BY_AVERAGE());
    end
    cmgdem_per_year = cmgdem:aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR);
    
    local chart = Chart("Load Marginal Cost per Year");
    chart:add_column(cmgdem_per_year:aggregate_scenarios(BY_AVERAGE()));
    dashboard_costs:push(chart);

    local chart = get_percentiles_chart(cmgdem, "Load Marginal Cost");
    dashboard_costs:push(chart);
    
    local dashboard_generation = Dashboard("Generation");
    dashboard_generation:set_icon("activity");
    dashboard_generation:push("# Generation");

    local gerter = thermal:load("gerter2"):aggregate_scenarios(BY_AVERAGE());
    if not gerter:is_hourly() then
        gerter = gerter:aggregate_blocks(BY_SUM());
    end
    gerter_per_system = gerter:aggregate_agents(BY_SUM(), Collection.SYSTEM);

    local gerhid = hydro:load("gerhid"):aggregate_scenarios(BY_AVERAGE());
    if not gerhid:is_hourly() then
        gerhid = gerhid:aggregate_blocks(BY_SUM());
    end
    local gerhid_per_system = gerhid:aggregate_agents(BY_SUM(), Collection.SYSTEM);

    local gergnd = renewable:load("gergnd"):aggregate_scenarios(BY_AVERAGE());
    if not gergnd:is_hourly() then
        gergnd = gergnd:aggregate_blocks(BY_SUM());
    end
    local gergnd_per_system = gergnd:aggregate_agents(BY_SUM(), Collection.SYSTEM);

    local gerbat = battery:load("gerbat"):aggregate_scenarios(BY_AVERAGE()):convert("GWh");
    if not gerbat:is_hourly() then
        gerbat = gerbat:aggregate_blocks(BY_SUM());
    end
    local gerbat_per_system = gerbat:aggregate_agents(BY_SUM(), Collection.SYSTEM);

    local demand = system:load("demand");
    if not demand:is_hourly() then
        demand = demand:aggregate_blocks(BY_SUM());
    end

    local chart = Chart("Total Generation");
    chart:add_area_stacking(gerter:aggregate_agents(BY_SUM(), "Total thermal"), {color="red"});
    chart:add_area_stacking(gerhid:aggregate_agents(BY_SUM(), "Total hydro"), {color="blue"});
    chart:add_area_stacking(gergnd:aggregate_agents(BY_SUM(), "Total renewables"), {color="green"});
    chart:add_area_stacking(gerbat:aggregate_agents(BY_SUM(), "Total battery"), {color="orange"});
    chart:add_line(demand:aggregate_agents(BY_SUM(), "Demand"), {color="purple"});
    dashboard_generation:push(chart);

    local agents_size = demand:agents_size();
    for i = 1,agents_size do
        local agent = demand:agent(i);
        local chart = Chart("Generation - " .. agent);
        chart:add_area_stacking(gerter_per_system:select_agent(i):rename_agent("Thermal"), {color="red"});
        chart:add_area_stacking(gerhid_per_system:select_agent(i):rename_agent("Hydro"), {color="blue"});
        chart:add_area_stacking(gergnd_per_system:select_agent(i):rename_agent("Renewables"), {color="green"});
        chart:add_area_stacking(gerbat_per_system:select_agent(i):rename_agent("Battery"), {color="orange"});
        chart:add_line(demand:select_agent(i):rename_agent("Demand"), {color="purple"});
        dashboard_generation:push(chart);
    end

    -- dashboard_volume = Dashboard("Initial Volume");
    -- dashboard_volume:set_icon("cloud-drizzle");
    -- dashboard_volume:push("# Initial Volume");
    
    (dashboard_costs + dashboard_generation):save("dashboard");    
end

save_dashboard();

-- local function push_market_dashboard(iteration, demand, dashboard_cmgdem, dashboard_generation, dashboard_volume)
--     local generic = Generic();

--     local cmgdem = generic:load(iteration .. "/cmgdem");
--     local defcit = generic:load(iteration .. "/defcit");
--     local gerter = generic:load(iteration .. "/gerter");
--     local gerhid = generic:load(iteration .. "/gerhid");
--     local volini = generic:load(iteration .. "/volini");

--     local chart = get_percentiles_chart(cmgdem, iteration);
--     dashboard_cmgdem:push("___");
--     dashboard_cmgdem:push(chart);
--     dashboard_cmgdem:push("___");

--     local thermals = { gerter:aggregate_agents(BY_SUM(), "ag0") };
--     local hydros = { gerhid:aggregate_agents(BY_SUM(), "ag0") };
--     local volinis = { volini:aggregate_agents(BY_SUM(), "ag0") };

--     local agents = generic:get_directories(iteration, "(ag_.*)");
--     for i = 1, #agents do 
--         local agent = agents[i];
--         table.insert(thermals, generic:load(iteration .. "/" .. agent .. "/gerter"):aggregate_agents(BY_SUM(), agent));
--         table.insert(hydros, generic:load(iteration .. "/" .. agent .. "/gerhid"):aggregate_agents(BY_SUM(), agent));
--         table.insert(volinis, generic:load(iteration .. "/" .. agent .. "/volini"):aggregate_agents(BY_SUM(), agent));
--     end
--     concatenate(thermals):save("gerter-" .. iteration);
--     concatenate(hydros):save("gerhid-" .. iteration);
--     concatenate(volinis):save("volini-" .. iteration);

--     local chart = Chart(iteration);
--     chart:add_area_stacking(concatenate(thermals):aggregate_scenarios(BY_AVERAGE()):add_prefix("Thermal "), {color="red"});
--     chart:add_area_stacking(concatenate(hydros):aggregate_scenarios(BY_AVERAGE()):add_prefix("Hydro "), {color="blue"});
--     chart:add_line(demand, {color="purple"});
--     chart:add_line(defcit:aggregate_scenarios(BY_AVERAGE()):rename_agents({"Deficit"}), {color="black"});
--     dashboard_generation:push("___");
--     dashboard_generation:push(chart);
--     dashboard_generation:push("___");

--     local chart = get_percentiles_chart(concatenate(volinis):aggregate_agents(BY_SUM(), "Initial Volume"), iteration);
--     dashboard_volume:push("___");
--     dashboard_volume:push(chart);
--     dashboard_volume:push("___");
-- end

-- dashboard_cmgdem = Dashboard("Load Marginal Cost");
-- dashboard_cmgdem:set_icon("dollar-sign");
-- dashboard_cmgdem:push("# Load Marginal Cost");

-- dashboard_generation = Dashboard("Generation");
-- dashboard_generation:set_icon("activity");
-- dashboard_generation:push("# Generation");

-- dashboard_volume = Dashboard("Initial Volume");
-- dashboard_volume:set_icon("cloud-drizzle");
-- dashboard_volume:push("# Initial Volume");

-- generic = Generic();
-- demand = generic:load("iter_init/demand"):rename_agents({"Demand"});

-- push_market_dashboard("iter_init", demand, dashboard_cmgdem, dashboard_generation, dashboard_volume);

-- iterations = generic:get_directories("(iter_[0-9]*)");
-- for i = 1, #iterations do 
--     local iteration = iterations[i];
--     push_market_dashboard(iteration, demand, dashboard_cmgdem, dashboard_generation, dashboard_volume);
-- end

-- (dashboard_cmgdem + dashboard_generation + dashboard_volume):save("dashboard_market");