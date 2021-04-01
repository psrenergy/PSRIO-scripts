function save_usedcl(suffix)
    if dclink == nil then dclink = DCLink(); end
    local linkdc = dclink:load("dclink" .. (suffix or "")):convert("MW");

    ifelse(linkdc:gt(0), 
        ifelse(dclink.capacity_right:gt(0), linkdc / dclink.capacity_right, 1.0), 
        ifelse(dclink.capacity_left:gt(0), -linkdc / dclink.capacity_left, 1.0)
    ):convert("%"):save("usedcl" .. (suffix or ""));
end