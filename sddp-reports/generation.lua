if battery == nil then battery = Battery(); end
if hydro == nil then hydro = Hydro(); end
if renewable == nil then renewable = Renewable(); end
if system == nil then system = System(); end
if thermal == nil then thermal = Thermal(); end

concatenate(
    hydro:load("gerhid"):aggregate_agents(BY_SUM(), "Total Hydro"):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()),
    thermal:load("gerter"):aggregate_agents(BY_SUM(), "Total Term."):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()),
    renewable:load("gergnd"):aggregate_agents(BY_SUM(), "Total Renw."):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()),
    battery:load("gerbat"):aggregate_agents(BY_SUM(), "Total Batt."):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()):convert("GWh"),
    system:load("defcit"):aggregate_agents(BY_SUM(), "Deficit"):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE())
):save("sddpgrxxd");