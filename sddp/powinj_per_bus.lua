if power_injection == nil then power_injection = PowerInjection(); end

local suffixes = {"", "__day", "__week", "__hour", "__trueup"}
for _, suffix in ipairs(suffixes) do
    power_injection:load("powinj" .. suffix)
        :aggregate_agents(BY_SUM(), Collection.BUSES)
        :save("powinj" .. suffix .. "_per_bus");
end