function save_lscinf()
    if circuitssum == nil then circuitssum = CircuitsSum(); end
    circuitssum.lb:save("lscinf");
end