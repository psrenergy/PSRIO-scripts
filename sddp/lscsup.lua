function save_lscsup()
    if circuitssum == nil then circuitssum = CircuitsSum(); end
    circuitssum.ub:save("lscsup");
end