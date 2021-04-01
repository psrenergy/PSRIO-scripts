function save_powinj_per_bus(suffix)
    if powerinjection == nil then powerinjection = PowerInjection(); end
    local output = "powinj" .. (suffix or "");
    powerinjection:load(output):aggregate_agents(BY_SUM(), Collection.BUSES):save(output .. "_per_bus");
end