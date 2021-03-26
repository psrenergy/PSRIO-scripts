if thermal == nil then thermal = Thermal(); end

-- POTTER - Available thermal capacity
ifelse(thermal.existing:gt(0.5), 0, thermal.germax_maintenance):save("potter");