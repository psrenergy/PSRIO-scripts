-- local chart1 = Chart("Chart 1");
-- chart1:add_line("cmgdem");

-- local chart2 = Chart("Chart 2");
-- chart2:add_line("gergnd");

-- local chart3 = Chart("Chart 3");
-- chart2:add_line("gerhid");

-- local dashboard1 = Dashboard("Dashboard1");
-- dashboard1:add_chart({chart1});
-- dashboard1:add_markdown("``` code ```");

-- local dashboard2 = Dashboard("Dashboard2");
-- dashboard2:add_chart({chart2});
-- dashboard2:add_markdown("``` code ```");

-- local dashboard3 = Dashboard("Dashboard3");
-- dashboard3:add_chart({chart3});
-- dashboard3:add_markdown("``` code ```");

-- (dashboard1 + dashboard2 + dashboard3):save("risk");





































local chart1 = Chart("Chart 1");
chart1:add_line("cmgdem");

local chart2 = Chart("Chart 2");
chart2:add_line("gergnd");

local chart3 = Chart("Chart 3");

local generic = require("collection/generic");
duraci = generic:load("duraci");

(2 * duraci):save("duraci2");
chart3:add_area_range("duraci2", "duraci", {color="#ffff00"});

local dashboard1 = Dashboard("Dashboard1");
dashboard1:push(chart1);
dashboard1:push("``` code ```");
dashboard1:push(chart3);

local dashboard2 = Dashboard("Dashboard2");
dashboard2:push(chart2);
dashboard2:push("# HEADLINE");
dashboard2:push("*This text will be italic*");
dashboard2:push("_This will also be italic_");
dashboard2:push("**This text will be bold**");
dashboard2:push("__This will also be bold__");
dashboard2:push("_You **can** combine them_");


dashboard2:push("As Kanye West said:");
dashboard2:push("> We're living the future so");
dashboard2:push("> the present is our past.");
dashboard2:push("I think you should use an");
dashboard2:push("`<addr>` element here instead.");
-- dashboard2:push("");
-- dashboard2:push("");
-- dashboard2:push("");
-- dashboard2:push("");


-- dashboard2:push("http://github.com - automatic![GitHub](http://github.com)")




-- local dashboard3 = Dashboard("Dashboard3");
-- dashboard3:push({chart1, chart2});
-- dashboard3:add_markdown("``` code ```");

(dashboard1 + dashboard2):save("aaa");



