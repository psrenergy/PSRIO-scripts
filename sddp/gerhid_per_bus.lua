if hydro == nil then hydro = Hydro(); end

suffixes = {"", "__day", "__week", "__hour", "__trueup"}
for _, suffix in ipairs(suffixes) do
    hydro:load("gerhid" .. suffix)
        :aggregate_agents(BY_SUM(), Collection.BUSES)
        :save("gerhid" .. suffix .. "_per_bus");
end