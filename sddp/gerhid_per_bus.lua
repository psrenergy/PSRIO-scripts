function save_gerhid_per_bus(suffix)
    if hydro == nil then hydro = Hydro(); end
    local output = "gerhid" .. (suffix or "")
    hydro:load(output):aggregate_agents(BY_SUM(), Collection.BUSES):save(output .. "_per_bus");
end