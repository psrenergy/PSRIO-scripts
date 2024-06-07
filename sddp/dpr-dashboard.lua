local generic = Generic();

local dprdash_psrio = generic:load("dprdashboard",true,true):force_hourly():force_unit("");
local dprdash_psrio_agents = dprdash_psrio:agents();

local tab = Tab("DPR")

for _,agent in ipairs(dprdash_psrio_agents) do
    local ymax = dprdash_psrio:aggregate_stages(BY_MAX()):aggregate_scenarios(BY_MAX()):aggregate_blocks(BY_MAX()):select_agent(agent):to_list()[1];
    local ymin = dprdash_psrio:aggregate_stages(BY_MIN()):aggregate_scenarios(BY_MIN()):aggregate_blocks(BY_MAX()):select_agent(agent):to_list()[1];

    local chart = Chart(agent);
    chart:enable_controls();
    for stage = 1, dprdash_psrio:last_stage() do
        chart:add_area(dprdash_psrio:select_agent(agent)
             :select_stage(stage),
             { sequence = stage, color = "#2690DA", showInLegend = false, yMin = ymin, yMax = ymax});
    end
    tab:push(chart);
end

local dashboard = Dashboard()
dashboard:push(tab)
dashboard:save("dashboard_DPR")
