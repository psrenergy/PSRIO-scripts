if thermal == nil then thermal = Thermal(); end

local suffixes = {"", "__day", "__week", "__hour", "__trueup"}
for _, suffix in ipairs(suffixes) do
    thermal:load("gerter" .. suffix)
        :aggregate_agents(BY_SUM(), Collection.BUSES)
        :save("gerter" .. suffix .. "_per_bus");
end