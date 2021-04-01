function save_frinmx()
    if fuelreservoir == nil then fuelreservoir = FuelReservoir(); end
    min(fuelreservoir.maxinjection, fuelreservoir.maxinjection_chronological):save("frinmx");
end