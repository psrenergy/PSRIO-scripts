if circuit == nil then circuit = Circuit(); end

local suffixes = {"", "__day", "__week", "__hour", "__trueup"}
for _, suffix in ipairs(suffixes) do
    local cirflw = circuit:load("cirflw" .. suffix);
    -- USECIR
    (cirflw:abs() / circuit.capacity):convert("%"):save("usecir" .. suffix);
end