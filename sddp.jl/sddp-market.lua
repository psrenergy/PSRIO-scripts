local function get_percentiles_chart(output, title)
    local light_blue = "#ADD8E6";
    local orange = "#FFA500";

    local chart = Chart(title);

    for i = 1,output:agents_size() do
        chart:add_area_range(
            output:select_agent(i):rename_agents({"p10"}):aggregate_scenarios(BY_PERCENTILE(10)),
            output:select_agent(i):rename_agents({"p90"}):aggregate_scenarios(BY_PERCENTILE(90)),
            {color=light_blue}
        );
        chart:add_area_range(
            output:select_agent(i):rename_agents({"p25"}):aggregate_scenarios(BY_PERCENTILE(25)),
            output:select_agent(i):rename_agents({"p75"}):aggregate_scenarios(BY_PERCENTILE(75)),
            {color=light_blue}
        );
        chart:add_line(output:select_agent(i):aggregate_scenarios(BY_AVERAGE()), {color=orange});
    end


    return chart;
end

-- load collections
local generic = Generic();

-- create dashboard tabs
local dashboard_cmgdem = Dashboard("Load Marginal Cost");
dashboard_cmgdem:set_icon("dollar-sign");

local dashboard_generation = Dashboard("Generation");
dashboard_generation:set_icon("activity");

local dashboard_volume = Dashboard("Initial Volume");
dashboard_volume:set_icon("cloud-drizzle");

-- load demand
local demand = generic:load("iter_init/demand"):rename_agents({"Demand"});

-- get the directories of the iterations
local iterations = generic:get_directories("(iter_[0-9]*)");

-- sort the iterations based on their number
table.sort(iterations, function (a, b) return (tonumber(string.match(a, "%d+")) < tonumber(string.match(b, "%d+"))) end)

-- insert the "iter_init" directory at the beginning of the list
table.insert(iterations, 1, "iter_init");

local aggregated_generation_thermals = {};
local aggregated_generation_hydros = {};
local aggregated_generation_deficit = {};

for i = 1, #iterations do
    local iteration = iterations[i];

    local cmgdem = generic:load(iteration .. "/cmgdem");
    local defcit = generic:load(iteration .. "/defcit");
    local gerter = generic:load(iteration .. "/gerter");
    local gerhid = generic:load(iteration .. "/gerhid");
    local volini = generic:load(iteration .. "/volini");
    local eneemb = generic:load(iteration .. "/eneemb");

    local chart = get_percentiles_chart(cmgdem, iteration);
    dashboard_cmgdem:push(chart);

    local thermals = { gerter:aggregate_agents(BY_SUM(), "ag0") };
    local hydros = { gerhid:aggregate_agents(BY_SUM(), "ag0") };
    local volinis = { volini:aggregate_agents(BY_SUM(), "ag0") };
	local eneembs = { eneemb:aggregate_agents(BY_SUM(), "ag0") };

    local agents = generic:get_directories(iteration, "(ag_[0-9]+$)");
    for j = 1, #agents do
        local agent = agents[j];
        table.insert(thermals, generic:load(iteration .. "/" .. agent .. "/gerter"):aggregate_agents(BY_SUM(), agent));
        table.insert(hydros, generic:load(iteration .. "/" .. agent .. "/gerhid"):aggregate_agents(BY_SUM(), agent));
        table.insert(volinis, generic:load(iteration .. "/" .. agent .. "/volini"):aggregate_agents(BY_SUM(), agent));
		table.insert(eneembs, generic:load(iteration .. "/" .. agent .. "/eneemb"):aggregate_agents(BY_SUM(), agent));
    end

    local concatenated_thermals = concatenate(thermals):save_and_load("gerter-" .. iteration):aggregate_scenarios(BY_AVERAGE()):add_prefix("Thermal ");
    local concatenated_hydros = concatenate(hydros):save_and_load("gerhid-" .. iteration):aggregate_scenarios(BY_AVERAGE()):add_prefix("Hydro ");
    local concatenated_volinis = concatenate(volinis):save_and_load("volini-" .. iteration);
	local concatenated_eneembs = concatenate(eneembs):save_and_load("eneemb-" .. iteration);

    local chart = Chart(iteration);
    chart:add_area_stacking(concatenated_thermals, {color="red"});
    chart:add_area_stacking(concatenated_hydros, {color="blue"});
    chart:add_line(demand, {color="purple"});
    chart:add_line(defcit:aggregate_scenarios(BY_AVERAGE()):rename_agents({"Deficit"}), {color="black"});
    dashboard_generation:push(chart);

    for j = 1, concatenated_thermals:agents_size() do
        local agent = concatenated_thermals:agent(j);
        if aggregated_generation_thermals[agent] == nil then
            aggregated_generation_thermals[agent] = {};
        end
        table.insert(aggregated_generation_thermals[agent], concatenated_thermals:select_agent(agent):aggregate_stages(BY_SUM()));
    end

    for j = 1, concatenated_hydros:agents_size() do
        local agent = concatenated_hydros:agent(j);
        if aggregated_generation_hydros[agent] == nil then
            aggregated_generation_hydros[agent] = {};
        end
        table.insert(aggregated_generation_hydros[agent], concatenated_hydros:select_agent(agent):aggregate_stages(BY_SUM()));
    end

    table.insert(aggregated_generation_deficit, defcit:aggregate_scenarios(BY_AVERAGE()):rename_agents({"Deficit"}):aggregate_stages(BY_SUM()));

    local chart = get_percentiles_chart(concatenated_eneembs:aggregate_agents(BY_SUM(), "Initial Volume"), iteration);
	dashboard_volume:push(chart);

    local chart = get_percentiles_chart(concatenated_eneembs, iteration);
    dashboard_volume:push(chart);
end

local chart_aggregated_generation = Chart("Aggregated Generation");
for _, v in pairs(aggregated_generation_thermals) do
    chart_aggregated_generation:add_column_stacking(concatenate_stages(v):set_stage_type(0), {color="red"});
end

for _, v in pairs(aggregated_generation_hydros) do
    chart_aggregated_generation:add_column_stacking(concatenate_stages(v):set_stage_type(0), {color="blue"});
end

chart_aggregated_generation:add_column_stacking(concatenate_stages(aggregated_generation_deficit):set_stage_type(0), {color="black"});


-- chart_aggregated_generation:add_column_stacking(concatenate_stages(aggregated_generation_thermals):set_stage_type(0), {color="blue"});
dashboard_generation:push(chart_aggregated_generation);

(dashboard_cmgdem + dashboard_generation + dashboard_volume):save("dashboard_market");