function save_gtcmgb()
    if thermal == nil then thermal = Thermal(); end
    if bus == nil then bus = Bus(); end
    local gerter = thermal:load("gerter");
    local cmgbus = bus:load("cmgbus");
    (gerter * cmgbus):save("gtcmgb");
end