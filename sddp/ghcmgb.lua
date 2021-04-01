function save_ghcmgb()
    if hydro == nil then hydro = Hydro(); end
    if bus == nil then bus = Bus(); end
    local gerhid = hydro:load("gerhid");
    local cmgbus = bus:load("cmgbus");
    (gerhid * cmgbus):save("ghcmgb");
end