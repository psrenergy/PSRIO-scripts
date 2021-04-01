function save_datarr()
    if thermal == nil then thermal = Thermal(); end
    thermal.startup_cost:save("datarr", {remove_zeros = true});
end