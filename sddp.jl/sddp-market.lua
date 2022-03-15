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
local hydro = Hydro();

-- create dashboard tabs
local dashboard_costs = Dashboard("Marginal Costs");
dashboard_costs:set_icon("dollar-sign");

local dashboard_generation = Dashboard("Generation");
dashboard_generation:set_icon("activity");

local dashboard_revenue = Dashboard("Revenue");
dashboard_revenue:set_icon("activity");

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

-- local aggregated_generation = {};
local all_gerter = {};
local all_gerhid = {};
local all_defcit = {};
local all_cmgdem = {};

local function aggregate_and_concatenate_stages(v, f)
    local new_v = {};
    for key, value in pairs(v) do
        table.insert(new_v, value:aggregate_stages(f));
    end
    return concatenate_stages(new_v):set_stage_type(0);
end

for i = 1, #iterations do
    local iteration = iterations[i];

    local cmgdem = generic:load(iteration .. "/cmgdem");
    local defcit = generic:load(iteration .. "/defcit"):aggregate_scenarios(BY_AVERAGE()):rename_agents({"Deficit"});

    local chart = get_percentiles_chart(cmgdem, iteration);
    dashboard_costs:push(chart);

    local gerter = { generic:load(iteration .. "/gerter"):aggregate_agents(BY_SUM(), "ag0") };
    local gerhid = { generic:load(iteration .. "/gerhid"):aggregate_agents(BY_SUM(), "ag0") };
    local gergnd = { generic:load(iteration .. "/gergnd"):aggregate_agents(BY_SUM(), "ag0") };
    local volini = { generic:load(iteration .. "/volini"):aggregate_agents(BY_SUM(), "ag0") };
	local eneemb = { generic:load(iteration .. "/eneemb"):aggregate_agents(BY_SUM(), "ag0") };
	local bid_accepted = { generic:load(iteration .. "/bid_accepted_0"):aggregate_agents(BY_SUM(), "ag0") };
	local bid_price = { generic:load(iteration .. "/bid_price_0"):aggregate_agents(BY_SUM(), "ag0") };

    local agents = generic:get_directories(iteration, "(ag_[0-9]+$)");
    for j = 1, #agents do
        local agent = agents[j];
        local index = string.match(agent, "%d+");

        table.insert(gerter, generic:load(iteration .. "/" .. agent .. "/gerter"):aggregate_agents(BY_SUM(), agent));
        table.insert(gerhid, generic:load(iteration .. "/" .. agent .. "/gerhid"):aggregate_agents(BY_SUM(), agent));
        table.insert(gergnd, generic:load(iteration .. "/" .. agent .. "/gergnd"):aggregate_agents(BY_SUM(), agent));
        table.insert(volini, generic:load(iteration .. "/" .. agent .. "/volini"):aggregate_agents(BY_SUM(), agent));
		table.insert(eneemb, generic:load(iteration .. "/" .. agent .. "/eneemb"):aggregate_agents(BY_SUM(), agent));
		table.insert(bid_accepted, generic:load(iteration .. "/bid_accepted_" .. index):aggregate_agents(BY_SUM(), agent));
		table.insert(bid_price, generic:load(iteration .. "/bid_price_" .. index):aggregate_agents(BY_SUM(), agent));
    end

    local concatenated_gerter = concatenate(gerter):save_and_load("gerter-" .. iteration):add_prefix("Thermal ");
    local concatenated_gerhid = concatenate(gerhid):save_and_load("gerhid-" .. iteration):add_prefix("Hydro ");
    local concatenated_gergnd = concatenate(gergnd):save_and_load("gergnd-" .. iteration):add_prefix("Renewable ");
    local concatenated_volini = concatenate(volini):save_and_load("volini-" .. iteration);
	local concatenated_eneemb = concatenate(eneemb):save_and_load("eneemb-" .. iteration);
	local concatenated_bid_accepted = concatenate(bid_accepted):save_and_load("bid_accepted-" .. iteration);
	local concatenated_bid_price = concatenate(bid_price):save_and_load("bid_price-" .. iteration);

    local chart = Chart(iteration);
    chart:add_area_stacking(concatenated_gerter:aggregate_scenarios(BY_AVERAGE()), {color="red"});
    chart:add_area_stacking(concatenated_gerhid:aggregate_scenarios(BY_AVERAGE()), {color="blue"});
    chart:add_area_stacking(concatenated_gergnd:aggregate_scenarios(BY_AVERAGE()), {color="green"});
    chart:add_line(demand, {color="purple"});
    chart:add_line(defcit, {color="black"});
    dashboard_generation:push(chart);

    for j = 1, concatenated_gerter:agents_size() do
        local agent = concatenated_gerter:agent(j);
        if all_gerter[agent] == nil then
            all_gerter[agent] = {};
        end
        table.insert(all_gerter[agent], concatenated_gerter:select_agent(agent));
    end

    for j = 1, concatenated_gerhid:agents_size() do
        local agent = concatenated_gerhid:agent(j);
        if all_gerhid[agent] == nil then
            all_gerhid[agent] = {};
        end
        table.insert(all_gerhid[agent], concatenated_gerhid:select_agent(agent));
    end

    table.insert(all_defcit, defcit);

    table.insert(all_cmgdem, cmgdem:aggregate_scenarios(BY_AVERAGE()));

    local chart = Chart(iteration);
    chart:add_area_stacking((concatenated_gerter * cmgdem):aggregate_scenarios(BY_AVERAGE()), {color="red"});
    chart:add_area_stacking((concatenated_gerhid * cmgdem):aggregate_scenarios(BY_AVERAGE()), {color="blue"});
    chart:add_area_stacking((concatenated_gergnd * cmgdem):aggregate_scenarios(BY_AVERAGE()), {color="green"});
    chart:add_line((demand * cmgdem):aggregate_scenarios(BY_AVERAGE()), {color="purple"});
    chart:add_line((defcit * cmgdem):aggregate_scenarios(BY_AVERAGE()), {color="black"});
    dashboard_revenue:push(chart);

    local chart = get_percentiles_chart(concatenated_eneemb:aggregate_agents(BY_SUM(), "Initial Volume"), iteration);
	dashboard_volume:push(chart);

    local chart = get_percentiles_chart(concatenated_eneemb, iteration);
    dashboard_volume:push(chart);
end

local cmgdem = aggregate_and_concatenate_stages(all_cmgdem, BY_AVERAGE()):save_cache();
local defcit = aggregate_and_concatenate_stages(all_defcit, BY_SUM()):save_cache();

local chart = Chart("Aggregated Load Marginal Cost");
chart:add_column_stacking(cmgdem);
dashboard_costs:push(chart);

local chart = Chart("Aggregated Generation");
for _, v in pairs(all_gerter) do
    chart:add_column_stacking(aggregate_and_concatenate_stages(v, BY_SUM()):aggregate_scenarios(BY_AVERAGE()), {color="red"});
end
for _, v in pairs(all_gerhid) do
    chart:add_column_stacking(aggregate_and_concatenate_stages(v, BY_SUM()):aggregate_scenarios(BY_AVERAGE()), {color="blue"});
end
chart:add_column_stacking(defcit, {color="black"});
dashboard_generation:push(chart);

local chart = Chart("Aggregated Revenue");
for _, v in pairs(all_gerter) do
    chart:add_column_stacking((aggregate_and_concatenate_stages(v, BY_SUM()) * cmgdem):aggregate_scenarios(BY_AVERAGE()), {color="red"});
end
for _, v in pairs(all_gerhid) do
    chart:add_column_stacking((aggregate_and_concatenate_stages(v, BY_SUM()) * cmgdem):aggregate_scenarios(BY_AVERAGE()), {color="blue"});
end
chart:add_column_stacking((defcit * cmgdem), {color="black"});
dashboard_revenue:push(chart);


-- local chart = Chart("Revenue");
-- chart:add_line(concatenate_stages(aggregated_generation):set_stage_type(0) * concatenate_stages(aggregated_load_marginal_cost):set_stage_type(0));
-- dashboard_revenue:push(chart);

(dashboard_costs + dashboard_generation + dashboard_revenue + dashboard_volume):save("dashboard_market");