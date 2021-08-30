local generic = require("collection/generic");

local mismatch_power = generic:load("cache_mismatch_power");

local apagao_severo = ifelse(mismatch_power:gt(0), 1, 0):aggregate_blocks(BY_AVERAGE());
local risco_apagao_severo = ifelse(apagao_severo:gt(1), 1, 0):aggregate_scenarios(BY_AVERAGE());

risco_apagao_severo:save("debug");