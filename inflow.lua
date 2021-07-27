local function create_chart(chart, title, exp, color)
    local avg = exp:aggregate_scenarios(BY_AVERAGE()):rename_agents({title .. " avg"});
    local p10 = exp:aggregate_scenarios(BY_PERCENTILE(10)):rename_agents({title .. " p10"});
    local p25 = exp:aggregate_scenarios(BY_PERCENTILE(25)):rename_agents({title .. " p25"});
    local p75 = exp:aggregate_scenarios(BY_PERCENTILE(75)):rename_agents({title .. " p75"});
    local p90 = exp:aggregate_scenarios(BY_PERCENTILE(90)):rename_agents({title .. " p90"});
    local min = exp:aggregate_scenarios(BY_MIN()):rename_agents({title .. " min"});
    local max = exp:aggregate_scenarios(BY_MAX()):rename_agents({title .. " max"});

    
    chart:add_line(min, {color=color});
    chart:add_line(max, {color=color});
    chart:add_area_range(p10, p90, {color=color});
    chart:add_area_range(p25, p75, {color=color});
    chart:add_line(avg, {color="#000000"});
end

local generic = require("collection/generic");
local inflow = generic:load("inflow"):aggregate_agents(BY_SUM(), "all agents");
local inflow_new = generic:load("inflow_new"):aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), "all agents");

local chart = Chart("Inflow");

local dashboard1 = Dashboard("Home");

create_chart(chart, "novo", inflow, "#2f7ed8");
create_chart(chart, "antigo", inflow_new, "#8bbc21")

dashboard1:push(chart);

(dashboard1):save("dashboard");



