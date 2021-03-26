if hydro == nil then hydro = Hydro(); end

-- POTHID - Available hydro capacity
fprodt = hydro:load("fprodt");
ifelse(hydro.existing:gt(0.5), 0, min(hydro.qmax * fprodt, hydro.capacity_maintenance)):save("pothid");