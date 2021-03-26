if hydro == nil then hydro = Hydro(); end

-- ENEARM
volfin = hydro:load("volfin");
fprodtac = hydro:load("fprodtac");
ifelse(hydro.existing:gt(0.5), 0, (volfin - hydro.vmin) * fprodtac)
    :aggregate_agents(BY_SUM(), Collection.SYSTEMS)
    :convert("GWh")
    :save("enearm");