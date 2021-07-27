local demand = require("collection/demand");
local study = require("collection/study");

if study:is_hourly_load() then
    demand.inelastic_hour:aggregate_agents(BY_SUM(), Collection.SYSTEM):convert("GWh"):save("demand");
else
    demand.inelastic_block:aggregate_agents(BY_SUM(), Collection.SYSTEM):save("demand");
end

local duraci = require("sddp/duraci");
duraci():save("duraci");