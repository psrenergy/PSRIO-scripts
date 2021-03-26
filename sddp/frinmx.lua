if fuelreservoir == nil then fuelreservoir = FuelReservoir(); end

-- FRINMX
min(fuelreservoir.maxinjection, fuelreservoir.maxinjection_chronological):save("frinmx");