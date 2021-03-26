if system == nil then system = System(); end

marginal_cost = system:load("cmgdem"):aggregate_blocks(BY_AVERAGE()):aggregate_scenarios(BY_AVERAGE());
marginal_cost:save("sddpcmgd");
marginal_cost:aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR):save("sddpcmga");