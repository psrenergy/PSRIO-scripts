function save_gerter_per_bus(suffix)
    if thermal == nil then thermal = Thermal(); end
    local output = "gerter" .. (suffix or "")
    thermal:load(output):aggregate_agents(BY_SUM(), Collection.BUSES):save(output .. "_per_bus");
end