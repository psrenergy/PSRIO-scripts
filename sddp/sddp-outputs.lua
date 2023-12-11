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

-- POTGND - Renewable capacity scenario
renewable = Renewable();
renwscen = renewable:load("renwscen");
potgnd = renwscen * renewable.capacity;
if potgnd:is_hourly() then
  potgnd:save("potgnd", {variable_by_block=2, csv=is_csv});
else
  potgnd:save("potgnd", {csv=is_csv});
end

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
  batcapacity = battery.capacity;
  pbatstg = safe_divide(batstg,batcapacity):convert("%");
  if pbatstg:is_hourly() then
    pbatstg:save("pbatstg", {variable_by_block=2, csv=is_csv});
  else
    pbatstg:save("pbatstg", {csv=is_csv});
  end
end
