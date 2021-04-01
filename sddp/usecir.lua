function save_usecir(suffix)
    if circuit == nil then circuit = Circuit(); end
    local cirflw = circuit:load("cirflw" .. (suffix or ""));
    (cirflw:abs() / circuit.capacity):convert("%"):save("usecir" .. (suffix or ""));
end