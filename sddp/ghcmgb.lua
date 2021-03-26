if hydro == nil then hydro = Hydro(); end
if bus == nil then bus = Bus(); end

-- GHCMGB - Hydro Gen. x Bus MargCost 
gerhid = hydro:load("gerhid");
cmgbus = bus:load("cmgbus");
(gerhid * cmgbus):save("ghcmgb");