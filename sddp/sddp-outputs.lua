-- ENEMBP - Percentual of stored energy by reservatory
local enembp = require("sddp/enembp");
enembp():save("enembp");

-- USERNW - Renewable dispatch factor
local usernw = require("sddp/usernw");
usernw():save("usernw");