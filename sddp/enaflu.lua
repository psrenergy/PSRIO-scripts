function save_enaflu()
    if hydro == nil then hydro = Hydro(); end
    local inflow = hydro:load("inflow");
    local fprodtac = hydro:load("fprodtac");
    ifelse(hydro.existing:gt(0.5), 0, inflow * fprodtac):aggregate_agents(BY_SUM(), Collection.SYSTEMS):convert("GWh"):save("enaflu");
end