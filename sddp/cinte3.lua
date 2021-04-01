function save_cinte3()
    if thermal == nil then thermal = Thermal(); end
    if fuel == nil then fuel = Fuel(); end
    (thermal.cesp3 * (thermal.transport_cost + fuel.cost) + thermal.omcost):save("cinte3");
end