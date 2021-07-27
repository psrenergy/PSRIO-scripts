-- -- CHART
-- local chart1 = Chart("Chart Title");

-- -- LINE
-- chart1:push_line("cmgdem");

-- -- chart1:push_line_stacking("output");
-- -- chart1:push_line_percent("output");

-- -- -- COLUMN
-- -- chart1:push_column("output1");
-- -- chart1:push_column_stacking("output1");
-- -- chart1:push_column_percent("output1");

-- -- -- AREA
-- -- chart1:push_area("output1");
-- -- chart1:push_area_stacking("output1");
-- -- chart1:push_area_percent("output1");
-- -- chart1:push_area_range("output1", "output2");

-- -- -- HISTOGRAM
-- -- chart1:push_histogram("output1");

-- -- -- PIE
-- -- chart1:push_pie("output1");

-- -- -- OPTIONS
-- -- chart1:push_line("output", {color="#ffffff"});




-- -- DASHBOARD
-- local dashboard = Dashboard("Dashboard title");

-- -- MENU
-- dashboard:add_menu("Menu Title", "menu_id");

-- -- DASHBOARD PUSH
-- -- dashboard:push(chart1);
-- -- dashboard:push({chart1});
-- -- dashboard:push({chart1, chart2});

-- -- dashboard:push(chart1, "menu_id");
-- dashboard:push(chart1, "menu_id");
-- -- dashboard:push({chart1, chart2}, "menu_id");

-- -- DASHBOARD SAVE
-- dashboard:save("risk");





-- -- -- HEATMAP
-- -- chart1:push_heatmap("output1");
-- -- chart1:push_heatmap("output1", {"blue", "white", "red"});
-- -- chart1:push_heatmap("output1", {max=25, min=-15, stops={{0, '#3060cf'}, {0.5, '#fffbbc'}, {1, '#c4463a'}}});















































-- -- -- DASHBOARD
-- -- local dashboard = Dashboard("Dashboard title");

-- -- -- MENU
-- -- dashboard:add_menu("Menu Title", "menu_id");

-- -- -- DASHBOARD PUSH
-- -- dashboard:push(chart1);
-- -- dashboard:push({chart1});
-- -- dashboard:push({chart1, chart2});

-- -- dashboard:push(chart1, "menu_id");
-- -- dashboard:push({chart1}, "menu_id");
-- -- dashboard:push({chart1, chart2}, "menu_id");

-- -- -- DASHBOARD SAVE
-- -- dashboard:save("risk");


















-- CHART
local chart1 = Chart("Chart 1");
chart1:push_line("cmgdem");

local chart2 = Chart("Chart 2");
chart2:push_line("gergnd");

-- DASHBOARD
local dashboard = Dashboard("Dashboard title");

dashboard:add_menu("Menu 1", "menu1");
dashboard:add_menu("Menu 2", "menu2");

dashboard:push({chart1}, "menu1");
dashboard:push_markdown("``` code ```");


dashboard:push({chart2}, "menu2");

dashboard:save("risk");





-- -- HEATMAP
-- chart1:push_heatmap("output1");
-- chart1:push_heatmap("output1", {"blue", "white", "red"});
-- chart1:push_heatmap("output1", {max=25, min=-15, stops={{0, '#3060cf'}, {0.5, '#fffbbc'}, {1, '#c4463a'}}});















































-- -- DASHBOARD
-- local dashboard = Dashboard("Dashboard title");

-- -- MENU
-- dashboard:add_menu("Menu Title", "menu_id");

-- -- DASHBOARD PUSH
-- dashboard:push(chart1);
-- dashboard:push({chart1});
-- dashboard:push({chart1, chart2});

-- dashboard:push(chart1, "menu_id");
-- dashboard:push({chart1}, "menu_id");
-- dashboard:push({chart1, chart2}, "menu_id");

-- -- DASHBOARD SAVE
-- dashboard:save("risk");














