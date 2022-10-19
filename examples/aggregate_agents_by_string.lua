local spairs = require("lua/spairs");

local thermal = Thermal();
local output = thermal:load("gerter"):aggregate_agents(BY_SUM(), Collection.FUEL);
local agents = output:agents();

-- BUILD DICTIONARY WITH UNIQUE AGENT NAMES
local dictionary = {};
for i, v in spairs(agents) do
    if dictionary[v] then
        table.insert(dictionary[v], i);
    else
        dictionary[v] = { i };
    end
end

-- AGGREGATE AGENTS
local unique_agents = {};
for agent, indices in pairs(dictionary) do 
    info("Aggregating " .. agent .. "...");
    table.insert(unique_agents, output:select_agents(indices):aggregate_agents(BY_SUM(), agent));   
end
concatenate(unique_agents):save("gerter_agg_fuel_unique", {fast_csv = true});