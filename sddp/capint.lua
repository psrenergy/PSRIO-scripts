function capint()
    if interconnection == nil then interconnection = Interconnection(); end
    interconnection.capacity_right:save("capint1");
    interconnection.capacity_left:save("capint2");
end