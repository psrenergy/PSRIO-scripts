if thermal == nil then thermal = Thermal(); end
if bus == nil then bus = Bus(); end

-- GTCMGB - Therm Gen. x Bus MargCost 
gerter = thermal:load("gerter");
cmgbus = bus:load("cmgbus");
(gerter * cmgbus):save("gtcmgb");