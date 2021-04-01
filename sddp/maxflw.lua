function save_maxflw()
    if circuit == nil then circuit = Circuit(); end
    circuit.capacity:save("maxflw");
end