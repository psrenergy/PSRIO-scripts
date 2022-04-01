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

local function aggregate_and_concatenate_as_stages(v, f)
    local new_v = {};
    for key, value in pairs(v) do
        table.insert(new_v, value:aggregate_stages(f));
    end
    return concatenate_stages(new_v):set_stage_type(0):shift_stages(-2);
end

local function load_all_collection(i, all, inner)
    local study = Study()
    local generic = Generic()
    for j = 1, inner:agents_size() do
        local agent = inner:agent(j);
        if all[agent] == nil then
            all[agent] = {};
        end
        if i > 1 then
            local vec = {}
            for i = 1,study:stages() do
                table.insert(vec, 0)
            end
            if #(all[agent]) == 0 then
                -- TODO 1:
                -- testar sem save cache
                -- TODO 2: unidade, cenarios, blocos
                -- agente zerado - pegando etapas do estudo
                -- local exp = generic:create(vec, "unidade")
                local exp = (inner:select_agent(agent)*0):save_cache();
                table.insert(all[agent], exp);
            end
        end
        local exp2 = inner:select_agent(agent):save_cache();
        table.insert(all[agent], exp2);
    end
    return all
end

local function cvar_scenario(exp, lambda, alpha)
    local preexp = exp:aggregate_blocks(BY_SUM())
    return lambda * preexp:aggregate_scenarios(BY_AVERAGE()) +
        (1-lambda) * preexp:aggregate_scenarios(BY_CVAR_L(alpha))
end

local alpha = 0.2
local lambda = 0.5

-- load collections
local generic = Generic();
local hydro = Hydro();
local thermal = Thermal();
local renewable = Renewable();
local cinte1 = require("sddp/cinte1");

cinte1():save_and_load("cinte1-psrio");

-- create dashboard tabs
local dashboard_marginal_costs = Dashboard("Spot Price");
dashboard_marginal_costs:set_icon("dollar-sign");

local dashboard_costs = Dashboard("Costs");
dashboard_costs:set_icon("dollar-sign");

local dashboard_generation = Dashboard("Generation");
dashboard_generation:set_icon("zap");

local dashboard_revenue = Dashboard("Revenue");
dashboard_revenue:set_icon("activity");

local dashboard_netrev = Dashboard("Net Revenue");
dashboard_netrev:set_icon("activity");

local dashboard_rskrev = Dashboard("Risk Net Revenue");
dashboard_rskrev:set_icon("activity");

local dashboard_volume = Dashboard("Stored Energy");
dashboard_volume:set_icon("battery-charging");

local dashboard_volume_ind = Dashboard("Stored Energy (Ind)");
dashboard_volume_ind:set_icon("battery-charging");

local dashboard_spill = Dashboard("Spilled Energy");
dashboard_spill:set_icon("trash-2");

local dashboard_spill_ind = Dashboard("Spilled Energy (Ind)");
dashboard_spill_ind:set_icon("trash-2");

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
local all_gergnd = {};

local all_coster = {};
local all_coshid = {};
local all_cosgnd = {};

local all_revter = {};
local all_revhid = {};
local all_revgnd = {};

local all_netter = {};
local all_nethid = {};
local all_netgnd = {};

local all_rskter = {};
local all_rskhid = {};
local all_rskgnd = {};

local all_defcit = {};
local all_cmgdem = {};

-- TODO: read discount rate

for i = 1, #iterations do
    local iteration = iterations[i];

    local cmgdem = generic:load(iteration .. "/cmgdem");
    local defcit = generic:load(iteration .. "/defcit"):aggregate_scenarios(BY_AVERAGE()):rename_agents({"Deficit"});

    local chart = get_percentiles_chart(cmgdem, iteration);
    dashboard_marginal_costs:push(chart);

    local gerter = {};
    local gerhid = {};
    local gergnd = {};
    local coster = {};
    local coshid = {};
    local cosgnd = {};
    local revter = {};
    local revhid = {};
    local revgnd = {};
    local netter = {};
    local nethid = {};
    local netgnd = {};
    local rskter = {};
    local rskhid = {};
    local rskgnd = {};
    local eneemb = {};
    local enever2 = {};
    local bid_accepted = {};
    local bid_price = {};

    -- list the directories ag_X (then sort)
    local directories = generic:get_directories(iteration, "(ag_[0-9]+$)");
    table.sort(directories, function (a, b) return (tonumber(string.match(a, "%d+")) < tonumber(string.match(b, "%d+"))) end)

    -- insert the ag_0 directory at the beginning of the list
    table.insert(directories, 1, "");

    for j = 1, #directories do
        local directory = directories[j];

        local index; local agent;
        if directory == "" then
            index = "0";
        else
            index = string.match(directory, "%d+");
        end

        -- TODO: generations for iter -1

        local _eneemb = generic:load(iteration .. "/" .. directory .. "/eneemb");
        table.insert(eneemb, _eneemb:aggregate_blocks(BY_LAST_VALUE()):aggregate_agents(BY_SUM(), index));
        local _enever2 = generic:load(iteration .. "/" .. directory .. "/enever2");
        table.insert(enever2, _enever2:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local _bid_ac = generic:load(iteration .. "/bid_accepted_" .. index);
        table.insert(bid_accepted, _bid_ac:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local _bid_pr = generic:load(iteration .. "/bid_price_" .. index);
        table.insert(bid_price, _bid_pr:aggregate_blocks(BY_AVERAGE()):aggregate_agents(BY_SUM(), index));

        local thermal_gen = thermal:load(iteration .. "/" .. directory .. "/gerter");
        table.insert(gerter, thermal_gen:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local hydro_gen = generic:load(iteration .. "/" .. directory .. "/gerhid");
        table.insert(gerhid, hydro_gen:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local renew_gen = generic:load(iteration .. "/" .. directory .. "/gergnd");
        table.insert(gergnd, renew_gen:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));

        local thermal_cost = thermal_gen * cinte1();
        table.insert(coster, thermal_cost:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local hydro_cost = hydro_gen * hydro.omcost;
        table.insert(coshid, hydro_cost:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local renew_cost = renew_gen * renewable.omcost;
        table.insert(cosgnd, renew_cost:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));

        local thermal_rev = thermal_gen * cmgdem;
        table.insert(revter, thermal_rev:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local hydro_rev = hydro_gen * cmgdem;
        table.insert(revhid, hydro_rev:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local renew_rev = renew_gen * cmgdem;
        table.insert(revgnd, renew_rev:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));

        local thermal_net = thermal_rev - thermal_cost;
        table.insert(netter, thermal_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local hydro_net = hydro_rev - hydro_cost;
        table.insert(nethid, hydro_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local renew_net = renew_rev - renew_cost;
        table.insert(netgnd, renew_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));

        -- TODO read alpha and lambda of each agent
        local thermal_rsk = thermal_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index);
        table.insert(rskter, cvar_scenario(thermal_rsk, lambda, alpha));
        local hydro_rsk = hydro_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index);
        table.insert(rskhid, cvar_scenario(hydro_rsk, lambda, alpha));
        local renew_rsk = renew_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index);
        table.insert(rskgnd, cvar_scenario(renew_rsk, lambda, alpha));

    end

    -- TODO: save in separate folder (might need to create a folder)
    -- local folder = "market_results_psrio/"
    -- local cat_gerter = concatenate(gerter):save_and_load(folder .. "gerter-" .. iteration):add_prefix("Thermal ");
    local cat_gerter = concatenate(gerter):save_and_load("gerter-" .. iteration):add_prefix("Thermal ");
    local cat_gerhid = concatenate(gerhid):save_and_load("gerhid-" .. iteration):add_prefix("Hydro ");
    local cat_gergnd = concatenate(gergnd):save_and_load("gergnd-" .. iteration):add_prefix("Renewable ");

    local cat_coster = concatenate(coster):save_and_load("coster-" .. iteration):add_prefix("Thermal ");
    local cat_coshid = concatenate(coshid):save_and_load("coshid-" .. iteration):add_prefix("Hydro ");
    local cat_cosgnd = concatenate(cosgnd):save_and_load("cosgnd-" .. iteration):add_prefix("Renewable ");

    local cat_revter = concatenate(revter):save_and_load("revter-" .. iteration):add_prefix("Thermal ");
    local cat_revhid = concatenate(revhid):save_and_load("revhid-" .. iteration):add_prefix("Hydro ");
    local cat_revgnd = concatenate(revgnd):save_and_load("revgnd-" .. iteration):add_prefix("Renewable ");

    local cat_netter = concatenate(netter):save_and_load("netter-" .. iteration):add_prefix("Thermal ");
    local cat_nethid = concatenate(nethid):save_and_load("nethid-" .. iteration):add_prefix("Hydro ");
    local cat_netgnd = concatenate(netgnd):save_and_load("netgnd-" .. iteration):add_prefix("Renewable ");

    -- this one has only 1 scenario (the above have all)
    local cat_rskter = concatenate(rskter):save_and_load("rskter-" .. iteration):add_prefix("Thermal ");
    local cat_rskhid = concatenate(rskhid):save_and_load("rskhid-" .. iteration):add_prefix("Hydro ");
    local cat_rskgnd = concatenate(rskgnd):save_and_load("rskgnd-" .. iteration):add_prefix("Renewable ");

    local cat_eneemb = concatenate(eneemb):save_and_load("eneemb-" .. iteration);
    local cat_enever2 = concatenate(enever2):save_and_load("enever2-" .. iteration);
    local cat_bid_accepted = concatenate(bid_accepted):save_and_load("bid_accepted-" .. iteration);
    local cat_bid_price = concatenate(bid_price):save_and_load("bid_price-" .. iteration);

    local chart = Chart("Generation: " .. iteration);
    chart:add_area_stacking(cat_gerter:aggregate_scenarios(BY_AVERAGE()), {color="red"});
    chart:add_area_stacking(cat_gerhid:aggregate_scenarios(BY_AVERAGE()), {color="blue"});
    chart:add_area_stacking(cat_gergnd:aggregate_scenarios(BY_AVERAGE()), {color="green"});
    chart:add_line(demand:aggregate_scenarios(BY_AVERAGE()):aggregate_blocks(BY_SUM()), {color="purple"});
    chart:add_area_stacking(defcit:aggregate_scenarios(BY_AVERAGE()):aggregate_blocks(BY_SUM()), {color="black"});
    dashboard_generation:push(chart);

    local chart = Chart("Revenue: " .. iteration);
    chart:add_area_stacking(cat_revter:aggregate_scenarios(BY_AVERAGE()), {color="red"});
    chart:add_area_stacking(cat_revhid:aggregate_scenarios(BY_AVERAGE()), {color="blue"});
    chart:add_area_stacking(cat_revgnd:aggregate_scenarios(BY_AVERAGE()), {color="green"});
    chart:add_area_stacking((defcit * cmgdem):aggregate_scenarios(BY_AVERAGE()):aggregate_blocks(BY_SUM()), {color="black"});
    chart:add_line((demand * cmgdem):aggregate_scenarios(BY_AVERAGE()):aggregate_blocks(BY_SUM()), {color="purple"});
    dashboard_revenue:push(chart);

    local chart = Chart("Cost: " .. iteration);
    chart:add_area_stacking(cat_coster:aggregate_scenarios(BY_AVERAGE()), {color="red"});
    chart:add_area_stacking(cat_coshid:aggregate_scenarios(BY_AVERAGE()), {color="blue"});
    chart:add_area_stacking(cat_cosgnd:aggregate_scenarios(BY_AVERAGE()), {color="green"});
    -- TODO read deficit cost
    -- chart:add_area_stacking((defcit * defcos):aggregate_scenarios(BY_AVERAGE()), {color="black"});
    dashboard_costs:push(chart);

    local chart = Chart("Net Revenue: " .. iteration);
    chart:add_area_stacking(cat_netter:aggregate_scenarios(BY_AVERAGE()), {color="red"});
    chart:add_area_stacking(cat_nethid:aggregate_scenarios(BY_AVERAGE()), {color="blue"});
    chart:add_area_stacking(cat_netgnd:aggregate_scenarios(BY_AVERAGE()), {color="green"});
    -- chart:add_area_stacking((defcit * cmgdem):aggregate_scenarios(BY_AVERAGE()), {color="black"});
    -- chart:add_line((demand * cmgdem):aggregate_scenarios(BY_AVERAGE()), {color="purple"});
    dashboard_netrev:push(chart);

    -- these already have 1 single scenario
    local chart = Chart("Risk Adjusted Net Revenue: " .. iteration);
    chart:add_area_stacking(cat_rskter, {color="red"});
    chart:add_area_stacking(cat_rskhid, {color="blue"});
    chart:add_area_stacking(cat_rskgnd, {color="green"});
    dashboard_rskrev:push(chart);

    load_all_collection(i, all_gerter, cat_gerter:aggregate_scenarios(BY_AVERAGE()))
    load_all_collection(i, all_gerhid, cat_gerhid:aggregate_scenarios(BY_AVERAGE()))
    load_all_collection(i, all_gergnd, cat_gergnd:aggregate_scenarios(BY_AVERAGE()))

    load_all_collection(i, all_coster, cat_coster:aggregate_scenarios(BY_AVERAGE()))
    load_all_collection(i, all_coshid, cat_coshid:aggregate_scenarios(BY_AVERAGE()))
    load_all_collection(i, all_cosgnd, cat_cosgnd:aggregate_scenarios(BY_AVERAGE()))

    load_all_collection(i, all_revter, cat_revter:aggregate_scenarios(BY_AVERAGE()))
    load_all_collection(i, all_revhid, cat_revhid:aggregate_scenarios(BY_AVERAGE()))
    load_all_collection(i, all_revgnd, cat_revgnd:aggregate_scenarios(BY_AVERAGE()))

    load_all_collection(i, all_netter, cat_netter:aggregate_scenarios(BY_AVERAGE()))
    load_all_collection(i, all_nethid, cat_nethid:aggregate_scenarios(BY_AVERAGE()))
    load_all_collection(i, all_netgnd, cat_netgnd:aggregate_scenarios(BY_AVERAGE()))

    load_all_collection(i, all_rskter, cat_rskter)
    load_all_collection(i, all_rskhid, cat_rskhid)
    load_all_collection(i, all_rskgnd, cat_rskgnd)

    table.insert(all_defcit, defcit:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()));

    table.insert(all_cmgdem, cmgdem:aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()));

    local chart = get_percentiles_chart(cat_eneemb:aggregate_agents(BY_SUM(), "All"), "Stored Energy: " .. iteration);
    dashboard_volume:push(chart);
    local chart = get_percentiles_chart(cat_enever2:aggregate_agents(BY_SUM(), "All"), "Spilled Energy: " .. iteration);
    dashboard_spill:push(chart);

    local chart = get_percentiles_chart(cat_eneemb, "Stored Energy: " .. iteration);
    dashboard_volume_ind:push(chart);
    local chart = get_percentiles_chart(cat_enever2, "Spilled Energy: " .. iteration);
    dashboard_spill_ind:push(chart);
end

local cmgdem = aggregate_and_concatenate_as_stages(all_cmgdem, BY_AVERAGE()):save_cache();
local defcit = aggregate_and_concatenate_as_stages(all_defcit, BY_SUM()):save_cache();

local chart = Chart("Aggregated Load Marginal Cost");
chart:add_column_stacking(cmgdem);
dashboard_marginal_costs:push(chart);

local chart = Chart("Aggregated Generation");
for _, v in pairs(all_gerter) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="red"});
end
for _, v in pairs(all_gerhid) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="blue"});
end
for _, v in pairs(all_gergnd) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="green"});
end
chart:add_column_stacking(defcit, {color="black"});
dashboard_generation:push(chart);

local chart = Chart("Aggregated Cost");
for _, v in pairs(all_coster) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="red"});
end
for _, v in pairs(all_coshid) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="blue"});
end
for _, v in pairs(all_cosgnd) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="green"});
end
-- chart:add_column_stacking(defcit * cmgdem), {color="black"});
dashboard_costs:push(chart);

local chart = Chart("Aggregated Revenue");
for _, v in pairs(all_revter) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="red"});
end
for _, v in pairs(all_revhid) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="blue"});
end
for _, v in pairs(all_revgnd) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="green"});
end
-- chart:add_column_stacking(defcit * cmgdem, {color="black"});
dashboard_revenue:push(chart);

local chart = Chart("Aggregated Net Revenue");
for _, v in pairs(all_netter) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="red"});
end
for _, v in pairs(all_nethid) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="blue"});
end
for _, v in pairs(all_netgnd) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="green"});
end
-- chart:add_column_stacking((defcit * cmgdem), {color="black"});
dashboard_netrev:push(chart);

local chart = Chart("Aggregated Risk Adjusted Net Revenue");
for _, v in pairs(all_rskter) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="red"});
end
for _, v in pairs(all_rskhid) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="blue"});
end
for _, v in pairs(all_rskgnd) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="green"});
end
-- chart:add_column_stacking((defcit * cmgdem), {color="black"});
dashboard_rskrev:push(chart);


-- local chart = Chart("Revenue");
-- chart:add_line(concatenate_stages(aggregated_generation):set_stage_type(0) * concatenate_stages(aggregated_load_marginal_cost):set_stage_type(0));
-- dashboard_revenue:push(chart);

(
    dashboard_generation +
    dashboard_costs +
    dashboard_marginal_costs +
    dashboard_revenue +
    dashboard_netrev +
    dashboard_rskrev +
    dashboard_volume +
    dashboard_volume_ind +
    dashboard_spill +
    dashboard_spill_ind
):save("dashboard_market");