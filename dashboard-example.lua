local function create_chart(title, exp, color)
    local avg = exp:aggregate_scenarios(BY_AVERAGE()):rename_agents({"avg"});
    local p10 = exp:aggregate_scenarios(BY_PERCENTILE(10)):rename_agents({"p10-p90"});
    local p25 = exp:aggregate_scenarios(BY_PERCENTILE(25)):rename_agents({"p25-p75"});
    local p75 = exp:aggregate_scenarios(BY_PERCENTILE(75)):rename_agents({"p75"});
    local p90 = exp:aggregate_scenarios(BY_PERCENTILE(90)):rename_agents({"p90"});
    local min = exp:aggregate_scenarios(BY_MIN()):rename_agents({"min"});
    local max = exp:aggregate_scenarios(BY_MAX()):rename_agents({"max"});

    local chart = Chart(title);
    chart:add_line(min, {color=color});
    chart:add_line(max, {color=color});
    chart:add_area_range(p10, p90, {color=color});
    chart:add_area_range(p25, p75, {color=color});
    chart:add_line(avg, {color="#000000"});

    return chart;
end

-- local hydro = require("collection/hydro");
-- local gerhid = hydro:load("gerhid"):aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), "all agents");

local chart = Chart("bla");
chart:add_histogram("gerter");
local dashboard = Dashboard("Hydro and Renewable");
dashboard:push(chart);
dashboard:save("bla")



-- local renewable = require("collection/renewable");
-- local gergnd = renewable:load("gergnd"):aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), "all agents");

-- local dashboard1 = Dashboard("Hydro and Renewable");
-- dashboard1:push(create_chart("Hydro Generation", gerhid, "#2f7ed8"));
-- dashboard1:push(create_chart("Renewable Generation", gergnd, "#8bbc21"));

-- local thermal = require("collection/thermal");
-- local gerter = thermal:load("gerter"):aggregate_blocks(BY_SUM()):aggregate_agents(BY_SUM(), "all agents");

-- local dashboard2 = Dashboard("Thermal");
-- dashboard2:push(create_chart("Thermal Generation", gerter, "#ff0000"));

-- -- Headlines
-- dashboard2:push("# h1 heading");
-- dashboard2:push("## h2 heading");
-- dashboard2:push("### h3 heading");
-- dashboard2:push("#### h4 heading");
-- dashboard2:push("##### h5 heading");
-- dashboard2:push("###### h6 heading");

-- -- Links
-- dashboard2:push("[Text of the link](http://example.com)");

-- -- Lists
-- dashboard2:push("- unordered");
-- dashboard2:push("* list");
-- dashboard2:push("+ items");

-- dashboard2:push("* unordered");
-- dashboard2:push("  * list");
-- dashboard2:push("  * items");
-- dashboard2:push("    * in");
-- dashboard2:push("    + an");
-- dashboard2:push("  - hierarchy");

-- dashboard2:push("1. ordered");
-- dashboard2:push("2. list");
-- dashboard2:push("3. items");

-- dashboard2:push("1. ordered");
-- dashboard2:push("* list");
-- dashboard2:push("* items");

-- dashboard2:push("1. ordered");
-- dashboard2:push("* list");
-- dashboard2:push("  1. items");
-- dashboard2:push("  * in");
-- dashboard2:push("    1. an");
-- dashboard2:push("  * hierarchy");

-- dashboard2:push("* combination");
-- dashboard2:push("* of");
-- dashboard2:push("  1. unordered and");
-- dashboard2:push("  * ordered");
-- dashboard2:push("* list");

-- dashboard2:push("- [ ] some item");
-- dashboard2:push("  - [ ] another item");
-- dashboard2:push("- [x] some checked item");

-- dashboard2:push("```some code```");

-- dashboard2:push("some text `some inline code` some other text");

-- dashboard2:push("> Some quote");

-- dashboard2:push("**bold text**");
-- dashboard2:push("__bold text__");

-- dashboard2:push("*italic text*");

-- dashboard2:push("_emphasized text_");

-- dashboard2:push("~~striked through text~~");

-- dashboard2:push("---");

-- dashboard2:push("New\r\nLine");

-- dashboard2:push("![Image alt text](https://www.psr-inc.com/wp-content/themes/psrNew/images/logo.png)");

-- dashboard2:push("");
-- dashboard2:push("");
-- dashboard2:push("");

-- dashboard2:push("# HEADLINE");
-- dashboard2:push("*This text will be italic*");
-- dashboard2:push("_This will also be italic_");
-- dashboard2:push("**This text will be bold**");
-- dashboard2:push("__This will also be bold__");
-- dashboard2:push("_You **can** combine them_");
-- dashboard2:push("As Kanye West said:");
-- dashboard2:push("> We're living the future so");
-- dashboard2:push("> the present is our past.");
-- dashboard2:push("I think you should use an");
-- dashboard2:push("`<addr>` element here instead.");

-- (dashboard1 + dashboard2 + nil):save("dashbaord");



