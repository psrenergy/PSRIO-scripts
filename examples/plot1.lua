local generic = require("collection/generic");

local gerhid = generic:load("gerhid"):select_agents({"ITAIPU"}):aggregate_blocks(BY_SUM());

local gerhid_p0 = gerhid:aggregate_scenarios(BY_PERCENTILE(0)):rename_agents({"0%"});
local gerhid_p10 = gerhid:aggregate_scenarios(BY_PERCENTILE(10)):rename_agents({"10%"});
local gerhid_p30 = gerhid:aggregate_scenarios(BY_PERCENTILE(30)):rename_agents({"30%"});
local gerhid_p50 = gerhid:aggregate_scenarios(BY_PERCENTILE(50)):rename_agents({"Median (50%)"});
local gerhid_p70 = gerhid:aggregate_scenarios(BY_PERCENTILE(70)):rename_agents({"70%"});
local gerhid_p90 = gerhid:aggregate_scenarios(BY_PERCENTILE(90)):rename_agents({"90%"});
local gerhid_p100 = gerhid:aggregate_scenarios(BY_PERCENTILE(100)):rename_agents({"100%"});
local gerhid_avg = gerhid:aggregate_scenarios(BY_AVERAGE()):rename_agents({"Mean"});

local gergnd = generic:load("gergnd"):select_agents({"EOL-NE-BA"}):convert("MW"):aggregate_blocks(BY_SUM());
local gergnd_p0 = gergnd:aggregate_scenarios(BY_PERCENTILE(0)):rename_agents({"0%"});
local gergnd_p10 = gergnd:aggregate_scenarios(BY_PERCENTILE(10)):rename_agents({"10%"});
local gergnd_p30 = gergnd:aggregate_scenarios(BY_PERCENTILE(30)):rename_agents({"30%"});
local gergnd_p50 = gergnd:aggregate_scenarios(BY_PERCENTILE(50)):rename_agents({"Median (50%)"});
local gergnd_p70 = gergnd:aggregate_scenarios(BY_PERCENTILE(70)):rename_agents({"70%"});
local gergnd_p90 = gergnd:aggregate_scenarios(BY_PERCENTILE(90)):rename_agents({"90%"});
local gergnd_p100 = gergnd:aggregate_scenarios(BY_PERCENTILE(100)):rename_agents({"100%"});
local gergnd_avg = gergnd:aggregate_scenarios(BY_AVERAGE()):rename_agents({"Mean"});

local light_blue = "#8583ff";
local dark_blue = "#2f2c95";

local chart1 = Chart("KAR vol percentiles");
chart1:add_area_range(gerhid_p0, gerhid_p100, {color=light_blue});
chart1:add_area_range(gerhid_p10, gerhid_p90, {color=light_blue});
chart1:add_area_range(gerhid_p30, gerhid_p70, {color=light_blue});
chart1:add_line(gerhid_p50, {color=dark_blue});
chart1:add_line(gerhid_avg, {color=dark_blue});

local light_yellow = "#F9E79F";
local dark_yellow = "#F1C40F";

local chart2 = Chart("Snid lllb intsum percentiles");
chart2:add_area_range(gergnd_p0, gergnd_p100, {color=light_yellow});
chart2:add_area_range(gergnd_p10, gergnd_p90, {color=light_yellow});
chart2:add_area_range(gergnd_p30, gergnd_p70, {color=light_yellow});
chart2:add_line(gergnd_p50, {color=dark_yellow});
chart2:add_line(gergnd_avg, {color=dark_yellow});

local dashboard = Dashboard("Plot Example");
dashboard:push(chart1);
dashboard:push(chart2);
dashboard:save("teste");
