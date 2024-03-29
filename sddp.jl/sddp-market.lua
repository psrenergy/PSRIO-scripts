PSR.assert_version(">0.22.0");

-- TODO pass vector of colors
-- today doable adding line by line
-- https://colorswall.com/palette/73
local agent_colors = {
    "#e81123", -- rgb(232, 17, 35)   Red 185
    "#00188f", -- rgb(0, 24, 143)    Blue 286
    "#009e49", -- rgb(0, 158, 73)    Green 355
    "#ff8c00", -- rgb(255, 140, 0)   Orange 144
    "#68217a", -- rgb(104, 33, 122)  Purple 526
    "#00b294", -- rgb(0, 178, 148)   Teal 3275
    "#fff100", -- rgb(255, 241, 0)   Process Yellow
    "#ec008c", -- rgb(236, 0, 140)   Process Magenta
    "#00bcf2", -- rgb(0, 188, 242)   Process Cyan
    "#bad80a", -- rgb(186, 216, 10)  Lime 382
};

local light_colors = {
"#6495ED",
"#EC9C9C",
"#32CD32",
"#9370DB",
"#F4A460",
"#9ACD32",
"#836FFF",
"#ED6DEA",
"#48D1CC",
"#FFB6C1",
"#A9A9A9",
};

local medium_colors = {
"#4169E1",
"#DC4848",
"#228E2F",
"#8A2BE2",
"#CD853F",
"#6F9424",
"#6959CD",
"#DE1CD9",
"#20B2AA",
"#DC7EA2",
"#808080",
};

local dark_colors = {
"#00008B",
"#B22222",
"#165A1E",
"#4B0082",
"#A0522D",
"#556B2F",
"#483D8B",
"#8B008B",
"#008080",
"#B03060",
"#4F4F4F",
};

-- TODO: add interpolation
-- colors = PSR.interpolate_colors("#ff0000", "#00ff00", 4)

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
    local study = Study();
    local generic = Generic();
    for j = 1, inner:agents_size() do
        local agent = inner:agent(j);
        if all[agent] == nil then
            all[agent] = {};
        end
        if i > 1 then
            -- local vec = {}
            -- for k = 1,study:stages() do
            --     table.insert(vec, 0);
            -- end
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
    return all;
end

local function cvar_scenario(exp, lambda, alpha)
    local preexp = exp:aggregate_blocks(BY_SUM())
    return (1-lambda) * preexp:aggregate_scenarios(BY_AVERAGE()) + lambda * preexp:aggregate_scenarios(BY_CVAR_L(alpha))
end

-- load collections
local generic = Generic();
local hydro = Hydro();
local thermal = Thermal();
local renewable = Renewable();
local system = System();
local cinte1 = require("sddp/cinte1");

cinte1():save_and_load("cinte1-psrio");

-- TODO use discount
-- local discount_rate = require("sddp/discount_rate");
-- discount_rate():save_and_load("discount_rate-psrio");

-- create dashboard tabs
local tab_marginal_costs = Tab("Spot Price");
tab_marginal_costs:set_icon("dollar-sign");

local tab_netrev_captured = Tab("Normalized Net Revenue");
tab_netrev_captured:set_icon("dollar-sign");

local tab_costs = Tab("Costs");
tab_costs:set_icon("dollar-sign");

local tab_generation = Tab("Generation");
tab_generation:set_icon("zap");

local tab_revenue = Tab("Revenue");
tab_revenue:set_icon("activity");

local tab_netrev = Tab("Net Revenue");
tab_netrev:set_icon("activity");

local tab_rskrev = Tab("Risk Net Revenue");
tab_rskrev:set_icon("activity");

local tab_volume = Tab("Stored Energy (System)");
tab_volume:set_icon("battery-charging");

local tab_volume_ind = Tab("Agents");
tab_volume_ind:set_icon("minus");

local tab_spill = Tab("Spilled Energy (System)");
tab_spill:set_icon("trash-2");

local tab_spill_ind = Tab("Agents");
tab_spill_ind:set_icon("minus");

-- load demand
local demand = generic:load("iter_init/demand"):rename_agents({"Demand"});

-- get the directories of the iterations
local iterations = generic:get_directories("(iter_[0-9]*)");

-- sort the iterations based on their number
table.sort(iterations, function (a, b) return (tonumber(string.match(a, "%d+")) < tonumber(string.match(b, "%d+"))) end)

-- insert the "iter_init" directory at the beginning of the list
table.insert(iterations, 1, "iter_init");

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

local all_revcon = {};
local all_coscon = {};
local all_netcon = {};
local all_rskcon = {};

local all_nettot = {};
local all_nettot_captured = {};
local all_rsktot = {};

local all_defcit = {};
local all_cmgdem = {};

local all_eneemb = {};
local all_enever2 = {};

local chart_avg_volume     = Chart("Average stored energy all");
local chart_avg_volume_ind = Chart("Average stored energy agents");
local chart_avg_spill      = Chart("Average spilled energy all");
local chart_avg_spill_ind  = Chart("Average spilled energy agents");
local chart_avg_spot       = Chart("Average spot price - iterations");

local chart_avg_gerter = Chart("Average generation thermal - iterations");
local chart_avg_gerhid = Chart("Average generation hydro - iterations");
local chart_avg_gergnd = Chart("Average generation renewable - iterations");

local chart_avg_cos = Chart("Average cost - iterations");
local chart_avg_rev = Chart("Average revenue - iterations");
local chart_avg_net = Chart("Average net revenue - iterations");
local chart_avg_rsk = Chart("Risk adjusted revenue - iterations");


-- read data for risk aversion parameter from additionl file
-- TODO consider reading CCTA and CCTL from sddp.dat
local all_lambda = {};
local all_alpha = {};

local toml = generic:load_toml("sddpconfig.dat");
local alpha = toml:get_integer("CCTA", 0);
all_alpha["0"] = alpha;
local lambda = toml:get_integer("CCTL", 0)/100;
all_lambda["0"] = lambda;

-- min (1 - λ) * E[x] + λ * CVaR_alpha[x] (alpha highest - right)
-- internal alpha == 0.0 means worst case = highest
local toml = generic:load_toml("agents.dat");
local size = toml:get_table_array_size("AGENT");
for a = 1, size do
    local agent = toml:get_table_array("AGENT", a);
    -- this is alpha used in sddp for cost min, where 0 is worst (high cost)
    local alpha = agent:get_integer("alpha", 0);
    all_alpha[tostring(a)] = alpha;
    local lambda = agent:get_integer("lambda", 0)/100;
    all_lambda[tostring(a)] = lambda;
end

local interp_colors = {};
for i = 1, 10 do
    interp_colors[i] = PSR.interpolate_colors(light_colors[i], dark_colors[i], #iterations);
end

for i = 1, #iterations do
    local iteration = iterations[i];

    local cmgdem = system:load(iteration .. "/cmgdem"):aggregate_blocks(BY_AVERAGE());
    local defcit = system:load(iteration .. "/defcit"):aggregate_scenarios(BY_AVERAGE()):rename_agents({"Deficit"});

    local chart = get_percentiles_chart(cmgdem, iteration);
    tab_marginal_costs:push(chart);

    chart_avg_spot:add_line(
        cmgdem:aggregate_scenarios(BY_AVERAGE()):add_prefix("i " .. tostring(i-2) .. " - "), {color=interp_colors[2][i]});

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
    local revcon = {};
    local coscon = {};
    local netcon = {};
    local rskcon = {};
    -- costot
    -- revtot
    local nettot = {};
    local nettot_captured = {};
    local rsktot = {};

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

        local _eneemb = hydro:load(iteration .. "/" .. directory .. "/eneemb");
        table.insert(eneemb, _eneemb:aggregate_blocks(BY_LAST_VALUE()):aggregate_agents(BY_SUM(), index));
        local _enever2 = hydro:load(iteration .. "/" .. directory .. "/enever2");
        table.insert(enever2, _enever2:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local _bid_ac = generic:load(iteration .. "/bid_accepted_" .. index);
        table.insert(bid_accepted, _bid_ac:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local _bid_pr = generic:load(iteration .. "/bid_price_" .. index);
        table.insert(bid_price, _bid_pr:aggregate_blocks(BY_AVERAGE()):aggregate_agents(BY_SUM(), index));

        local thermal_gen = thermal:load(iteration .. "/" .. directory .. "/gerter");
        table.insert(gerter, thermal_gen:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local hydro_gen = hydro:load(iteration .. "/" .. directory .. "/gerhid");
        table.insert(gerhid, hydro_gen:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local renew_gen = renewable:load(iteration .. "/" .. directory .. "/gergnd");
        table.insert(gergnd, renew_gen:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));

        local thermal_cost = thermal_gen * cinte1();
        table.insert(coster, thermal_cost:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local hydro_cost = hydro_gen * hydro.om_cost;
        table.insert(coshid, hydro_cost:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local renew_cost = renew_gen * renewable.om_cost;
        table.insert(cosgnd, renew_cost:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));

        local thermal_rev = thermal_gen * cmgdem;
        table.insert(revter, thermal_rev:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local hydro_rev = hydro_gen * cmgdem;
        table.insert(revhid, hydro_rev:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local renew_rev = renew_gen * cmgdem;
        table.insert(revgnd, renew_rev:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));

        -- revenue: P*Q - pi*Q + pi*g - c*g
        local contractsys_pq = system:load("contractsys_pq_" .. tostring(index));
        table.insert(revcon, contractsys_pq:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local contractsys_q = system:load("contractsys_q_" .. tostring(index));
        table.insert(coscon, (contractsys_q*cmgdem):aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local contract_net = (contractsys_pq - contractsys_q*cmgdem);
        table.insert(netcon, contract_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local contract_rsk = contract_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index);

        local _lambda = all_lambda[index]
        if _lambda == nil then
            _lambda = 0.0
        end
        local _alpha = all_alpha[index]
        if _alpha == nil then
            _alpha = 1
        end
        table.insert(rskcon, cvar_scenario(contract_rsk, _lambda, _alpha));

        local thermal_net = thermal_rev - thermal_cost;
        table.insert(netter, thermal_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local hydro_net = hydro_rev - hydro_cost;
        table.insert(nethid, hydro_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));
        local renew_net = renew_rev - renew_cost;
        table.insert(netgnd, renew_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index));

        local total = thermal_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index) +
            hydro_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index) +
            renew_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index) +
            contract_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index);
        table.insert(nettot,
            total
        );

        local total_captured = ((
            thermal_net:aggregate_agents(BY_SUM(), index) +
            hydro_net:aggregate_agents(BY_SUM(), index) +
            renew_net:aggregate_agents(BY_SUM(), index)
        ):aggregate_blocks(BY_SUM()):aggregate_stages(BY_SUM()) / (
            thermal_gen:aggregate_agents(BY_SUM(), index) +
            hydro_gen:aggregate_agents(BY_SUM(), index) +
            renew_gen:aggregate_agents(BY_SUM(), index)
        ):aggregate_blocks(BY_SUM()):aggregate_stages(BY_SUM()));
        table.insert(nettot_captured,
            total_captured
        );

        local thermal_rsk = thermal_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index);
        table.insert(rskter, cvar_scenario(thermal_rsk, _lambda, _alpha));
        local hydro_rsk = hydro_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index);
        table.insert(rskhid, cvar_scenario(hydro_rsk, _lambda, _alpha));
        local renew_rsk = renew_net:aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), index);
        table.insert(rskgnd, cvar_scenario(renew_rsk, _lambda, _alpha));

        table.insert(rsktot, cvar_scenario(total, _lambda, _alpha));
    end

    -- TODO: save in separate folder (might need to create a folder)
    -- local folder = "market_results_psrio/"
    -- local cat_gerter = concatenate(gerter):save_and_load(folder .. "gerter-" .. iteration):add_prefix("Thermal ");
    local cat_gerter = concatenate(gerter):add_prefix("Thermal ");
    local cat_gerhid = concatenate(gerhid):add_prefix("Hydro ");
    local cat_gergnd = concatenate(gergnd):add_prefix("Renewable ");

    local cat_coster = concatenate(coster):add_prefix("Thermal ");
    local cat_coshid = concatenate(coshid):add_prefix("Hydro ");
    local cat_cosgnd = concatenate(cosgnd):add_prefix("Renewable ");

    local cat_revter = concatenate(revter):add_prefix("Thermal ");
    local cat_revhid = concatenate(revhid):add_prefix("Hydro ");
    local cat_revgnd = concatenate(revgnd):add_prefix("Renewable ");

    local cat_netter = concatenate(netter):add_prefix("Thermal ");
    local cat_nethid = concatenate(nethid):add_prefix("Hydro ");
    local cat_netgnd = concatenate(netgnd):add_prefix("Renewable ");

    -- this one has only 1 scenario (the above have all)
    local cat_rskter = concatenate(rskter):add_prefix("Thermal ");
    local cat_rskhid = concatenate(rskhid):add_prefix("Hydro ");
    local cat_rskgnd = concatenate(rskgnd):add_prefix("Renewable ");

    local cat_coscon = concatenate(coscon):add_prefix("Contract ");
    local cat_revcon = concatenate(revcon):add_prefix("Contract ");
    local cat_netcon = concatenate(netcon):add_prefix("Contract ");
    local cat_rskcon = concatenate(rskcon):add_prefix("Contract ");

    local cat_nettot_captured = concatenate(nettot_captured):add_prefix("Ag ");
    local cat_nettot = concatenate(nettot):add_prefix("Ag ");
    local cat_rsktot = concatenate(rsktot):add_prefix("Ag ");

    local cat_eneemb = concatenate(eneemb);
    local cat_enever2 = concatenate(enever2);
    -- local cat_bid_accepted = concatenate(bid_accepted):save_and_load("bid_accepted-" .. iteration);
    -- local cat_bid_price = concatenate(bid_price):save_and_load("bid_price-" .. iteration);

    local chart = Chart("Generation: " .. iteration);
    chart:add_area_stacking(cat_gerter:aggregate_scenarios(BY_AVERAGE()), {color="red"});
    chart:add_area_stacking(cat_gerhid:aggregate_scenarios(BY_AVERAGE()), {color="blue"});
    chart:add_area_stacking(cat_gergnd:aggregate_scenarios(BY_AVERAGE()), {color="green"});
    chart:add_line(demand:aggregate_scenarios(BY_AVERAGE()):aggregate_blocks(BY_SUM()), {color="purple"});
    chart:add_area_stacking(defcit:aggregate_scenarios(BY_AVERAGE()):aggregate_blocks(BY_SUM()), {color="black"});
    tab_generation:push(chart);

    local chart = Chart("Revenue: " .. iteration);
    chart:add_area_stacking(cat_revter:aggregate_scenarios(BY_AVERAGE()), {color="red"});
    chart:add_area_stacking(cat_revhid:aggregate_scenarios(BY_AVERAGE()), {color="blue"});
    chart:add_area_stacking(cat_revgnd:aggregate_scenarios(BY_AVERAGE()), {color="green"});
    chart:add_area_stacking(cat_revcon:aggregate_scenarios(BY_AVERAGE()), {color="purple"});
    chart:add_area_stacking((defcit * cmgdem):aggregate_scenarios(BY_AVERAGE()):aggregate_blocks(BY_SUM()), {color="black"});
    chart:add_line((demand * cmgdem):aggregate_scenarios(BY_AVERAGE()):aggregate_blocks(BY_SUM()), {color="pink"});
    tab_revenue:push(chart);

    local chart = Chart("Cost: " .. iteration);
    chart:add_area_stacking(cat_coster:aggregate_scenarios(BY_AVERAGE()), {color="red"});
    chart:add_area_stacking(cat_coshid:aggregate_scenarios(BY_AVERAGE()), {color="blue"});
    chart:add_area_stacking(cat_cosgnd:aggregate_scenarios(BY_AVERAGE()), {color="green"});
    chart:add_area_stacking(cat_coscon:aggregate_scenarios(BY_AVERAGE()), {color="purple"});
    -- TODO read deficit cost
    -- chart:add_area_stacking((defcit * defcos):aggregate_scenarios(BY_AVERAGE()), {color="black"});
    tab_costs:push(chart);

    local chart = Chart("Net Revenue (per tech): " .. iteration);
    chart:add_area_stacking(cat_netter:aggregate_scenarios(BY_AVERAGE()), {color="red"});
    chart:add_area_stacking(cat_nethid:aggregate_scenarios(BY_AVERAGE()), {color="blue"});
    chart:add_area_stacking(cat_netgnd:aggregate_scenarios(BY_AVERAGE()), {color="green"});
    chart:add_area_stacking(cat_netcon:aggregate_scenarios(BY_AVERAGE()), {color="purple"});
    -- chart:add_area_stacking((defcit * cmgdem):aggregate_scenarios(BY_AVERAGE()), {color="black"});
    -- chart:add_line((demand * cmgdem):aggregate_scenarios(BY_AVERAGE()), {color="purple"});
    tab_netrev:push(chart);

    -- these already have 1 single scenario
    local chart = Chart("Risk Adjusted Net Revenue (per tech): " .. iteration);
    chart:add_area_stacking(cat_rskter, {color="red"});
    chart:add_area_stacking(cat_rskhid, {color="blue"});
    chart:add_area_stacking(cat_rskgnd, {color="green"});
    chart:add_area_stacking(cat_rskcon, {color="purple"});
    tab_rskrev:push(chart);

    -- TODO add loop here
    local chart = Chart("Net Revenue: " .. iteration);
    chart:add_area_stacking(cat_nettot:aggregate_scenarios(BY_AVERAGE()), {color=medium_colors[1+1]});
    tab_netrev:push(chart);

    -- local chart = Chart("Normalized Net Revenue: " .. iteration);
    -- chart:add_area_stacking(cat_nettot_captured:aggregate_scenarios(BY_AVERAGE()), {color=medium_colors[1+1]});
    -- tab_netrev:push(chart);

    local chart = Chart("Risk Adjusted Net Revenue: " .. iteration);
    chart:add_area_stacking(cat_rsktot, {color=medium_colors[i+1]});
    tab_rskrev:push(chart);

    load_all_collection(i, all_gerter, cat_gerter:aggregate_scenarios(BY_AVERAGE()));
    load_all_collection(i, all_gerhid, cat_gerhid:aggregate_scenarios(BY_AVERAGE()));
    load_all_collection(i, all_gergnd, cat_gergnd:aggregate_scenarios(BY_AVERAGE()));

    load_all_collection(i, all_coster, cat_coster:aggregate_scenarios(BY_AVERAGE()));
    load_all_collection(i, all_coshid, cat_coshid:aggregate_scenarios(BY_AVERAGE()));
    load_all_collection(i, all_cosgnd, cat_cosgnd:aggregate_scenarios(BY_AVERAGE()));

    load_all_collection(i, all_revter, cat_revter:aggregate_scenarios(BY_AVERAGE()));
    load_all_collection(i, all_revhid, cat_revhid:aggregate_scenarios(BY_AVERAGE()));
    load_all_collection(i, all_revgnd, cat_revgnd:aggregate_scenarios(BY_AVERAGE()));

    load_all_collection(i, all_netter, cat_netter:aggregate_scenarios(BY_AVERAGE()));
    load_all_collection(i, all_nethid, cat_nethid:aggregate_scenarios(BY_AVERAGE()));
    load_all_collection(i, all_netgnd, cat_netgnd:aggregate_scenarios(BY_AVERAGE()));

    load_all_collection(i, all_coscon, cat_coscon:aggregate_scenarios(BY_AVERAGE()));
    load_all_collection(i, all_revcon, cat_revcon:aggregate_scenarios(BY_AVERAGE()));
    load_all_collection(i, all_netcon, cat_netcon:aggregate_scenarios(BY_AVERAGE()));
    load_all_collection(i, all_rskcon, cat_rskcon)

    load_all_collection(i, all_nettot_captured, cat_nettot_captured:aggregate_scenarios(BY_AVERAGE()));
    load_all_collection(i, all_nettot, cat_nettot:aggregate_scenarios(BY_AVERAGE()));
    load_all_collection(i, all_rsktot, cat_rsktot);

    -- these are already aggregated by risk
    load_all_collection(i, all_rskter, cat_rskter);
    load_all_collection(i, all_rskhid, cat_rskhid);
    load_all_collection(i, all_rskgnd, cat_rskgnd);

    load_all_collection(i, all_eneemb, cat_eneemb:aggregate_scenarios(BY_AVERAGE()));
    load_all_collection(i, all_enever2, cat_enever2:aggregate_scenarios(BY_AVERAGE()));

    table.insert(all_defcit, defcit:aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()));

    table.insert(all_cmgdem, cmgdem:aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE()));

    local chart = get_percentiles_chart(cat_eneemb:aggregate_agents(BY_SUM(), "All"), "Stored Energy: " .. iteration);
    tab_volume:push(chart);
    local chart = get_percentiles_chart(cat_enever2:aggregate_agents(BY_SUM(), "All"), "Spilled Energy: " .. iteration);
    tab_spill:push(chart);

    chart_avg_spill:add_line(cat_enever2:aggregate_agents(BY_SUM(), "i " .. tostring(i-2) .. " - ")
        :aggregate_scenarios(BY_AVERAGE()), {color=interp_colors[1][i]});
    chart_avg_volume:add_line(cat_eneemb:aggregate_agents(BY_SUM(), "i " .. tostring(i-2) .. " - ")
        :aggregate_scenarios(BY_AVERAGE()), {color=interp_colors[1][i]});

    for a = 1,cat_enever2:agents_size() do 
        chart_avg_spill_ind:add_line(
            cat_enever2:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            :add_prefix("i " .. tostring(i-2) .. " - "), {color=interp_colors[a][i]});
        chart_avg_volume_ind:add_line(
            cat_eneemb:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            :add_prefix("i " .. tostring(i-2) .. " - "), {color=interp_colors[a][i]});

        chart_avg_gerter:add_line(
            cat_gerter:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            :add_prefix("i " .. tostring(i-2) .. " - "), {color=interp_colors[a][i]});
        chart_avg_gerhid:add_line(
            cat_gerhid:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            :add_prefix("i " .. tostring(i-2) .. " - "), {color=interp_colors[a][i]});
        chart_avg_gergnd:add_line(
            cat_gergnd:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            :add_prefix("i " .. tostring(i-2) .. " - "), {color=interp_colors[a][i]});

        chart_avg_cos:add_line(
            (
              cat_coster:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            + cat_coshid:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            + cat_cosgnd:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            + cat_coscon:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            ):aggregate_agents(BY_SUM(), "i " .. tostring(i-2) .. "- ag" .. tostring(a-1)), {color=interp_colors[a][i]});

        chart_avg_rev:add_line(
            (
                cat_revter:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            + cat_revhid:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            + cat_revgnd:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            + cat_revcon:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            ):aggregate_agents(BY_SUM(), "i " .. tostring(i-2) .. "- ag" .. tostring(a-1)), {color=interp_colors[a][i]});

        chart_avg_net:add_line(
            (
                cat_netter:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            + cat_nethid:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            + cat_netgnd:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            + cat_netcon:select_agent(a):aggregate_scenarios(BY_AVERAGE())
            ):aggregate_agents(BY_SUM(), "i " .. tostring(i-2) .. "- ag" .. tostring(a-1)), {color=interp_colors[a][i]});

        chart_avg_rsk:add_line(
            (
            --     cat_rskter:select_agent(a)
            -- + cat_rskhid:select_agent(a)
            -- + cat_rskgnd:select_agent(a)
            -- + cat_rskcon:select_agent(a)
            cat_rsktot:select_agent(a)
            ):aggregate_agents(BY_SUM(), "i " .. tostring(i-2) .. "- ag" .. tostring(a-1)), {color=interp_colors[a][i]});
    end


    local chart = get_percentiles_chart(cat_eneemb, "Stored Energy: " .. iteration);
    tab_volume_ind:push(chart);
    local chart = get_percentiles_chart(cat_enever2, "Spilled Energy: " .. iteration);
    tab_spill_ind:push(chart);
end

local cmgdem = aggregate_and_concatenate_as_stages(all_cmgdem, BY_AVERAGE()):save_cache();
local defcit = aggregate_and_concatenate_as_stages(all_defcit, BY_SUM()):save_cache();

local chart = Chart("Aggregated Load Marginal Cost");
chart:add_column_stacking(cmgdem);
tab_marginal_costs:push(chart);

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
tab_generation:push(chart);

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
for _, v in pairs(all_coscon) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="purple"});
end
-- chart:add_column_stacking(defcit * cmgdem), {color="black"});
tab_costs:push(chart);

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
for _, v in pairs(all_revcon) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="purple"});
end
-- chart:add_column_stacking(defcit * cmgdem, {color="black"});
tab_revenue:push(chart);

local chart = Chart("Aggregated Net Revenue (per tech)");
for _, v in pairs(all_netter) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="red"});
end
for _, v in pairs(all_nethid) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="blue"});
end
for _, v in pairs(all_netgnd) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="green"});
end
for _, v in pairs(all_netcon) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="purple"});
end
-- chart:add_column_stacking((defcit * cmgdem), {color="black"});
tab_netrev:push(chart);

local chart = Chart("Aggregated Net Revenue");
for i, v in pairs(all_nettot) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color=medium_colors[i]});
end
tab_netrev:push(chart);

local chart = Chart("Normalized Aggregated Net Revenue");
for i, v in pairs(all_nettot_captured) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color=medium_colors[i]});
end
tab_netrev_captured:push(chart);

local chart = Chart("Aggregated Risk Adjusted Net Revenue (per tech)");
for _, v in pairs(all_rskter) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="red"});
end
for _, v in pairs(all_rskhid) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="blue"});
end
for _, v in pairs(all_rskgnd) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="green"});
end
for _, v in pairs(all_rskcon) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="purple"});
end
-- chart:add_column_stacking((defcit * cmgdem), {color="black"});
tab_rskrev:push(chart);

local chart = Chart("Aggregated Risk Adjusted Net Revenue");
for i, v in pairs(all_rsktot) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color=medium_colors[i]});
end
tab_rskrev:push(chart);

local chart = Chart("Average stored energy");
for _, v in pairs(all_eneemb) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_AVERAGE()), {color="blue"});
end
tab_volume_ind:push(chart);

local chart = Chart("Total spilled energy");
for _, v in pairs(all_enever2) do
    chart:add_column_stacking(aggregate_and_concatenate_as_stages(v, BY_SUM()), {color="blue"});
end
tab_spill_ind:push(chart);

-- local chart = Chart("Revenue");
-- chart:add_line(concatenate_stages(aggregated_generation):set_stage_type(0) * concatenate_stages(aggregated_load_marginal_cost):set_stage_type(0));
-- tab_revenue:push(chart);

tab_spill_ind:push(chart_avg_spill_ind);
tab_volume_ind:push(chart_avg_volume_ind);
tab_spill:push(chart_avg_spill);
tab_volume:push(chart_avg_volume);
tab_marginal_costs:push(chart_avg_spot);

tab_generation:push(chart_avg_gerter);
tab_generation:push(chart_avg_gerhid);
tab_generation:push(chart_avg_gergnd);

tab_costs:push(chart_avg_cos);
tab_revenue:push(chart_avg_rev);
tab_netrev:push(chart_avg_net);
tab_rskrev:push(chart_avg_rsk);

local dashboard = Dashboard();
dashboard:push(tab_generation);
dashboard:push(tab_marginal_costs);
dashboard:push(tab_netrev_captured);
dashboard:push(tab_costs);
dashboard:push(tab_revenue);
dashboard:push(tab_netrev);
dashboard:push(tab_rskrev);
dashboard:push(tab_volume);
tab_volume:push(tab_volume_ind);
dashboard:push(tab_spill);
tab_spill:push(tab_spill_ind);
dashboard:save("dashboard_market");