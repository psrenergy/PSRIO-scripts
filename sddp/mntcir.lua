function save_mntcir()
    if circuit == nil then circuit = Circuit(); end
    ifelse(circuit.status:gt(0.5), 0, 1):save("mntcir");
end