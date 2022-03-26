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
local thermal = Thermal();
local renewable = Renewable();
local cinte1 = require("sddp/cinte1");

-- create dashboard tabs
local dashboard_marginal_costs = Dashboard("Marginal Costs");
dashboard_marginal_costs:set_icon("dollar-sign");

local dashboard_costs = Dashboard("Costs");
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

local all_coster = {};
local all_coshid = {};

local all_revter = {};
local all_revhid = {};

local all_defcit = {};
local all_cmgdem = {};

local function aggregate_and_concatenate_as_stages(v, f)
    local new_v = {};
    for key, value in pairs(v) do
        table.insert(new_v, value:aggregate_stages(f));
    end
    return concatenate_stages(new_v):set_stage_type(0);
end

local function load_all_collection(i, all, inner)
    for j = 1, inner:agents_size() do
        local agent = inner:agent(j);
        if all[agent] == nil then
            all[agent] = {};
        end
        if i > 1 then
            -- and table.getn(all[agent]) == 0 then
            local val = 0
            for _, _ in pairs(all[agent]) do
                val =  val + 1;
            end
            -- print(table.getn(all[agent]));
            if val == 0 then
                exp = (inner:select_agent(agent)*0):save_cache();
                table.insert(all[agent], exp);
            end
        end
        exp2 = inner:select_agent(agent):save_cache();
        table.insert(all[agent], exp2);
    end
    return all
end

for i = 1, #iterations do
    local iteration = iterations[i];

    local cmgdem = generic:load(iteration .. "/cmgdem");
    local defcit = generic:load(iteration .. "/defcit"):aggregate_scenarios(BY_AVERAGE()):rename_agents({"Deficit"});

    local chart = get_percentiles_chart(cmgdem, iteration);
    dashboard_marginal_costs:push(chart);

    local chart_costs = Chart(iteration);

    local gerter = {};
    local gerhid = {};
    local gergnd = {};
    local coster = {};
    local coshid = {};
    local cosgnd = {};
    local revter = {};
    local revhid = {};
    local revgnd = {};
    -- local volini = {};
    local eneemb = {};
    local enever2 = {};
    local bid_accepted = {};
    local bid_price = {};

    -- list the directories ag_X
    local directories = generic:get_directories(iteration, "(ag_[0-9]+$)");

    -- insert the ag_0 directory at the beginning of the list
    table.insert(directories, 1, "");

    for j = 1, #directories do
        local directory = directories[j];

        local index; local agent;
        if directory == "" then
            index = "0";
            agent = "ag_0";
        else
            index = string.match(directory, "%d+");
            agent = directory;
        end

        table.insert(gerter, generic:load(iteration .. "/" .. directory .. "/gerter"):aggregate_agents(BY_SUM(), agent));
        table.insert(gerhid, generic:load(iteration .. "/" .. directory .. "/gerhid"):aggregate_agents(BY_SUM(), agent));
        table.insert(gergnd, generic:load(iteration .. "/" .. directory .. "/gergnd"):aggregate_agents(BY_SUM(), agent));

        table.insert(eneemb, generic:load(iteration .. "/" .. directory .. "/eneemb"):aggregate_agents(BY_SUM(), agent));
        table.insert(enever2, generic:load(iteration .. "/" .. directory .. "/enever2"):aggregate_agents(BY_SUM(), agent));
        table.insert(bid_accepted, generic:load(iteration .. "/bid_accepted_" .. index):aggregate_agents(BY_SUM(), agent));
        table.insert(bid_price, generic:load(iteration .. "/bid_price_" .. index):aggregate_agents(BY_SUM(), agent));

        local thermal_cost = thermal:load(iteration .. "/" .. directory .. "/gerter") * cinte1();
        table.insert(coster, thermal_cost:aggregate_agents(BY_SUM(), agent));
        local hydro_cost = hydro:load(iteration .. "/" .. directory .. "/gerhid") * hydro.omcost;
        table.insert(coshid, hydro_cost:aggregate_agents(BY_SUM(), agent));
        local renew_cost = renewable:load(iteration .. "/" .. directory .. "/gergnd") * renewable.omcost;
        table.insert(cosgnd, renew_cost:aggregate_agents(BY_SUM(), agent));

        local thermal_rev = thermal:load(iteration .. "/" .. directory .. "/gerter") * cmgdem;
        table.insert(revter, thermal_rev:aggregate_agents(BY_SUM(), agent));
        local hydro_rev = hydro:load(iteration .. "/" .. directory .. "/gerhid") * cmgdem;
        table.insert(revhid, hydro_rev:aggregate_agents(BY_SUM(), agent));
        local renew_rev = renewable:load(iteration .. "/" .. directory .. "/gergnd") * cmgdem;
        table.insert(revgnd, renew_rev:aggregate_agents(BY_SUM(), agent));

    end

    dashboard_costs:push(chart_costs);

    local concatenated_gerter = concatenate(gerter):save_and_load("gerter-" .. iteration):add_prefix("Thermal ");
    local concatenated_gerhid = concatenate(gerhid):save_and_load("gerhid-" .. iteration):add_prefix("Hydro ");
    local concatenated_gergnd = concatenate(gergnd):save_and_load("gergnd-" .. iteration):add_prefix("Renewable ");

    local concatenated_coster = concatenate(coster):save_and_load("coster-" .. iteration):add_prefix("Thermal ");
    local concatenated_coshid = concatenate(coshid):save_and_load("coshid-" .. iteration):add_prefix("Hydro ");
    local concatenated_cosgnd = concatenate(cosgnd):save_and_load("cosgnd-" .. iteration):add_prefix("Renewable ");

    local concatenated_revter = concatenate(revter):save_and_load("revter-" .. iteration):add_prefix("Thermal ");
    local concatenated_revhid = concatenate(revhid):save_and_load("revhid-" .. iteration):add_prefix("Hydro ");
    local concatenated_revgnd = concatenate(revgnd):save_and_load("revgnd-" .. iteration):add_prefix("Renewable ");

    -- local concatenated_volini = concatenate(volini):save_and_load("volini-" .. iteration);
    local concatenated_eneemb = concatenate(eneemb):save_and_load("eneemb-" .. iteration);
    local concatenated_enever2 = concatenate(enever2):save_and_load("enever2-" .. iteration);
    local concatenated_bid_accepted = concatenate(bid_accepted):save_and_load("bid_accepted-" .. iteration);
    local concatenated_bid_price = concatenate(bid_price):save_and_load("bid_price-" .. iteration);

    local chart = Chart("Generation: " .. iteration);
    chart:add_area_stacking(concatenated_gerter:aggregate_scenarios(BY_AVERAGE()), {color="red"});
    chart:add_area_stacking(concatenated_gerhid:aggregate_scenarios(BY_AVERAGE()), {color="blue"});
    chart:add_area_stacking(concatenated_gergnd:aggregate_scenarios(BY_AVERAGE()), {color="green"});
    chart:add_line(demand, {color="purple"});
    chart:add_area_stacking(defcit, {color="black"});
    dashboard_generation:push(chart);

    local chart = Chart("Revenue: " .. iteration);
    chart:add_area_stacking(concatenated_revter:aggregate_scenarios(BY_AVERAGE()), {color="red"});
    chart:add_area_stacking(concatenated_revhid:aggregate_scenarios(BY_AVERAGE()), {color="blue"});
    chart:add_area_stacking(concatenated_revgnd:aggregate_scenarios(BY_AVERAGE()), {color="green"});
    chart:add_area_stacking((defcit * cmgdem):aggregate_scenarios(BY_AVERAGE()), {color="black"});
    chart:add_line((demand * cmgdem):aggregate_scenarios(BY_AVERAGE()), {color="purple"});
    dashboard_revenue:push(chart);

    local chart = Chart("Cost: " .. iteration);
    chart:add_area_stacking(concatenated_coster:aggregate_scenarios(BY_AVERAGE()), {color="red"});
    chart:add_area_stacking(concatenated_coshid:aggregate_scenarios(BY_AVERAGE()), {color="blue"});
    chart:add_area_stacking(concatenated_cosgnd:aggregate_scenarios(BY_AVERAGE()), {color="green"});
    -- chart:add_area_stacking((defcit * cmgdem):aggregate_scenarios(BY_AVERAGE()), {color="black"});
    -- chart:add_line((demand * cmgdem):aggregate_scenarios(BY_AVERAGE()), {color="purple"});
    dashboard_costs:push(chart);

    load_all_collection(i, all_gerter, concatenated_gerter)
    load_all_collection(i, all_gerhid, concatenated_gerhid)
    -- load_all_collection(i, all_gergnd, concatenated_gergnd)

    load_all_collection(i, all_coster, concatenated_coster)
    load_all_collection(i, all_coshid, concatenated_coshid)
    -- load_all_collection(i, all_cosgnd, concatenated_cosgnd)

    load_all_collection(i, all_revter, concatenated_revter)
    load_all_collection(i, all_revhid, concatenated_revhid)
    -- load_all_collection(i, all_revgnd, concatenated_revgnd)

    table.insert(all_defcit, defcit);

    table.insert(all_cmgdem, cmgdem:aggregate_scenarios(BY_AVERAGE()));

    local chart = get_percentiles_chart(concatenated_eneemb:aggregate_agents(BY_SUM(), "All"), "Stored Energy: " .. iteration);
    dashboard_volume:push(chart);
    local chart = get_percentiles_chart(concatenated_enever2:aggregate_agents(BY_SUM(), "All"), "Spilled Energy: " .. iteration);
    dashboard_volume:push(chart);

    local chart = get_percentiles_chart(concatenated_eneemb, "Stored Energy: " .. iteration);
    dashboard_volume:push(chart);
    local chart = get_percentiles_chart(concatenated_enever2, "Spilled Energy: " .. iteration);
    dashboard_volume:push(chart);
end

local cmgdem = aggregate_and_concatenate_as_stages(all_cmgdem, BY_AVERAGE()):save_cache();
local defcit = aggregate_and_concatenate_as_stages(all_defcit, BY_SUM()):save_cache();

local chart = Chart("Aggregated Load Marginal Cost");
chart:add_column_stacking(cmgdem);
dashboard_marginal_costs:push(chart);

local chart = Chart("Aggregated Generation");
for _, v in pairs(all_gerter) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()):aggregate_scenarios(BY_AVERAGE()), {color="red"});
end
for _, v in pairs(all_gerhid) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()):aggregate_scenarios(BY_AVERAGE()), {color="blue"});
end
chart:add_column_stacking(defcit, {color="black"});
dashboard_generation:push(chart);

local chart = Chart("Aggregated Cost");
for _, v in pairs(all_coster) do
    chart:add_column_stacking((aggregate_and_concatenate_as_stages(v, BY_SUM())):aggregate_scenarios(BY_AVERAGE()), {color="red"});
end
for _, v in pairs(all_coshid) do
    chart:add_column_stacking((aggregate_and_concatenate_as_stages(v, BY_SUM())):aggregate_scenarios(BY_AVERAGE()), {color="blue"});
end
-- chart:add_column_stacking((defcit * cmgdem), {color="black"});
dashboard_costs:push(chart);

local chart = Chart("Aggregated Revenue");
for _, v in pairs(all_revter) do
    chart:add_column_stacking((aggregate_and_concatenate_as_stages(v, BY_SUM())):aggregate_scenarios(BY_AVERAGE()), {color="red"});
end
for _, v in pairs(all_revhid) do
    chart:add_column_stacking((aggregate_and_concatenate_as_stages(v, BY_SUM())):aggregate_scenarios(BY_AVERAGE()), {color="blue"});
end
chart:add_column_stacking((defcit * cmgdem), {color="black"});
dashboard_revenue:push(chart);


-- local chart = Chart("Revenue");
-- chart:add_line(concatenate_stages(aggregated_generation):set_stage_type(0) * concatenate_stages(aggregated_load_marginal_cost):set_stage_type(0));
-- dashboard_revenue:push(chart);

(dashboard_marginal_costs + dashboard_costs + dashboard_generation + dashboard_revenue + dashboard_volume):save("dashboard_market");