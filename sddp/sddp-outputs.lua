-- Verifying format option
is_csv = Study():get_parameter("BINF",0) == 0;

-- ENEMBP - Percentual of stored energy by reservatory
local enembp = require("sddp/enembp")();
if enembp:is_hourly() then
  enembp:save("enembp", {variable_by_block=2, csv=is_csv});
else
  enembp:save("enembp", {csv=is_csv});
end

-- USERNW - Renewable dispatch factor
local usernw = require("sddp/usernw")();
usernw:save("usernw", {variable_by_block=2, csv=is_csv});

-- VERE15 - Expected value of the percentage of rationing with respect to the load
local vere15 = require("sddp/vere15")();
vere15:save("vere15",{csv=is_csv});
