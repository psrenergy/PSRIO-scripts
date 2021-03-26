if battery == nil then battery = Battery(); end

local suffixes = {"", "__day", "__week", "__hour", "__trueup"}
for _, suffix in ipairs(suffixes) do
    battery:load("gerbat" .. suffix)
        :aggregate_agents(BY_SUM(), Collection.BUSES)
        :save("gerbat" .. suffix .. "_per_bus");
end