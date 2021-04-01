function save_pothid()
    if hydro == nil then hydro = Hydro(); end
    local fprodt = hydro:load("fprodt");
    ifelse(hydro.existing:gt(0.5), 0, min(hydro.qmax * fprodt, hydro.capacity_maintenance)):save("pothid");
end