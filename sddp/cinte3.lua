if thermal == nil then thermal = Thermal(); end
if fuel == nil then fuel = Fuel(); end

-- CINTE3 - Thermal plt. unit cost - seg. 3
(thermal.cesp3 * (thermal.transport_cost + fuel.cost) + thermal.omcost):save("cinte3");