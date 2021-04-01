function save_potter()
    if thermal == nil then thermal = Thermal(); end
    ifelse(thermal.existing:gt(0.5), 0, thermal.germax_maintenance):save("potter");
end