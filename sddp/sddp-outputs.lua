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

-- VEREC - Expected value of the percentage of rationing with respect to the load
local vere15 = require("sddp/vere15")();
if vere15:is_hourly() then
  enembp:save("vere15");
else
  enembp:save("vere15",{csv=true});
end