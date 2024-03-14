
local generic = Generic();

local dprdash_psrio = generic:load("dprdashboard",true,true):force_hourly():force_unit("");

local tab = Tab("DLR")

local chart = Chart("DLR");
chart:enable_controls();
for stage = 1, dprdash_psrio:last_stage() do
    chart:add_line(dprdash_psrio:select_stage(stage), { sequence = stage});
end
tab:push(chart);

local dashboard = Dashboard()
dashboard:push(tab)
dashboard:save("dashboard_DLR")
