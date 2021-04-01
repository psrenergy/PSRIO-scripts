function capdcl2()
    if dclink == nil then dclink = DCLink(); end
    dclink.capacity_left:save("capdcl2", {remove_zeros = true});
end