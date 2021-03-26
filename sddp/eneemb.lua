if hydro == nil then hydro = Hydro(); end

-- ENEEMB
volfin = hydro:load("volfin");
fprodtac = hydro:load("fprodtac");
ifelse(hydro.existing:gt(0.5), 0, (volfin - hydro.vmin) * fprodtac):convert("GWh"):save("eneemb");