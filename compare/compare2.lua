local label1 = "case1";
local label2 = "case2";

local generic1 = require_collection("Generic", 1);
local generic2 = require_collection("Generic", 2);

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