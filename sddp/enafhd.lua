function save_enafhd()
    if hydro == nil then hydro = Hydro(); end
    local inflow = hydro:load("inflow");
    local fprodtac = hydro:load("fprodtac");
    ifelse(hydro.existing:gt(0.5), 0, inflow * fprodtac):convert("GWh"):save("enafhd");
end