if thermal == nil then thermal = Thermal(); end
if fuel == nil then fuel = Fuel(); end

-- CINTE2 - Thermal plt. unit cost - seg. 2
(thermal.cesp2 * (thermal.transport_cost + fuel.cost) + thermal.omcost):save("cinte2");