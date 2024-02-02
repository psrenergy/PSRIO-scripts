gergnd = Generic():load("gergnd");
gergnd = gergnd:aggregate_agents(BY_SUM(), "Total Power Generation");
prod = Generic():load("h2_prod"):aggregate_agents(BY_SUM(),"Electrolyser consumption");
exp = Generic():load("line_export"):aggregate_agents(BY_SUM(), "Export");
imp = Generic():load("line_import"):aggregate_agents(BY_SUM(), "Import");
storage = Generic():load("ess_volf"):aggregate_agents(BY_SUM(), "Final storage");

gergnd_mscen = gergnd:aggregate_scenarios(BY_AVERAGE());
prod_mscen = prod:aggregate_scenarios(BY_AVERAGE());
exp_mscen = exp:aggregate_scenarios(BY_AVERAGE());
imp_mscen = imp:aggregate_scenarios(BY_AVERAGE());
storage_mscen = storage:aggregate_scenarios(BY_AVERAGE());

local N_scn = gergnd:scenarios();

tab2 = Tab("Operation by scenario");
for sce = 1,N_scn do
   local chart = Chart("Operation of the hydrogen production facility - scenario " .. sce)
   chart:add_line(concatenate(gergnd:select_scenario(sce),prod:select_scenario(sce),exp:select_scenario(sce),imp:select_scenario(sce),storage:select_scenario(sce)));
   tab2:push(chart)
end

tab = Tab("Average operation");
graph = concatenate(gergnd_mscen,prod_mscen,exp_mscen,imp_mscen,storage_mscen);
chart1 = Chart("Operation of the hydrogen production facility - average");
chart1:add_line(graph);
tab:push(chart1);


dashboard = Dashboard();
dashboard:push(tab);
dashboard:push(tab2);
dashboard:save("dashboard");