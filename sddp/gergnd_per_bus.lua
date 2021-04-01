function save_gergnd_per_bus(suffix)
    if renewable == nil then renewable = Renewable(); end
    local output = "gergnd" .. (suffix or "")
    renewable:load(output):aggregate_agents(BY_SUM(), Collection.BUSES):save(output .. "_per_bus");
end