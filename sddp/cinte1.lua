function save_cinte1()
    if thermal == nil then thermal = Thermal(); end
    if fuel == nil then fuel = Fuel(); end
    (thermal.cesp1 * (thermal.transport_cost + fuel.cost) + thermal.omcost):save("cinte1");
end