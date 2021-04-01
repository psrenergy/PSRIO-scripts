function save_gergnd_per_bus(suffix)
    if battery == nil then battery = Battery(); end
    local output = "gerbat" .. (suffix or "")
    battery:load(output):aggregate_agents(BY_SUM(), Collection.BUSES):save(output .. "_per_bus");
end