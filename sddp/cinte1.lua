if thermal == nil then thermal = Thermal(); end
if fuel == nil then fuel = Fuel(); end

-- CINTE1 - Thermal plt. unit cost - seg. 1
(thermal.cesp1 * (thermal.transport_cost + fuel.cost) + thermal.omcost):save("cinte1");