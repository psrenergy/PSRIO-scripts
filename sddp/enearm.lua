function save_enearm()
    if hydro == nil then hydro = Hydro(); end
    local volfin = hydro:load("volfin");
    local fprodtac = hydro:load("fprodtac");
    ifelse(hydro.existing:gt(0.5), 0, (volfin - hydro.vmin) * fprodtac):aggregate_agents(BY_SUM(), Collection.SYSTEMS):convert("GWh"):save("enearm");
end