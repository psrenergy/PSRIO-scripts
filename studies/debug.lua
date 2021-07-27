local dashboard = Dashboard();

dashboard:add_menu("quality", "Solution Quality");
dashboard:add_menu("costs", "Operation costs");

-- SOLUTON QUALITY
local chart1 = Chart("Convergence report");
local chart1 = Chart("Convergence report", "quality");

chart1:push_line("output");
chart1:push_area_range("output");

chart1:push("enearm_risk_level2_SE_or_SU", "column", {color="#ffffff"});



dashboard:push(chart1);

dashboard:save("risk");
