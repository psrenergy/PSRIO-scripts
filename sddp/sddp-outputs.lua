-- ENEMBP - Percentual of stored energy by reservatory
local enembp = require("sddp/enembp")();
if enembp:is_hourly() then
  enembp:save("enembp", {variable_by_block=2});
else
  enembp:save("enembp");
end

-- USERNW - Renewable dispatch factor
local usernw = require("sddp/usernw");
usernw():select_stages():save("usernw", {variable_by_block=2});