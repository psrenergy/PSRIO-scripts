function save_eneemb()
    if hydro == nil then hydro = Hydro(); end
    local volfin = hydro:load("volfin");
    local fprodtac = hydro:load("fprodtac");
    ifelse(hydro.existing:gt(0.5), 0, (volfin - hydro.vmin) * fprodtac):convert("GWh"):save("eneemb");
end