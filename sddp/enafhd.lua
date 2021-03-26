if hydro == nil then hydro = Hydro(); end

-- ENAFHD
inflow = hydro:load("inflow");
fprodtac = hydro:load("fprodtac");
ifelse(hydro.existing:gt(0.5), 0, inflow * fprodtac):convert("GWh"):save("enafhd");