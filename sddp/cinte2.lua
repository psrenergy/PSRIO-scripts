function save_cinte2()
    if thermal == nil then thermal = Thermal(); end
    if fuel == nil then fuel = Fuel(); end
    (thermal.cesp2 * (thermal.transport_cost + fuel.cost) + thermal.omcost):save("cinte2");
end