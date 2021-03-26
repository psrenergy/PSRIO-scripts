if thermal == nil then thermal = Thermal(); end

-- DATARR - Start-up Cost Data
thermal.startup_cost:save("datarr", {remove_zeros = true});