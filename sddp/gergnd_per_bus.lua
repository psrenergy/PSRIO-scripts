if renewable == nil then renewable = Renewable(); end

local suffixes = {"", "__day", "__week", "__hour", "__trueup"}
for _, suffix in ipairs(suffixes) do
    renewable:load("gergnd" .. suffix)
        :aggregate_agents(BY_SUM(), Collection.BUSES)
        :save("gergnd" .. suffix .. "_per_bus");
end