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

-- POTCSP - CSP capacity scenario
csp = ConcentratedSolarPower();
cspscen = csp:load("cspscen");
capacity = csp:load_vector("PotInst", "MW");
potcsp = cspscen * capacity;
if potcsp:is_hourly() then
  potcsp:save("potcsp", {variable_by_block=2, csv=is_csv});
else
  potcsp:save("potcsp", {csv=is_csv});
end

-- OEMGND - Renewable O&M unitary cost
renewable = Renewable();
oemgnd = renewable.om_cost;
oemgnd:save("oemgnd",{csv=is_csv});

-- PBATSTG - Percentual of battery storage
battery = Battery();
batstg = battery:load("batstg"):convert("MW");
if batstg:loaded() then
  max_storage = battery.max_storage;
  pbatstg = safe_divide(batstg,max_storage):convert("%");
  if pbatstg:is_hourly() then
    pbatstg:save("pbatstg", {variable_by_block=2, csv=is_csv});
  else
    pbatstg:save("pbatstg", {csv=is_csv});
  end
end

-- COSSHUT - Shutdown cost of commitment thermal plants
thermal = Thermal();
trshdw = thermal:load("trshdw");
if trshdw:loaded() then
  cosshut = thermal.shutdown_cost * trshdw;
  if cosshut:is_hourly() then
    cosshut:save("cosshut", {variable_by_block=2, csv=is_csv});
  else
    cosshut:save("cosshut", {csv=is_csv});
  end
end

-- GASEMI - total gas emission
emission = GasEmission();
generic = Generic();
local emiValues = generic:load("teremi");
if emiValues:loaded() then
  local emiNames = emission:labels();
  local emiAux   = {}
  for _, iName in ipairs(emiNames) do
    table.insert(emiAux, emiValues:select_agents_by_regex(iName .. "(.*)"):aggregate_agents(BY_SUM(), iName))
  end
  gasemi = concatenate(emiAux):select_agents(Collection.GAS_EMISSION);
  if gasemi:is_hourly() then
    gasemi:save("gasemi", {variable_by_block=2, csv=is_csv});
  else
    gasemi:save("gasemi", {csv=is_csv});
  end
end

-- OEMBATUN - battery o&m cost
battery = Battery();
local oembatun = battery.om_cost;
oembatun:save("oembatun", {csv=is_csv});

-- gerterMW - thermal MW generation
thermal = Thermal();
gerter = thermal:load("gerter");
if gerter:loaded() then
  if gerter:is_hourly() then
    gerter:convert("MW"):save("gerterMW", {variable_by_block=2, csv=is_csv});
  else
    gerter:convert("MW"):save("gerterMW", {csv=is_csv});
  end
end