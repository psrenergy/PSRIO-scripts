function save_capdcl1()
    if dclink == nil then dclink = DCLink(); end
    dclink.capacity_right:save("capdcl1", {remove_zeros = true});
end