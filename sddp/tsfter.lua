function save_tsfter()
    if thermal == nil then thermal = Thermal(); end
    thermal.ih:save("tsfter");
end