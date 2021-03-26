if circuit == nil then circuit = Circuit(); end

-- USECIR
cirflw = circuit:load("cirflw")
(cirflw:abs() / circuit.capacity):convert("%"):save("usecir");