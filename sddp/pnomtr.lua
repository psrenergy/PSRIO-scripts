function save_pnomtr()
    if thermal == nil then thermal = Thermal(); end
    thermal.capacity:save("pnomtr");
end