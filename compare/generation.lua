local label1 = "case1";
local label2 = "case2";

local hydro1 = require_collection("Hydro", 1);
local hydro2 = require_collection("Hydro", 2);

local gerhid1 = hydro1:load("gerhid");
local gerhid2 = hydro2:load("gerhid");

local volfin1 = hydro1:load("volfin");
local volfin2 = hydro2:load("volfin");

local bus1 = require_collection("Bus", 1);
local bus2 = require_collection("Bus", 2);

local system1 = require_collection("System", 1);
local system2 = require_collection("System", 2);

local defcit1 = system1:load("defcit");
local defcit2 = system2:load("defcit");

local function add_comparison(dashboard, file, blocks, chart_label)
    local output1 = generic1:load(file)
        :aggregate_blocks(blocks)
        :aggregate_scenarios(BY_AVERAGE())
        :aggregate_agents(BY_SUM(), label1);

    local output2 = generic2:load(file)
        :aggregate_blocks(blocks)
        :aggregate_scenarios(BY_AVERAGE())
        :aggregate_agents(BY_SUM(), label2);

    if output1:loaded() and output2:loaded() then
        local chart = Chart(chart_label);
        chart:add_line(output1);
        chart:add_line(output2);
        dashboard:push(chart);    
    end
end

"defcos.csv", 
"coster.csv", 
"fprodt.csv",
"qverti.csv", 
"qturbi.csv", 
"gerter.csv", 
"interc.csv", 
"cmgbus.csv", 
"cirflw.csv",
"enever.csv", 
"gergnd.csv", 
"volini.csv", 
"fuelcn.csv", 
"cmgdem.csv", 
"cmgcir.csv",
"rrodhd.csv", 
"rrodtr.csv", 
"cmgrrt.csv", 
"cmgrrh.csv",
"penreg.csv", 
"cmgreg.csv", 
"vrestg.csv"






local function add_comparison(dashboard, file, blocks, chart_label)
    local output1 = generic1:load(file)
        :aggregate_blocks(blocks)
        :aggregate_scenarios(BY_AVERAGE())
        :aggregate_agents(BY_SUM(), label1);

    local output2 = generic2:load(file)
        :aggregate_blocks(blocks)
        :aggregate_scenarios(BY_AVERAGE())
        :aggregate_agents(BY_SUM(), label2);

    if output1:loaded() and output2:loaded() then
        local chart = Chart(chart_label);
        chart:add_line(output1);
        chart:add_line(output2);
        dashboard:push(chart);    
    end
end

local cost = Dashboard("Cost");
add_comparison(cost, "cmgdem", BY_AVERAGE(), "Load Marginal Cost");
add_comparison(cost, "coster", BY_AVERAGE(), "Thermal Cost");
add_comparison(cost, "defcit", BY_AVERAGE(), "Deficit Cost");

local generation = Dashboard("Generation");
add_comparison(generation, "gerhid", BY_SUM(), "Hydro Generation");
add_comparison(generation, "gergnd", BY_SUM(), "Renewable Generation");
add_comparison(generation, "gerter", BY_SUM(), "Thermal Generation");

(cost + generation):save("comparison");