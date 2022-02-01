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

local function get_dashboard_costs(title, suffix)
    local system = System();
    local cmgdem = system:load("cmgdem" .. (suffix or ""));

    local dashboard = Dashboard(title);
    dashboard:set_icon("dollar-sign");
    dashboard:push("# " .. title);

    -- LOAD MARGINAL COST PER YEAR --
    local chart = Chart("Load Marginal Cost per Year");
    chart:add_column(
        cmgdem:aggregate_scenarios(BY_AVERAGE()):aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR)
    );
    dashboard:push(chart);

    -- LOAD MARGINAL COST --
    if not cmgdem:is_hourly() then
        cmgdem = cmgdem:aggregate_blocks(BY_AVERAGE());
    end
    local chart = get_percentiles_chart(cmgdem:aggregate_agents(BY_SUM(), "All systems"), "Load Marginal Cost");
    dashboard:push(chart);

    -- LOAD MARGINAL COST PER SYSTEM --
    local agents_size = cmgdem:agents_size();
    if agents_size > 1 then
        for i = 1,agents_size do
            local agent = cmgdem:agent(i);
            local chart = get_percentiles_chart(cmgdem:select_agent(agent), "Load Marginal Cost - " .. agent);
            dashboard:push(chart);
        end
    end

    return dashboard;
end

local function get_dashboard_generation(title, suffix)
    local battery = Battery();
    local hydro = Hydro();
    local renewable = Renewable();
    local system = System();
    local thermal = Thermal();
    
    local dashboard = Dashboard(title);
    dashboard:set_icon("activity");
    dashboard:push("# " .. title);

    local gerter = thermal:load("gerter2" .. (suffix or "")):aggregate_scenarios(BY_AVERAGE());
    if not gerter:is_hourly() then
        gerter = gerter:aggregate_blocks(BY_SUM());
    end
    local gerter_per_system = gerter:aggregate_agents(BY_SUM(), Collection.SYSTEM);

    local gerhid = hydro:load("gerhid" .. (suffix or "")):aggregate_scenarios(BY_AVERAGE());
    if not gerhid:is_hourly() then
        gerhid = gerhid:aggregate_blocks(BY_SUM());
    end
    local gerhid_per_system = gerhid:aggregate_agents(BY_SUM(), Collection.SYSTEM);

    local gergnd = renewable:load("gergnd" .. (suffix or "")):aggregate_scenarios(BY_AVERAGE());
    if not gergnd:is_hourly() then
        gergnd = gergnd:aggregate_blocks(BY_SUM());
    end
    local gergnd_per_system = gergnd:aggregate_agents(BY_SUM(), Collection.SYSTEM);

    local gerbat = battery:load("gerbat" .. (suffix or "")):aggregate_scenarios(BY_AVERAGE()):convert("GWh");
    if not gerbat:is_hourly() then
        gerbat = gerbat:aggregate_blocks(BY_SUM());
    end
    local gerbat_per_system = gerbat:aggregate_agents(BY_SUM(), Collection.SYSTEM);

    local demand = system:load("demand" .. (suffix or ""));
    if not demand:is_hourly() then
        demand = demand:aggregate_blocks(BY_SUM());
    end

    -- GENERATION --
    local chart = Chart("Total Generation");
    chart:add_area_stacking(gerter:aggregate_agents(BY_SUM(), "Total thermal"), {color="red"});
    chart:add_area_stacking(gerhid:aggregate_agents(BY_SUM(), "Total hydro"), {color="blue"});
    chart:add_area_stacking(gergnd:aggregate_agents(BY_SUM(), "Total renewables"), {color="green"});
    chart:add_area_stacking(gerbat:aggregate_agents(BY_SUM(), "Total battery"), {color="orange"});
    chart:add_line(demand:aggregate_agents(BY_SUM(), "Demand"), {color="purple"});
    dashboard:push(chart);

    -- GENERATION PER SYSTEM --
    local agents_size = demand:agents_size();
    if agents_size > 1 then
        for i = 1,agents_size do
            local agent = demand:agent(i);
            local chart = Chart("Generation - " .. agent);
            chart:add_area_stacking(gerter_per_system:select_agent(agent):rename_agent("Thermal"), {color="red"});
            chart:add_area_stacking(gerhid_per_system:select_agent(agent):rename_agent("Hydro"), {color="blue"});
            chart:add_area_stacking(gergnd_per_system:select_agent(agent):rename_agent("Renewables"), {color="green"});
            chart:add_area_stacking(gerbat_per_system:select_agent(agent):rename_agent("Battery"), {color="orange"});
            chart:add_line(demand:select_agent(agent):rename_agent("Demand"), {color="purple"});
            dashboard:push(chart);
        end
    end

    return dashboard;
end

local function save_dashboard()
    local study = Study();
    if study:is_genesys() then
        local costs__week = get_dashboard_costs("Costs (week)", "__week");
        local costs__day = get_dashboard_costs("Costs (day)", "__day");
        local costs__hour = get_dashboard_costs("Costs (hour)", "__hour");
        local costs__trueup = get_dashboard_costs("Costs (trueup)", "__trueup");

        local generation__week = get_dashboard_generation("Generation (week)", "__week");
        local generation__day = get_dashboard_generation("Generation (day)", "__day");
        local generation__hour = get_dashboard_generation("Generation (hour)", "__hour");
        local generation__trueup = get_dashboard_generation("Generation (trueup)", "__trueup");

        local dashboard =
            costs__week +
            costs__day +
            costs__hour +
            costs__trueup +
            generation__week +
            generation__day +
            generation__hour +
            generation__trueup;
        dashboard:save("dashboard");
    else
        local costs = get_dashboard_costs("Costs");
        local generation = get_dashboard_generation("Generation");   
        local dashboard = costs + generation;
        dashboard:save("dashboard");
    end
end

save_dashboard();