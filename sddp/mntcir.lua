if circuit == nil then circuit = Circuit(); end

-- MNTCIR - Circuit flag
ifelse(circuit.status:gt(0.5), 0, 1):save("mntcir");