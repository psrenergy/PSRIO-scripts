if hydro == nil then hydro = Hydro(); end

-- ENAFLU
inflow = hydro:load("inflow");
fprodtac = hydro:load("fprodtac");
ifelse(hydro.existing:gt(0.5), 0, inflow * fprodtac)
    :aggregate_agents(BY_SUM(), Collection.SYSTEMS)
    :convert("GWh")
    :save("enaflu");