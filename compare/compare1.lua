local label1 = "case1";
local label2 = "case2";

local hydro1 = require_collection("Hydro", 1);
local hydro2 = require_collection("Hydro", 2);

local gerhid1 = hydro1:load("gerhid")
    :aggregate_blocks(BY_SUM())
    :aggregate_scenarios(BY_AVERAGE())
    :aggregate_agents(BY_SUM(), label1);

local gerhid2 = hydro2:load("gerhid_KTT")
    :aggregate_blocks(BY_SUM())
    :aggregate_scenarios(BY_AVERAGE())
    :aggregate_agents(BY_SUM(), label2);

local chart = Chart("Hydro Generation");
chart:add_line(gerhid1);
chart:add_line(gerhid2);

local dashboard = Dashboard("Compare");
dashboard:push(chart);
dashboard:save("debug");




-- cmgdem = "Load Marginal Cost"