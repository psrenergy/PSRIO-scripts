if dclink == nil then dclink = DCLink(); end

-- CAPDCL1 AND CAPDCL2
dclink.capacity_right:save("capdcl1", {remove_zeros = true});
dclink.capacity_left:save("capdcl2", {remove_zeros = true});